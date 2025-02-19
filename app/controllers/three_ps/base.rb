module ThreePs
  class Base < Grape::API
    include Grape::Kaminari
    include ErrorHundle
    include Constants


    #############################
    # Prefix and Formatting
    #############################
    format :json
    prefix :three_ps
    formatter :json, Grape::Formatter::Json

    #############################
    # Authorization
    #############################
    before do
      ActiveStorage::Current.host = request.base_url
      auth_optional = route&.settings&.dig(:authentication, :optional)
      if auth_optional
        # allow guest users if the endpoint specifies so
        Rails.logger.info 'Authentication optional for this endpoint'
      else
        error!('Unauthorized', HTTP_CODE[:UNAUTHORIZED]) unless authenticated!
      end
      set_audited_user
    end

    helpers do
      def authenticated!
        auth_key = AuthorizationKey.find_by(token: bearer_token)
        if auth_key.present? && !auth_key.expired? && auth_key.authable.is_active?
          @current_user = auth_key.authable
        else
          error!('Unauthorized', HTTP_CODE[:UNAUTHORIZED])
        end
      rescue StandardError => e
        Rails.logger.error "Authentication failed due to: #{e.message}"
        error!('Unauthorized', HTTP_CODE[:UNAUTHORIZED])
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_user
      end

    end

    #############################
    # API Mounts with Grape
    #############################
    mount ThreePs::ReturnOrders
    mount ThreePs::ThirdPartyUsers
    mount ThreePs::Orders
    mount ThreePs::LibraryCards
    mount ThreePs::Biblios

  end
end
