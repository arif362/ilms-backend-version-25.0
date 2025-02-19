# frozen_string_literal: true

module Lms
  class Base < Grape::API
    include Grape::Kaminari
    include Lms::Helpers::ErrorHundle
    include Constants

    #############################
    # Prefix and Formatting
    #############################
    format :json
    prefix :lms
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
          @current_library = auth_key.authable
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
        Audited.store[:audited_user] = @current_library
      end

      def current_user
        @current_library
      end
    end

    #############################
    # API Mounts with Grape
    #############################
    mount Lms::Libraries
    mount Lms::Guests
    mount Lms::LibraryEntryLogs
    mount Lms::Biblios
    mount Lms::MembershipRequests
    mount Lms::Orders
    mount Lms::LibraryCards
    mount Lms::Events
    mount Lms::LibraryCards
    mount Lms::BiblioSubjects
    mount Lms::Circulations
    mount Lms::LostDamagedBiblios
    mount Lms::BiblioEditions
    mount Lms::BiblioClassificationSources
    mount Lms::BiblioAuthors
    mount Lms::BiblioPublications
    mount Lms::SecurityMoneyRequests
    mount Lms::ReturnOrders
    mount Lms::LibraryLocations
    mount Lms::ItemTypes
    mount Lms::Payments
    mount Lms::GalleryAlbums
    mount Lms::NewspaperRecords
    mount Lms::BookTransferOrders
    mount Lms::Staffs
    mount Lms::RebindBiblios
    mount Lms::BorrowPolicies
    mount Lms::Collections
    mount Lms::Otps
    mount Lms::Patrons
    mount Lms::BiblioStatuses
    mount Lms::Divisions
    mount Lms::Districts
    mount Lms::Thanas
    mount Lms::RequestedBiblios
    mount Lms::Divisions
    mount Lms::Districts
    mount Lms::Thanas
    mount Lms::LibraryTransferOrders
    mount Lms::ExtendRequests
    mount Lms::IntLibExtensions
    mount Lms::Users
    mount Lms::PhoneChangeRequests
    mount Lms::LmsReports
    mount Lms::EventRegistrations
    mount Lms::Passwords
    mount Lms::Distributions
    mount Lms::Members
    mount Lms::DeliveryAreas
  end
end
