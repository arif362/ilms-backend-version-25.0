module PublicLibrary
  class Complains < PublicLibrary::Base
    helpers PublicLibrary::QueryParams::ComplainParams
    resources :complains do
      desc 'Complains list'
      params do
        use :pagination, per_page: 25
      end
      get do
        error!('Only Users Can Get Complaint list.', HTTP_CODE[:NOT_FOUND]) unless @current_user.present?
        complains = @current_user.complains.all.order(id: :desc)
        error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless complains.present?
        PublicLibrary::Entities::Complains.represent(paginate(complains))
      end

      desc 'Create complain'
      params do
        use :complain_create_params
      end
      route_setting :authentication, optional: true
      post do
        if params[:complain_type] == 'library_issue'
          error!('Library must exists', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:library_id].present?
        end
        if @current_user.present?
          complain = Complain.create!(declared(params, include_missing: false).merge!(user_id: @current_user.id, action_type: :open))
        else
          complain = Complain.create!(declared(params, include_missing: false).merge!(action_type: :open))
        end
        error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless complain.present?
        PublicLibrary::Entities::ComplainDetails.represent(complain, locale: @locale)
      end

      route_param :id do
        desc 'complain details'
        get do
          error!('Only Users Can Get Complaint list.', HTTP_CODE[:NOT_FOUND]) unless @current_user.present?
          complain = @current_user.complains.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless complain.present?
          PublicLibrary::Entities::ComplainDetails.represent(complain, locale: @locale)
        end

        # desc 'complain update'
        # params do
        #   use :complain_update_params
        # end
        # put do
        #   error!('Only Users Can Get Complaint list.', HTTP_CODE[:NOT_FOUND]) unless @current_user.present?
        #   complain = @current_user.complains.find_by(id: params[:id])
        #   error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless complain.present?
        #   complain.update!(declared(params, include_missing: false))
        #   PublicLibrary::Entities::ComplainDetails.represent(complain, locale: @locale)
        # rescue StandardError => e
        #   Rails.logger.info("Failed to remove complain item - #{e.full_message}")
        #   error!(failure_response("Failed to remove complain item - #{e.message}"))
        # end
      end
    end
  end
end
