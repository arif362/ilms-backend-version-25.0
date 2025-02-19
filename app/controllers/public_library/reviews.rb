module PublicLibrary
  class Reviews < PublicLibrary::Base
    resources :reviews do
      desc 'reviews'
      params do
        use :pagination, per_page: 25
      end
      get do
        reviews = @current_user.reviews.order(id: :desc)
        PublicLibrary::Entities::ReviewList.represent(paginate(reviews))
      end
    end
  end
end
