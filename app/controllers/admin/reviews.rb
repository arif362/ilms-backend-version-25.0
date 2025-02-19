module Admin
  class Reviews < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resources :reviews do
      desc 'Reviews List'
      params do
        use :pagination, max_per_page: 25
        optional :status, type: String, values: Review.statuses.keys, allow_blank: false
      end

      get do
        reviews = Review.all
        authorize reviews, :read?
        reviews = reviews.where(status: params[:status]) if params[:status].present?
        reviews = reviews.order(id: :desc)
        Admin::Entities::Reviews.represent(paginate(reviews))
      end

      route_param :id do
        desc 'Review Accept Reject'
        params do
          requires :status, type: String, values: Review.statuses.keys, allow_blank: false
        end
        post 'accept_reject' do
          review = Review.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless review.present?
          authorize review, :accept_reject?
          error!('Not a pending review to accept/reject', HTTP_CODE[:UNPROCESSABLE_ENTITY]) unless review.pending?

          review.update!(declared(params))
          Admin::Entities::Reviews.represent(review)
        end
      end
    end
  end
end
