module Admin
  class Base < Grape::API
    include Pundit::Authorization
    include Grape::Kaminari
    include ErrorHundle
    include Constants

    # Helpers to check formats of the params
    helpers Admin::Helpers::FormatHelpers

    #############################
    # Prefix and Formatting
    #############################
    format :json
    prefix :admin
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
        if auth_key.present? && auth_key.authable_type == 'Staff' && !auth_key.expired? && auth_key.authable.is_active?
          @current_staff = auth_key.authable
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
        Audited.store[:audited_user] = @current_staff
      end

      def current_user
        @current_staff
      end
    end

    #############################
    # API Mounts with Grape
    #############################
    mount Admin::StaffAuth
    mount Admin::Libraries
    mount Admin::Roles
    mount Admin::Staffs
    mount Admin::Designations
    mount Admin::Users
    mount Admin::Members
    mount Admin::LibraryEntryLogs
    mount Admin::MembershipRequests
    mount Admin::Pages
    mount Admin::Biblios
    mount Admin::Reviews
    mount Admin::Orders
    mount Admin::KeyPeople
    mount Admin::HomepageSliders
    mount Admin::PageBanners
    mount Admin::GalleryAlbums
    mount Admin::Notices
    mount Admin::Complains
    mount Admin::Events
    mount Admin::PageTypes
    mount Admin::BiblioSubjects
    mount Admin::LibraryCards
    mount Admin::Circulations
    mount Admin::Payments
    mount Admin::RequestedBiblios
    mount Admin::Faqs
    mount Admin::FaqCategories
    mount Admin::LostDamagedBiblios
    mount Admin::SecurityMoneys
    mount Admin::SecurityMoneyRequests
    mount Admin::NotifyAnnounce
    mount Admin::Districts
    mount Admin::Divisions
    mount Admin::Thanas
    mount Admin::CardStatuses
    mount Admin::OrderStatuses
    mount Admin::DocumentCategories
    mount Admin::Documents
    mount Admin::Newspapers
    mount Admin::PhysicalReviews
    mount Admin::FailedSearches
    mount Admin::ThirdPartyUsers
    mount Admin::DeletionRequests
    mount Admin::BookTransferOrders
    mount Admin::LibraryTransferOrders
    mount Admin::RebindBiblios
    mount Admin::Dashboards
    mount Admin::Passwords
    mount Admin::Memorandums
    mount Admin::Publishers
    mount Admin::MemorandumPublishers
    mount Admin::LibraryWorkingDays
    mount Admin::PurchaseOrders
    mount Admin::LmsReports
    mount Admin::EditedLogs
    mount Admin::ReceivedBooks
    mount Admin::IntlResearchGateways
    mount Admin::IlsReports
    mount Admin::BiblioAuthors
    mount Admin::BiblioPublications
    mount Admin::LibraryLocations
    mount Admin::BiblioEditions
    mount Admin::BiblioStatuses
    mount Admin::BiblioClassificationSources
    mount Admin::Collections
    mount Admin::BiblioItemTypes
    mount Admin::ReportApa
    mount Admin::PublisherBiblios
    mount Admin::Notifications
    mount Admin::DepartmentBiblioItems
    mount Admin::Distributions
    mount Admin::Ebooks
    mount Admin::BiblioItems
    mount Admin::DeliveryAreas
  end
end
