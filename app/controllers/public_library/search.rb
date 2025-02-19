# frozen_string_literal: true

module PublicLibrary
  class Search < PublicLibrary::Base
    helpers PublicLibrary::Helpers::FailedSearchHelper

    helpers do
      def elastic_json_to_suggestion_array(json, filter_topic)
        results = []
        if filter_topic == 'newspaper'
          json.each { |arr| results << arr['_source'].as_json(only: %i[id name]) }
        elsif filter_topic == 'album'
          json.each { |arr| results << arr['_source'].as_json(only: %i[id title slug album_type]) }
        else
          json.each { |arr| results << arr['_source'].as_json(only: %i[id title slug]) }
        end
        {
          filter_topic:,
          filter_results: results.flatten.compact.map
        }
      end

      def elastic_json_to_result_array(json, filter_topic)
        results = []
        json.each { |arr| results << arr['_source'].as_json(only: %i[id]) }
        filter_topic.classify.constantize.where(id: results.flatten.compact.map.pluck('id'))
      end
    end
    resources :search do
      desc 'search suggestion'
      params do
        use :pagination, per_page: 25
        optional :query, type: String
        requires :filter_with, type: String, values: %w[biblio event notice album newspaper]
      end
      route_setting :authentication, optional: true
      get '/suggestion' do
        query = params[:query] || ''
        result = []
        case params[:filter_with]
        when 'biblio'
          result = Biblio.search(query)
        when 'event'
          result = Event.search(query)
        when 'notice'
          result = Notice.search(query)
        when 'album'
          result = Album.search(query)
        when 'newspaper'
          result = Newspaper.search(query)
        else
          error!('Result Not found', HTTP_CODE[:NOT_FOUND])
        end

        elastic_json_to_suggestion_array(result&.response&.hits&.hits, params[:filter_with])
      end

      desc 'search list of result'
      params do
        use :pagination, per_page: 25
        optional :query, type: String
        requires :filter_with, type: String, values: %w[biblio event notice album newspaper]
      end
      route_setting :authentication, optional: true
      get '/list' do
        query = params[:query] || ''

        case params[:filter_with]
        when 'biblio'
          result = Biblio.search(query)
          add_failed_search(query) if query.present? && result.blank?
          elastic_result = elastic_json_to_result_array(result&.response&.hits&.hits, params[:filter_with])
          {
            filter_topic: params[:filter_with],
            filter_results: PublicLibrary::Entities::BiblioList.represent(paginate(elastic_result.order(id: :desc)),
                                                                          locale: @locale, request_source: @request_source,
                                                                          current_user: @current_user)
          }
        when 'event'
          result = Event.search(query)
          add_failed_search(query) if query.present? && result.blank?

          elastic_result = elastic_json_to_result_array(result&.response&.hits&.hits, params[:filter_with])
          {
            filter_topic: params[:filter_with],
            filter_results: PublicLibrary::Entities::Events.represent(paginate(elastic_result.order(id: :desc)),
                                                                      locale: @locale,
                                                                      request_source: @request_source)
          }

        when 'notice'
          result = Notice.search(query)
          add_failed_search(query) if query.present? && result.blank?
          elastic_result = elastic_json_to_result_array(result&.response&.hits&.hits, params[:filter_with])
          {
            filter_topic: params[:filter_with],
            filter_results: PublicLibrary::Entities::Notices.represent(paginate(elastic_result.order(id: :desc)),
                                                                       locale: @locale)
          }
        when 'album'
          result = Album.search(query)
          add_failed_search(query) if query.present? && result.blank?

          elastic_result = elastic_json_to_result_array(result&.response&.hits&.hits, params[:filter_with])
          {
            filter_topic: params[:filter_with],
            filter_results: PublicLibrary::Entities::Albums.represent(paginate(elastic_result.order(id: :desc)),
                                                                      locale: @locale,
                                                                      request_source: @request_source)
          }
        when 'newspaper'
          result = Newspaper.search(query)
          add_failed_search(query) if query.present? && result.blank?

          elastic_result = elastic_json_to_result_array(result&.response&.hits&.hits, params[:filter_with])
          {
            filter_topic: params[:filter_with],
            filter_results: PublicLibrary::Entities::Newspapers.represent(paginate(elastic_result.order(id: :desc)))
          }
        else
          {
            filter_topic: params[:filter_with],
            filter_results: []
          }
        end

      rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
        status HTTP_CODE[:OK]
        {
          filter_topic: params[:filter_with],
          filter_results: []
        }
      end
    end
  end
end
