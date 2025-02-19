# frozen_string_literal: true

module PublicLibrary
  class SuggestedBiblios < PublicLibrary::Base

    resources :suggested_biblios do
      desc 'user suggested biblios'
      params do
        optional :search_id, type: Integer, allow_blank: false
        optional :search_type, type: String, allow_blank: false, values: %w[Author BiblioSubject ItemType]
      end
      route_setting :authentication, optional: true
      get do
        suggested_biblios = {}
        if @current_user.present?
          biblio_ids = @current_user.suggested_biblios.order(points: :desc).first(6).pluck(:biblio_id)
          suggested_biblios = Biblio.where(id: biblio_ids)

        elsif params[:search_id].present? || params[:search_type].present?
          unless params[:search_id].present? && params[:search_type].present?
            suggested_biblios = []
          end
          unless suggested_biblios.blank?
            search_model = params[:search_type].constantize.find_by(id: params[:search_id])
            suggested_biblios = search_model.biblios.first(6) if search_model.present?
          end
        end

        if suggested_biblios.blank?
          trending_point = ENV['TRENDING_THRESHOLD'].to_i
          suggested_biblios = Biblio.where('biblios.read_count >= :trending_point or
                                            biblios.borrow_count >= :trending_point', trending_point:).distinct.first(6)
        end
        error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless suggested_biblios.present?
        PublicLibrary::Entities::BiblioList.represent(suggested_biblios,
                                                      locale: @locale, request_source: @request_source,
                                                      current_user: @current_user)
      end
    end
  end
end
