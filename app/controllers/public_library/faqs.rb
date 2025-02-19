# frozen_string_literal: true

module PublicLibrary
  class Faqs < PublicLibrary::Base
    resources :faqs do
      desc 'faq List'
      params do
        use :pagination, per_page: 25
        optional :faq_category_title, type: String
      end
      route_setting :authentication, optional: true
      get do
        faqs = Faq.published.all
        if params[:faq_category_title].present?
          faq_category = FaqCategory.find_by('title = :search_title or bn_title = :search_title ', search_title: params[:faq_category_title])
          error!('FAQ category not found', HTTP_CODE[:NOT_FOUND]) unless faq_category.present?

          faqs = faqs.where(faq_category_id: faq_category.id)
        end
        PublicLibrary::Entities::Faqs.represent(paginate(faqs.order(position: :asc)), locale: @locale)
      end
    end
  end
end
