# frozen_string_literal: true

module PublicLibrary
  class UserQrCodes < PublicLibrary::Base
    resources :user_qr_codes do
      helpers PublicLibrary::QueryParams::UserQrCodesParams
      desc 'create qr code for user'
      params do
        use :user_qr_code_create_params
      end
      route_setting :authentication, optional: true
      post do
        library = Library.find_by(code: params[:library_code])
        error!('Library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
        user_qr_code = UserQrCode.new(services: params[:services],
                                      library_id: library.id,
                                      user_id: @current_user&.id,
                                      expired_at: DateTime.now + 7.days,
                                      qr_code: SecureRandom.uuid)

        error!('Guest info is empty', HTTP_CODE[:NOT_FOUND]) if @current_user.blank? && params[:email].blank?

        if user_qr_code.save!
          unless @current_user.present?
            guest = Guest.create(library_id: library.id, name: params[:name], email: params[:email], gender: params[:gender],
                                 dob: params[:dob], phone: params[:phone])
          end
          LibraryEntryLog.create(library_id: library.id, entryable: @current_user.present? ? @current_user : guest,
                                 services: user_qr_code.services)

          PublicLibrary::Entities::UserQrCodes.represent(user_qr_code, locale: @locale)
        end
      end

      desc 'user qr code list'
      params do
        use :pagination, per_page: 25
      end
      route_setting :authentication, optional: true
      get do
        user_qr_code = @current_user.user_qr_codes.active.order(id: :desc)
        PublicLibrary::Entities::UserQrCodes.represent(paginate(user_qr_code), locale: @locale)
      end

      route_param :id do
        desc 'user qr code details'
        route_setting :authentication, optional: true
        get do
          user_qr_code = @current_user.user_qr_codes.active.find_by(id: params[:id])
          error!('QR code not found', HTTP_CODE[:NOT_FOUND]) unless user_qr_code.present?
          PublicLibrary::Entities::UserQrCodes.represent(user_qr_code, locale: @locale)
        end
      end
    end
  end
end
