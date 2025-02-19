# frozen_string_literal: true

module Admin
  class Memorandums < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::MemorandumParams

    resource :memorandums do

      desc 'Get dropdowns for memorandums'

      get 'dropdown' do
        memorandums = Memorandum.all.not_deleted
        Admin::Entities::MemorandumsDropdown.represent(memorandums.order(id: :desc))
      end


      desc 'Get a list of memorandums'
      params do
        use :pagination, per_page: 25
        optional :memorandum_no, type: String
        optional :tender_session, type: String, regexp: /\A[1-9]\d{3}-[1-9]\d{3}\z/
      end
      get do
        memorandums = Memorandum.all.not_deleted
        if params[:memorandum_no].present?
          memorandums = memorandums.not_deleted.where('lower(memorandum_no) LIKE ?',"%#{params[:memorandum_no].downcase}%")
        end
        if params[:tender_session].present?
          memorandums = memorandums.not_deleted.where('tender_session = ?', params[:tender_session])
        end
        authorize memorandums, :read?
        Admin::Entities::MemorandumsList.represent(memorandums.order(id: :desc))
      end


      desc 'Create a new memorandum'
      params do
        use :memorandum_create_params
      end
      post do
        if params[:description].nil? & params[:image_file].nil?
          error!('Description or Attachment of memorandum should not be empty', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        memorandum = Memorandum.new(declared(params, include_missing: false).merge(created_by_id: @current_staff.id))
        authorize memorandum, :create?
        Admin::Entities::Memorandums.represent(memorandum) if memorandum.save!
      end

      route_param :id do
        desc 'Get a single memorandum'
        get do
          memorandum = Memorandum.not_deleted.find_by(id: params[:id])
          error!('Memorandum Not Found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
          authorize memorandum, :read?
          Admin::Entities::Memorandums.represent(memorandum)
        end

        desc 'Update a memorandum'
        params do
          use :memorandum_update_params
        end
        put do
          memorandum = Memorandum.not_deleted.find_by(id: params[:id])
          error!('Memorandum Not Found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?

          if params[:description].nil? & params[:image_file].nil?
            error!('Description or Attachment of memorandum should not be empty', HTTP_CODE[:NOT_ACCEPTABLE]) unless memorandum.image.attached?
          end

          authorize memorandum, :update?
          memorandum.update!(declared(params, include_missing: false).merge(updated_by_id: @current_staff.id))
          Admin::Entities::Memorandums.represent(memorandum)
        end

        desc 'Delete a memorandum'
        delete do
          memorandum = Memorandum.not_deleted.find_by(id: params[:id])
          error!('Memorandum Not Found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
          authorize memorandum, :delete?
          memorandum.update!(is_deleted: true)
          Admin::Entities::Memorandums.represent(memorandum)
        end

        resources :memorandum_publishers do
          desc 'Memorandum publisher shorlist'

          params do
            use :memorandum_publisher_shortlist_params
          end

          put 'shortlist' do
            memorandum_publishers = []
            memorandum = Memorandum.not_deleted.find_by(id: params[:id])
            error!('Memorandum not found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
            ActiveRecord::Base.transaction do
              params[:memorandum_publisher_ids].each do |memorandum_publisher_id|
                memorandum_publisher = memorandum.memorandum_publishers.submitted.find_by(id: memorandum_publisher_id)
                unless memorandum_publisher.present?
                  error!('Memorandum publisher not found for the given memorandum', HTTP_CODE[:NOT_FOUND])
                end
                if memorandum_publisher.is_shortlisted
                  error!("Memorandum publisher: #{memorandum_publisher_id} is already shortlisted",
                         HTTP_CODE[:NOT_ACCEPTABLE])
                end
                authorize memorandum_publisher, :update?
                memorandum_publisher.update!(is_shortlisted: true)
                memorandum_publishers << memorandum_publisher
              end
            end
            Admin::Entities::MemorandumPublisherDetails.represent(memorandum_publishers)
          end
        end
      end
    end
  end
end
