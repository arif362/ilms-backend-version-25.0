# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

module Admin
  class DistributionSentToLibrary
    include Interactor
    include PublicLibrary::Helpers::ImageHelpers

    delegate :distribution, :action_type, to: :context

    def call
      distribution_sent_to_library
    end

    private
    def user_able
      staff_id = @current_staff
      Staff.find_by(id: staff_id)
    end


    def access_token(library)
      data = Lms::AccessManagement.call(user_able:, library:)
      data[:token] if data.success?
    end

    def base_library

      Library.find_by(id: distribution&.library_id)
    end

    def distribution_sent_to_library

      return unless base_library.working_url?(base_library.ip_address)

      library_base_url = "#{base_library.ip_address}/api/library"
      url = if action_type == 'created'
              URI("#{library_base_url}/service/challan-received")
            elsif action_type == 'updated'
              URI("#{library_base_url}/service/challan-received-update/#{distribution.id}")
            end
      Rails.logger.info("action url: #{url}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = library_base_url.start_with?('https')
      request = action_type == 'created' ? Net::HTTP::Post.new(url) : Net::HTTP::Patch.new(url)
      request['Authorization'] = "Bearer #{access_token(base_library)}"
      request['Content-Type'] = 'application/json'
      request.body = JSON.dump(distribution_sent_to_library_params)
      response = https.request(request).read_body
      response = JSON.parse(response, symbolize_names: true)
      Rails.logger.info("LMS api response: #{response}")
      LmsLogJob.perform_later("body: #{request.body} #{request.to_json}",
                              response,
                              user_able,
                              response[:error] != true)

    end

    def distribution_sent_to_library_params
      if action_type == 'created'
        distribution_sent_to_library_create_params
      else
        distribution_status_update_params
      end
    end

    def distribution_sent_to_library_create_params
      {
        challan_id: distribution&.id,
        quantity: distribution&.item_count,
        challan_created_at: distribution&.created_at&.strftime('%Y-%m-%d'),
        item_info: item_info
      }
    end

    def distribution_status_update_params
      {
        status: distribution&.status
      }
    end

    def item_info
      publisher_biblio = distribution.department_biblio_items.pluck(:publisher_biblio_id).uniq
      item_info = []
      publisher_biblio.each do |publisher_biblio_item|

        publisher_biblio_item = PublisherBiblio.find_by(id: publisher_biblio_item)
        accession_numbers = distribution.department_biblio_items.pluck(:central_accession_no)

        item_info << {
          title: publisher_biblio_item&.title,
          author: publisher_biblio_item&.author_name,
          central_accession_no: accession_numbers.join(','),
          quantity: distribution&.department_biblio_items&.count
        }
      end
      item_info
    end
  end
end
