# frozen_string_literal: true

module Lms
  class Circulations < Lms::Base
    helpers Lms::Helpers::MachineResponse

    resources :circulations do

      desc 'List of a circulation book'
      params do
        use :pagination, per_page: 25
      end
      get do
        circulations = @current_library.circulations.includes(:circulation_status, biblio_item: :biblio)
        Lms::Entities::Circulations.represent(paginate(circulations.order(id: :desc)))
      end

      desc 'add a book into circulation'
      params do
        requires :member_id, type: Integer, allow_blank: false
        requires :biblio_item_ids, type: Array, allow_blank: false
        optional :staff_id, type: Integer, allow_blank: false
        optional :is_machine, type: Boolean, values: [true, false], allow_blank: false
      end

      post do
        circulations = []
        total_book_loan_count = 0

        member = Member.find_by(id: params[:member_id])

        unless params[:is_machine].present?
          if params[:staff_id].blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:STAFF_ID_REQUIRED], error: 'Staff id required' },
                                    @current_library, false)
            present failed_response('Staff id required', HTTP_CUSTOM_CODE[:STAFF_ID_REQUIRED], [])
            next
          end
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:STAFF_NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            present failed_response('Staff not found', HTTP_CUSTOM_CODE[:STAFF_NOT_FOUND], [])
            next
          end
        end

        if member.blank?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CUSTOM_CODE[:MEMBER_NOT_FOUND], error: 'Member not found.' },
                                  @current_library, false)
          present failed_response('Member not found.', HTTP_CUSTOM_CODE[:MEMBER_NOT_FOUND], [])
          next
        end

        unless member.user.membership?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CUSTOM_CODE[:INVALID_MEMBERSHIP], error: 'Membership invalid.' },
                                  @current_library, false)
          present failed_response('Membership invalid.', HTTP_CUSTOM_CODE[:INVALID_MEMBERSHIP], [])
          next
        end


        if member.user.invoices&.fine&.pending.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CUSTOM_CODE[:PENDING_INVOICE], error: 'Patron have pending invoice' },
                                  @current_library, false)
          present failed_response('Patron have pending invoice', HTTP_CUSTOM_CODE[:PENDING_INVOICE], [])
          next
        end

        if (member.user.items_on_hand + member.user&.cart&.cart_items&.count.to_i) >= ENV['MAX_BORROW'].to_i
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CUSTOM_CODE[:MAX_BORROW_EXCEEDED], error: "You can not borrow more than #{ENV['MAX_BORROW'].to_i} items" },
                                  @current_library, false)
          present failed_response("You can not borrow more than #{ENV['MAX_BORROW'].to_i} items",
                                  HTTP_CUSTOM_CODE[:MAX_BORROW_EXCEEDED], [])
          next
        end

        ActiveRecord::Base.transaction do
          params[:biblio_item_ids].each do |biblio_item_id|

            biblio_item = BiblioItem.for_borrow.find_by(id: biblio_item_id)

            if biblio_item.blank?
              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CUSTOM_CODE[:BIBLIO_ITEM_NOT_FOUND], error: "Biblio item not found to borrow for the item id: #{biblio_item_id}" },
                                      @current_library, false)
              circulations << {
                "success": false,
                "status_code": HTTP_CUSTOM_CODE[:BIBLIO_ITEM_NOT_FOUND],
                "message": "Biblio item not found to borrow for the item id: #{biblio_item_id}"
              }
              next
            end

            circulation = Circulation.where(biblio_item_id: biblio_item_id)&.last
            if circulation&.circulation_status&.borrowed?

              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CUSTOM_CODE[:ALREADY_BORROWED], error: 'Biblio not available in this library' },
                                      @current_library, false)

              circulations << {
                "success": false,
                "status_code": HTTP_CUSTOM_CODE[:ALREADY_BORROWED],
                "accession_number": biblio_item.accession_no,
                "title": biblio_item.biblio.title.titleize,
                "message": 'Biblio not available in this library'
              }
              next
            end

            biblio_library = @current_library.biblio_libraries.find_by('available_quantity > ? AND biblio_id = ?', 0,
                                                                       biblio_item.biblio_id)
            if biblio_library.nil?

              LmsLogJob.perform_later(request.headers.merge(params:),
                                      { status_code: HTTP_CUSTOM_CODE[:BIBLIO_NOT_AVAILABLE_IN_LIBRARY], error: 'Biblio not available in this library' },
                                      @current_library, false)

              circulations << {
                "success": false,
                "status_code": HTTP_CUSTOM_CODE[:BIBLIO_NOT_AVAILABLE_IN_LIBRARY],
                "accession_number": biblio_item.accession_no,
                "title": biblio_item.biblio.title.titleize,
                "message": 'Biblio not available in this library'
              }
              next
            end

            circulation = @current_library.circulations.new
            circulation.member_id = member.id
            circulation.biblio_item_id = biblio_item.id
            circulation.updated_by = params[:is_machine].present? ? nil : staff
            circulation.is_machine = params[:is_machine].present?
            circulation.circulation_status = CirculationStatus.get_status(:borrowed)
            circulation.return_at = DateTime.now.advance(days: ENV['BORROW_DAYS'].to_i)
            circulation.save!
            circulations << {
              "success": true,
              "status_code": HTTP_CODE[:OK],
              "due_date": circulation.return_at,
              "accession_number": biblio_item.accession_no,
              "title": biblio_item.biblio.title.titleize,
              "message": 'Book has been loaned successfully'
            }
            total_book_loan_count += 1
          end
        end
        response = {
          "success": true,
          "status_code": HTTP_CODE[:OK],
          "message": if total_book_loan_count.zero?
                       'No Books Loaned'
                     else
                       "#{total_book_loan_count} #{total_book_loan_count >= 1 ? 'Books' : 'Book'} has been loaned successfully"
                     end,
          "data": circulations
        }
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                @current_library, true)

        present response
      end

      desc 'return of a circulation book'
      params do
        requires :barcodes, type: Array, allow_blank: false
        optional :staff_id, type: Integer
        optional :is_machine, type: Boolean, values: [true, false], allow_blank: false
      end

      put 'return' do
        unless params[:is_machine].present?
          if params[:staff_id].blank?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:STAFF_ID_REQUIRED], error: 'Staff id required' },
                                    @current_library, false)
            present failed_response('Staff id required', HTTP_CUSTOM_CODE[:STAFF_ID_REQUIRED], [])
            next
          end
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:STAFF_NOT_FOUND], error: 'Staff not found' },
                                    @current_library, false)
            present failed_response('Staff not found', HTTP_CUSTOM_CODE[:STAFF_NOT_FOUND], [])
            next
          end
        end
        circulations = []
        total_book_return_count = 0
        params[:barcodes].each do |barcode|
          is_external_circulation = false
          biblio_item = BiblioItem.find_by(barcode:)

          unless biblio_item.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:BIBLIO_ITEM_NOT_FOUND], error: "Biblio Item not found for the barcode: #{barcode}" },
                                    @current_library, false)

            circulations << {
              "success": false,
              "status_code": HTTP_CUSTOM_CODE[:BIBLIO_ITEM_NOT_FOUND],
              "message": "Biblio Item not found for the barcode: #{barcode}"
            }
            next
          end

          circulation = Circulation.where(biblio_item_id: biblio_item.id).last
          unless circulation.present?
            circulation = Circulation.find_by(biblio_item_id: biblio_item.id)
            is_external_circulation = true if circulation.present?
          end

          unless circulation.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:BOOK_NOT_IN_CIRCULATION], error: 'Book not found in circulation' },
                                    @current_library, false)
            circulations << {
              "success": false,
              "status_code": HTTP_CUSTOM_CODE[:BOOK_NOT_IN_CIRCULATION],
              "accession_number": biblio_item.accession_no,
              "title": biblio_item.biblio.title.titleize,
              "message": 'Book not found in circulation'
            }
            next
          end


          if circulation.circulation_status.returned? && circulation.returned_at.present?

            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:BOOK_ALREADY_RETURNED], error: 'Book already returned' },
                                    @current_library, false)

            circulations << {
              "success": false,
              "status_code": HTTP_CUSTOM_CODE[:BOOK_ALREADY_RETURNED],
              "accession_number": biblio_item.accession_no,
              "title": biblio_item.biblio.title.titleize,
              "message": 'Book already returned'
            }
            next
          elsif !circulation.circulation_status.borrowed?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:NOT_IN_BORROWED_LIST], error: 'This book not found in your borrowed list' },
                                    @current_library, false)

            circulations << {
              "success": false,
              "status_code": HTTP_CUSTOM_CODE[:NOT_IN_BORROWED_LIST],
              "accession_number": biblio_item.accession_no,
              "title": biblio_item.biblio.title.titleize,
              "message": 'This book not found in your borrowed list'
            }
            next
          end
          if is_external_circulation
            # Create Return Ciculation Transfer
            return_circulation_status = ReturnCirculationStatus.get_status(ReturnCirculationStatus.status_keys[:pending])
            return_circulation_transfer = ReturnCirculationTransfer.find_or_create_by!(circulation_id: circulation.id,
                                                                                       biblio_item_id: circulation.biblio_item_id,
                                                                                       user_id: circulation.member.user.id,
                                                                                       sender_library_id: @current_library.id,
                                                                                       receiver_library_id: circulation.library_id,
                                                                                       return_circulation_status_id: return_circulation_status.id,
                                                                                       created_by: params[:is_machine].present? ? nil : staff)
          end
          circulation.update!(circulation_status: CirculationStatus.get_status(:returned),
                              returned_at: DateTime.current,
                              updated_by: params[:is_machine].present? ? nil : staff,
                              is_machine: params[:is_machine].present?)

          circulations << {
            "success": true,
            "due_date": circulation.return_at,
            "status_code": HTTP_CODE[:OK],
            "accession_number": biblio_item.accession_no,
            "title": biblio_item.biblio.title.titleize,
            "message": 'Book has been returned successfully'
          }
          total_book_return_count += 1
        end
        LmsLogJob.perform_later(request.headers.merge(params:),
                                { status_code: HTTP_CODE[:OK] },
                                staff, true)
        response = {
          "success": true,
          "status_code": HTTP_CODE[:OK],
          "message": if total_book_return_count.zero?
                       'No Book Returned'
                     else
                       "#{total_book_return_count} #{total_book_return_count >= 1 ? 'Books' : 'Book'} has been returned successfully"
                     end,
          "data": circulations
        }

        present response
      end

      route_param :id do
        desc 'details of a circulation book'
        get do
          circulation = @current_library.circulations.find_by(id: params[:id])
          unless circulation.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CUSTOM_CODE[:BIBLIO_NOT_FOUND], error: 'Biblio Not Found' },
                                    @current_library, false)
            error!('Biblio Not Found', HTTP_CUSTOM_CODE[:BIBLIO_NOT_FOUND])
          end

          Lms::Entities::Circulations.represent(circulation)
        end
      end
    end
  end
end
