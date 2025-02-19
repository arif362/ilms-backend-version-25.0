module Admin
  class Libraries < Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::LibraryParams

    resource :libraries do
      desc 'Return list of libraries'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
      end
      get do
        libraries = Library.all.includes([:thana])
        if params[:search_term].present?
          search_term = params[:search_term].downcase
          libraries = libraries.where('lower(name) like :q OR lower(code) like :q ', q: "%#{search_term}%")
        end

        authorize libraries, :read?
        Admin::Entities::Libraries.represent(paginate(libraries.order(id: :desc)))
      end

      desc 'Get all libraries for dropdown.'
      get 'dropdown' do
        libraries = Library.order(id: :desc)
        authorize libraries, :skip?
        Admin::Entities::LibraryDropdown.represent(libraries)
      end

      desc 'list of library wise borrowed book'
      params do
        use :pagination, per_page: 25
        optional :library_code
      end
      get 'currently_borrowed' do
        circulation_status = CirculationStatus.get_status(CirculationStatus.status_keys[:borrowed])
        error!('Invalid status', HTTP_CODE[:NOT_ACCEPTABLE]) unless circulation_status.present?
        libraries = Library.all.order(current_borrow_count: :desc)
        if params[:library_code].present?
          library = Library.find_by(code: params[:library_code])
          error!('Library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          libraries = libraries.where(id: library.id)
        end
        authorize libraries, :read?
        Admin::Entities::LibraryCurrentBorrowList.represent(paginate(libraries))
      end

      desc 'list of library wise returned book'
      params do
        use :pagination, per_page: 25
        optional :library_code
      end
      get 'returned' do
        circulation_status = CirculationStatus.get_status(CirculationStatus.status_keys[:returned])
        error!('Invalid status', HTTP_CODE[:NOT_ACCEPTABLE]) unless circulation_status.present?
        libraries = Library.all
        if params[:library_code].present?
          library = Library.find_by(code: params[:library_code])
          error!('Library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          libraries = libraries.where(id: library.id)
        end
        authorize libraries, :read?
        Admin::Entities::LibraryBiblioReturnList.represent(paginate(libraries), circulation_status: circulation_status)
      end

      route_param :id do
        desc 'Details of a library'
        get do
          library = Library.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          authorize library, :read?

          Admin::Entities::LibraryDetails.represent(library)
        end

        desc 'Update library'
        params do
          use :library_update_params
        end
        put do
          library = Library.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          authorize library, :update?
          if params[:is_default_working_days] == false
            unless params[:library_working_days_attributes].blank?
              params[:library_working_days_attributes].each do |library_working_day|
                if library.is_default_working_days == false && library_working_day[:id].blank?
                  error!('Provide ID to update value', HTTP_CODE[:NOT_ACCEPTABLE])
                end
                if library_working_day[:is_holiday]
                  library_working_day.update(start_time: '', end_time: '')
                  library_working_day.update(updated_by_id: @current_staff.id)
                  next

                end
                if library_working_day[:start_time] && !valid_time_format?(library_working_day[:start_time])
                  error!("Invalid start time format (e.g., 'HH:mm')", HTTP_CODE[:NOT_ACCEPTABLE])
                end
                if library_working_day[:end_time] && !valid_time_format?(library_working_day[:end_time])
                  error!("Invalid end time format (e.g., 'HH:mm')", HTTP_CODE[:NOT_ACCEPTABLE])
                end
                library_working_day.update(updated_by_id: @current_staff.id)
              end
            end
          else
            params.update(library_working_days_attributes: []) if params[:library_working_days_attributes].present?
          end

          library.update!(declared(params.except(:current_password), include_missing: false).merge!(updated_by: @current_staff.id))
          Admin::Entities::LibraryDetails.represent(library)
        end

        desc 'Library Password Change'
        params do
          use :library_password_change_params
        end

        put :change_password do
          library = Library.find_by(id: params[:id])
          if library.password != params[:current_password]
            error!('Current password is incorrect', HTTP_CODE[:BAD_REQUEST])
          end
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) if library.blank?
          authorize library, :change_password?
          library.update!(declared(params, include_missing: false).merge(updated_by: @current_staff.id).except(:current_password))

        end


        desc 'Library ip Change'
        params do
          use :library_ip_change_params
        end
        put :change_ip do
          error!('IP format is not valid', HTTP_CODE[:NOT_ACCEPTABLE]) unless ip_validation(params[:ip_address])
          library = Library.find_by(id: params[:id])
          error!('Library Not Found', HTTP_CODE[:NOT_FOUND]) if library.blank?
          if library.password != params[:password] || library.ip_address != params[:current_ip]
            error!('password or current_ip is incorrect', HTTP_CODE[:BAD_REQUEST])
          end
          authorize library, :change_ip?
          library.update!(declared(params, include_missing: false).merge(updated_by: @current_staff.id).except(:current_ip, :password))

        end

        desc 'Remove library image'
        params do
          use :library_remove_image_params
        end
        delete 'remove_image' do
          library = Library.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          authorize library, :delete?
          library_image = library.images.find_by(id: params[:image_id])
          error!('Image Not Found', HTTP_CODE[:NOT_FOUND]) unless library_image.present?
          library_image.purge
          library.update!(updated_by: @current_staff.id)
          Admin::Entities::LibraryDetails.represent(library)
        end

        desc 'details of library wise borrowed book'
        params do
          use :pagination, per_page: 25
        end
        get 'currently_borrowed' do
          library = Library.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          authorize library, :read?
          Admin::Entities::LibraryCirculationDetails.represent(library)
        end

        desc 'details of library wise borrowed book'
        params do
          use :pagination, per_page: 25
        end
        get 'returned' do
          library = Library.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          authorize library, :read?
          Admin::Entities::LibraryCirculationDetails.represent(library, returned: true)
        end
      end

      desc 'create a new library'

      params do
        use  :library_create_params
      end

      post do
        districts = District.not_deleted.find_by(id: params[:district_id])

        thana = districts.thanas.not_deleted.find_by(id: params[:thana_id])
        error!("Thana not found under district #{districts.name}", HTTP_CODE[:NOT_FOUND]) unless thana.present?
        library = Library.new(declared(params, include_missing: false)
                                .merge(created_by: @current_staff.id, updated_by: @current_staff.id))

        authorize library, :create?

        if params[:is_default_working_days] == false
          unless params[:library_working_days_attributes].blank?
            total_week_days = params[:library_working_days_attributes].map { |hash| hash[:week_days] }
            unless (total_week_days.uniq == total_week_days) && total_week_days.length == 7
              error!('Please provide value for seven days', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end

          library.library_working_days.each do |library_working_day|
            if library_working_day[:is_holiday]
              library_working_day.update(start_time: '', end_time: '')
            else
              if library_working_day[:start_time] && !valid_time_format?(library_working_day[:start_time])
                error!("Invalid start time format (e.g., 'HH:mm')", HTTP_CODE[:NOT_ACCEPTABLE])
              end
              if library_working_day[:end_time] && !valid_time_format?(library_working_day[:end_time])
                error!("Invalid end time format (e.g., 'HH:mm')", HTTP_CODE[:NOT_ACCEPTABLE])
              end
            end
            library_working_day.update(created_by_id: @current_staff.id)
          end
        elsif params[:library_working_days_attributes].present?
          params.update(library_working_days_attributes: [])
        end
        Admin::Entities::LibraryDetails.represent(library) if library.save!
      end
    end
    helpers do
      def ip_validation(ip)
         ip.split(':').last == '8000'
      end
    end
  end
end

