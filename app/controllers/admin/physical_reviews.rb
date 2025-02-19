# frozen_string_literal: true

module Admin
  class PhysicalReviews < Admin::Base

    resources :physical_reviews do
      include Admin::Helpers::AuthorizationHelpers
      desc 'physical review List'

      params do
        use :pagination, per_page: 25
        optional :barcode, type: String
      end

      get do
        physical_reviews = if params[:barcode].present?
                             biblio_item_ids = BiblioItem.where('lower(barcode) LIKE ?', "%#{params[:barcode].downcase}%").pluck(:id)
                             PhysicalReview.where(biblio_item_id: biblio_item_ids).order(id: :desc)
                           else
                             PhysicalReview.order(id: :desc)
                           end
        authorize physical_reviews, :read?
        Admin::Entities::PhysicalReviews.represent(paginate(physical_reviews))
      end

      desc 'physical review details'

      route_param :id do

        get do
          physical_review = PhysicalReview.find_by(id: params[:id])
          error!('physical review not found', HTTP_CODE[:NOT_FOUND]) unless physical_review.present?
          authorize physical_review, :read?
          Admin::Entities::PhysicalReviewDetails.represent(physical_review)
        end

      end
    end
  end
end
