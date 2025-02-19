# frozen_string_literal: true

module Lms
  class Thanas < Lms::Base
    helpers Lms::QueryParams::ThanaParams

    resources :thanas do
      desc 'Thanas dropdown List'
      params do
        requires :district_id, type: Integer
      end
      get 'dropdown' do
        district = District.not_deleted.find_by(id: params[:district_id])
        unless district.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'District not found' },
                                  @current_library, false)
          error!('District not found', HTTP_CODE[:NOT_FOUND])
        end
        thanas = district.thanas.not_deleted.order(name: :asc)
        Lms::Entities::ThanaDropdown.represent(thanas)
      end

      desc 'Thanas List'

      params do
        optional :district_id, type: Integer
        optional :name, type: String
      end

      get do
        thanas = if params[:district_id].present?
                   district = District.not_deleted.find_by(id: params[:district_id])
                   error!('District not found', HTTP_CODE[:NOT_FOUND]) unless district.present?
                   district.thanas.not_deleted
                 else
                   Thana.not_deleted
                 end
        thanas.where("lower(name) LIKE ?", "%#{params[:name].downcase}%").order(name: :asc) if params[:name].present?
        Lms::Entities::Thanas.represent(thanas.order(name: :asc))
      end

      desc 'Thana Create'
      params do
        use :thana_create_params
      end
      post do
        district = District.not_deleted.find_by(id: params[:district_id])
        unless district.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'District not found' },
                                  @current_library, false)
          error!('District not found', HTTP_CODE[:NOT_FOUND])
        end
        thana = Thana.new(declared(params, include_missing: false))
        if thana.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          Lms::Entities::Thanas.represent(thana)
        end
      end

      route_param :id do
        desc 'Thana Details'

        get do
          thana = Thana.not_deleted.find_by(id: params[:id])
          unless thana.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Thana not found' },
                                    @current_library, false)
            error!('Thana not found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::Thanas.represent(thana)
        end

        desc 'Thana Update'

        params do
          use :thana_update_params
        end

        put do
          thana = Thana.not_deleted.find_by(id: params[:id])
          unless thana.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Thana not found' },
                                    @current_library, false)
            error!('Thana not found', HTTP_CODE[:NOT_FOUND])
          end
          district = District.not_deleted.find_by(id: params[:district_id])
          unless district.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'District not found' },
                                    @current_library, false)
            error!('District not found', HTTP_CODE[:NOT_FOUND])
          end
          if thana.update!(declared(params, include_missing: false))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::Thanas.represent(thana)
          end
        end

        desc 'Thana Delete'

        patch do
          thana = Thana.not_deleted.find_by(id: params[:id])
          unless thana.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Thana not found' },
                                    @current_library, false)
            error!('Thana not found', HTTP_CODE[:NOT_FOUND])
          end
          if thana.update!(is_deleted: true)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::Thanas.represent(thana)
          end
        end
      end
    end
  end
end
