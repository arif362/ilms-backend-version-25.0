# frozen_string_literal: true

module Lms::Helpers
  module ErrorHundle
    extend ActiveRecord::Associations
    extend ActiveSupport::Concern
    included do

      rescue_from ::Faraday::ConnectionFailed  do |exception|
        Rails.logger.error "Faraday::ConnectionFailed :  #{exception.full_message}"
        error!("Don't Worry !! Your expected record has been created and Faraday::ConnectionFailed :  #{exception.message}. But your global search will not work for this record", Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok])
      end

      rescue_from ::Grape::Exceptions::MethodNotAllowed do |exception|
        Rails.logger.error "Grape exception errors for not allowed :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Grape exception errors for not allowed'",
                                'Method not allowed, Please check your http method',
                                nil,
                                false)
        error!('Method not allowed, Please check your http method', Rack::Utils::SYMBOL_TO_STATUS_CODE[:method_not_allowed])
      end

      rescue_from ::Grape::Exceptions::ValidationErrors do |exception|
        Rails.logger.error "Grape exception errors :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Grape exception errors'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:bad_request])
      end

      rescue_from ::Pundit::NotAuthorizedError do |exception|
        Rails.logger.error "Access right issue :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Access right issue'",
                                'No access',
                                nil,
                                false)
        error!('No access', Rack::Utils::SYMBOL_TO_STATUS_CODE[:forbidden])
      end

      rescue_from ::Pundit::NotDefinedError do |exception|
        Rails.logger.error "Access right issue :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Access right issue'",
                                'No access',
                                nil,
                                false)
        error!('No access', Rack::Utils::SYMBOL_TO_STATUS_CODE[:forbidden])
      end

      rescue_from ::ActiveRecord::RecordInvalid do |exception|
        Rails.logger.error "Active record validation issue :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Active record validation issue'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:bad_request])
      end

      rescue_from ::ActiveRecord::RecordNotSaved do |exception|
        Rails.logger.error "Active record record not saved :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Active record record not saved'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity])
      end

      rescue_from ::ActiveRecord::RecordNotFound do |exception|
        Rails.logger.error "Active record not found issue :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Active record not found issue'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:not_found])
      end

      rescue_from ::ActiveRecord::DeleteRestrictionError do |exception|
        Rails.logger.error "Active record delete restriction issue :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Active record delete restriction issue'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:bad_request])
      end

      rescue_from ActiveRecord::ValueTooLong do |exception|
        Rails.logger.error "Data range/limit over for too long value:  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Data range/limit over for too long value'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity])
      end

      rescue_from ::NoMethodError do |exception|
        Rails.logger.error "No method restriction issue :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'No method restriction issue'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:forbidden])
      end

      rescue_from ::Elasticsearch::Transport::Transport::Errors::NotFound do |exception|
        Rails.logger.error "Elastic Search not found error :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Elastic Search not found error'",
                                'Search result not found',
                                nil,
                                false)
        error!('Search result not found', Rack::Utils::SYMBOL_TO_STATUS_CODE[:not_found])
      end

      rescue_from ::RuntimeError do |exception|
        Rails.logger.error "Runtime error  :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Runtime error'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity])
      end

      rescue_from ::Exception do |exception|
        Rails.logger.error "Internal server error :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'Internal server error'",
                                'Internal server error',
                                nil,
                                false)
        error!('Internal server error', Rack::Utils::SYMBOL_TO_STATUS_CODE[:internal_server_error])
      end

      rescue_from ::JSON::ParserError do |exception|
        Rails.logger.error "Json parser error :  #{exception.full_message}"
        LmsLogJob.perform_later("body: 'json params from ils as expected'",
                                exception.message,
                                nil,
                                false)
        error!(exception.message, Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity])
      end
    end
  end
end
