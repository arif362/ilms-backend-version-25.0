# frozen_string_literal: true

module PublicLibrary
  class PhysicalReviews < PublicLibrary::Base

    resources :physical_reviews do
      helpers PublicLibrary::QueryParams::PhysicalReviewParams
      desc 'physical review List created by user'

      get do
        physical_reviews = @current_user.physical_reviews.order(id: :desc)
        PublicLibrary::Entities::PhysicalReviews.represent(physical_reviews)
      end

      desc 'physical review create'

      params do
        use :physical_reviews_create_params
      end
      post do
        biblio_item = BiblioItem.find_by(barcode: params[:barcode])
        error!('biblio_item not found', HTTP_CODE[:NOT_FOUND]) unless biblio_item.present?

        physical_review = biblio_item.physical_reviews.create!(
          user_id: @current_user.id,
          review_body: params[:review_body],
          book_image_file: params[:book_image_file],
          library_id: biblio_item.library_id
        )

        PublicLibrary::Entities::PhysicalReviewDetails.represent(physical_review)
      end

      route_param :id do
        get do
          physical_review = PhysicalReview.find_by(id: params[:id])
          error!('physical review not fount', HTTP_CODE[:NOT_FOUND]) unless physical_review.present?
          PublicLibrary::Entities::PhysicalReviewDetails.represent(physical_review)
        end
      end
    end
  end
end
