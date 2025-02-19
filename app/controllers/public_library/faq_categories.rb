# frozen_string_literal: true

module PublicLibrary
  class FaqCategories < PublicLibrary::Base
    resources :faq_categories do
      desc 'faq categories List'
      route_setting :authentication, optional: true
      get 'dropdown' do
        faq_categories = FaqCategory.all
        PublicLibrary::Entities::FaqCategories.represent(faq_categories.order(id: :desc), locale: @locale)
      end
    end
  end
end
