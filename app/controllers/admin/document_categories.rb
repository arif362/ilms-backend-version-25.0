# frozen_string_literal: true

module Admin
  class DocumentCategories < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resources :document_categories do
      helpers Admin::QueryParams::DocumentCategoryParams
      desc 'Document Category List'

      params do
        optional :name, type: String
      end

      get do
        document_categories = if params[:name].present?
                                DocumentCategory.where("lower(name) LIKE ?", "%#{params[:name].downcase}%").order(id: :desc)
                              else
                                DocumentCategory.order(id: :desc)
                              end
        authorize document_categories, :read?
        Admin::Entities::DocumentCategories.represent(document_categories)
      end

      desc 'Document Category dropdowns'

      get 'dropdown' do
        document_categories = DocumentCategory.order(id: :desc)
        authorize document_categories, :read?
        Admin::Entities::DocumentCategoryDropdowns.represent(document_categories)
      end

      desc 'Document Category Create'
      params do
        use :document_category_create_params
      end
      post do
        document_category = DocumentCategory.new(declared(params, include_missing: false).merge!(created_by: current_user.id))
        authorize document_category, :create?
        document_category.save!
        Admin::Entities::DocumentCategories.represent(document_category)
      end

      route_param :id do
        desc 'Document Category Details'

        get do
          document_category = DocumentCategory.find_by(id: params[:id])
          error!('Document Category not Found', HTTP_CODE[:NOT_FOUND]) unless document_category.present?
          authorize document_category, :read?
          Admin::Entities::DocumentCategories.represent(document_category)
        end

        desc 'Division Update'

        params do
          use :document_category_create_params
        end

        put do
          document_category = DocumentCategory.find_by(id: params[:id])
          error!('Document Category not Found', HTTP_CODE[:NOT_FOUND]) unless document_category.present?
          authorize document_category, :update?
          document_category.update(declared(params, include_missing: false).merge!(created_by: current_user.id))
          Admin::Entities::DocumentCategories.represent(document_category)
        end

        desc 'Document Category Delete'

        delete do
          document_category = DocumentCategory.find_by(id: params[:id])
          error!('Document Category not Found', HTTP_CODE[:NOT_FOUND]) unless document_category.present?
          authorize document_category, :delete?
          document_category.destroy
        end
      end
    end
  end
end
