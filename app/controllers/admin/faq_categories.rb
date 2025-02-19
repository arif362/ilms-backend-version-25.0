# frozen_string_literal: true

module Admin
  class FaqCategories < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::FaqCategoryParams

    resources :faq_categories do
      desc 'FAQ Categories List'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
      end

      get do
        faq_categories = FaqCategory.all
        if params[:search_term].present?
          faq_categories = faq_categories.where('lower(title) LIKE :search_name or lower(bn_title) LIKE :search_name', search_name: "%#{params[:search_term].downcase}%")
        end
        authorize faq_categories, :read?
        Admin::Entities::FaqCategories.represent(paginate(faq_categories.order(id: :desc)))
      end

      desc 'FAQ Category create'
      params do
        use :faq_category_create_params
      end

      post do
        faq_category = FaqCategory.new(declared(params, include_missing: false).merge!(created_by_id: @current_staff.id))
        authorize faq_category, :create?
        Admin::Entities::FaqCategories.represent(faq_category) if faq_category.save!
      end

      route_param :id do
        desc 'FAQ category details'
        get do
          faq_category = FaqCategory.find_by(id: params[:id])
          error!('FAQ category not found', HTTP_CODE[:NOT_FOUND]) unless faq_category.present?
          authorize faq_category, :read?
          Admin::Entities::FaqCategories.represent(faq_category)
        end

        desc 'FAQ category update'
        params do
          use :faq_category_update_params
        end
        put do
          faq_category = FaqCategory.find_by(id: params[:id])
          error!('FAQ category not found', HTTP_CODE[:NOT_FOUND]) unless faq_category.present?
          authorize faq_category, :update?
          faq_category.update!(declared(params, include_missing: false).merge!(updated_by_id: @current_staff.id))
          Admin::Entities::FaqCategories.represent(faq_category)
        end

        desc 'FAQ category delete'
        delete do
          faq_category = FaqCategory.find_by(id: params[:id])
          error!('FAQ category not found', HTTP_CODE[:NOT_FOUND]) unless faq_category.present?
          authorize faq_category, :delete?
          faq_category.destroy!
          {
            message: 'Successfully deleted'
          }
        end
      end
    end
  end
end
