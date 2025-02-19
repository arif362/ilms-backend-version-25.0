module PublicLibrary
  class Base < Grape::API

    include Grape::Kaminari
    include ErrorHundle
    include Constants

    # Helpers to send success or failure message to frontend
    helpers Admin::QueryParams::StaffParams

    #############################
    # Prefix and Formatting
    #############################
    format :json
    prefix :public_library
    formatter :json, Grape::Formatter::Json

    #############################
    # Authorization
    #############################
    before do
      ActiveStorage::Current.host = request.base_url
      auth_optional = route&.settings&.dig(:authentication, :optional)
      if auth_optional
        auth_key = verify_auth_key
        if auth_key.present? && auth_key.authable_type == 'User' && !auth_key.expired? && auth_key.authable.is_active?
          @current_user = auth_key.authable
        else
          Rails.logger.info 'Authentication optional for this endpoint'
        end
      else
        error!('401 Unauthorized', 401) unless authenticated!
      end
      set_language unless request.post? || request.patch? || request.put?
      set_request_source
      set_audited_user
      set_user_agent
    end

    helpers do
      def authenticated!
        Rails.logger.error "Token: #{bearer_token}  and user-agent: #{set_user_agent}"
        auth_key = verify_auth_key
        if auth_key.present? && !auth_key.expired? && auth_key.authable.is_active?
          @current_user = auth_key.authable
        else
          error!('Unauthorized', 401)
        end
      rescue StandardError => e
        Rails.logger.error "Authentication failed due to: #{e.message}"
        error!('Unauthorized', 401)
      end

      def bearer_token
        request.headers.fetch('Authorization', '').split(' ').last
      end

      def set_audited_user
        Audited.store[:audited_user] = @current_user
      end

      def set_language
        @locale = extract_language == 'en' ? :en : :bn
        I18n.locale = @locale
      end

      def set_user_agent
        @request_user_agent = request.headers.fetch('User-Agent')
      end

      def extract_language
        request.headers.fetch('Accept-Language', '').split(' ').last
      end

      def set_request_source
        @request_source = extract_host == 'app' ? :app : :web
      end

      def extract_host
        request.headers.fetch('Request-Source', '').split(' ').last
      end

      def extract_server_side_agent
        request.headers.fetch('Agent-From', '').split(' ').last
      end

      # For handling the server side rendering from frontend this method is implemented
      def verify_auth_key
        if extract_server_side_agent == 'server'
          AuthorizationKey.find_by(token: bearer_token)
        else
          AuthorizationKey.find_by(
            token: bearer_token, user_agent: set_user_agent
          )
        end
      end
    end

    #############################
    # API Mounts with Grape
    #############################
    mount PublicLibrary::Users
    mount PublicLibrary::Otps
    mount PublicLibrary::MembershipRequests
    mount PublicLibrary::Pages
    mount PublicLibrary::Biblios
    mount PublicLibrary::Carts
    mount PublicLibrary::Orders
    mount PublicLibrary::Biblios
    mount PublicLibrary::Libraries
    mount PublicLibrary::Wishlists
    mount PublicLibrary::KeyPeople
    mount PublicLibrary::Notifications
    mount PublicLibrary::PageBanners
    mount PublicLibrary::HomepageSliders
    mount PublicLibrary::GalleryAlbums
    mount PublicLibrary::Notices
    mount PublicLibrary::Complains
    mount PublicLibrary::Members
    mount PublicLibrary::Events
    mount PublicLibrary::Districts
    mount PublicLibrary::Divisions
    mount PublicLibrary::Thanas
    mount PublicLibrary::PageTypes
    mount PublicLibrary::SavedAddresses
    mount PublicLibrary::BiblioSubjects
    mount PublicLibrary::LibraryCards
    mount PublicLibrary::Circulations
    mount PublicLibrary::RequestedBiblios
    mount PublicLibrary::UserQrCodes
    mount PublicLibrary::Faqs
    mount PublicLibrary::FaqCategories
    mount PublicLibrary::ReturnOrders
    mount PublicLibrary::SecurityMoneyRequests
    mount PublicLibrary::Payments
    mount PublicLibrary::BiblioAuthors
    mount PublicLibrary::PhysicalReviews
    mount PublicLibrary::BiblioItems
    mount PublicLibrary::Newspapers
    mount PublicLibrary::Reviews
    mount PublicLibrary::BookTransferOrders
    mount PublicLibrary::Search
    mount PublicLibrary::Publishers
    mount PublicLibrary::Memorandums
    mount PublicLibrary::MemorandumPublishers
    mount PublicLibrary::PublisherBiblios
    mount PublicLibrary::ExtendRequests
    mount PublicLibrary::IntlResearchGateways
    mount PublicLibrary::EventRegistrations
    mount PublicLibrary::SuggestedBiblios
    mount PublicLibrary::Ebooks
    mount PublicLibrary::DeliveryAreas
  end
end
