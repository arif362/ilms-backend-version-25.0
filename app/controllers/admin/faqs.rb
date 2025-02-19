# frozen_string_literal: true

module Admin
  class Faqs < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::FaqParams

    resources :faqs do
      desc 'FAQ List'
      params do
        use :pagination, max_per_page: 25
        optional :search_term, type: String
        optional :faq_category_id, type: Integer
        optional :status, type: String, values: %w[published unpublished]
        optional :position, type: Integer, values: { value: ->(v) { v.positive? },
                                                     message: 'must be greater than zero' }
      end

      get do
        faqs = Faq.all
        authorize faqs, :read?
        faqs = faqs.where(faq_category_id: params[:faq_category_id]) if params[:faq_category_id].present?
        faqs = faqs.where(position: params[:position]) if params[:position].present?
        if params[:status].present?
          faqs = if params[:status] == 'published'
                   faqs.where(is_published: true)
                 else
                   faqs.where(is_published: false)
                 end
        end
        if params[:search_term].present?
          faqs = faqs.where('lower(question) LIKE :search_question or lower(bn_question) LIKE :search_question',
                            search_question: "%#{params[:search_term].downcase}%")
        end
        Admin::Entities::Faqs.represent(paginate(faqs.order(id: :desc)))
      end

      desc 'FAQ create'
      params do
        use :faq_create_params
      end

      post do
        faq_category = FaqCategory.find_by(id: params[:faq_category_id])
        error!('FAQ category not found', HTTP_CODE[:NOT_FOUND]) unless faq_category.present?
        faq = Faq.new(declared(params, include_missing: false).merge!(created_by_id: @current_staff.id))
        authorize faq, :create?
        Admin::Entities::Faqs.represent(faq) if faq.save!
      end

      route_param :id do
        desc 'FAQ details'

        get do
          faq = Faq.find_by(id: params[:id])
          error!('FAQ not found', HTTP_CODE[:NOT_FOUND]) unless faq.present?
          authorize faq, :read?
          Admin::Entities::Faqs.represent(faq)
        end

        desc 'FAQ update'
        params do
          use :faq_update_params
        end

        put do
          faq = Faq.find_by(id: params[:id])
          error!('FAQ not found', HTTP_CODE[:NOT_FOUND]) unless faq.present?
          faq_category = FaqCategory.find_by(id: params[:faq_category_id])
          error!('FAQ category not found', HTTP_CODE[:NOT_FOUND]) unless faq_category.present?
          authorize faq, :update?
          faq.update!(declared(params, include_missing: false).merge!(updated_by_id: @current_staff.id))
          Admin::Entities::Faqs.represent(faq)
        end

        desc 'FAQ delete'

        delete do
          faq = Faq.find_by(id: params[:id])
          error!('FAQ not found', HTTP_CODE[:NOT_FOUND]) unless faq.present?
          authorize faq, :delete?
          faq.destroy!
          {
            message: 'Successfully deleted'
          }
        end
      end
    end
  end
end
