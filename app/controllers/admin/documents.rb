# frozen_string_literal: true

module Admin
  class Documents < Admin::Base
    include Admin::Helpers::AuthorizationHelpers

    resources :documents do
      helpers Admin::QueryParams::DocumentParams
      desc 'Document List'

      params do
        optional :name, type: String
        optional :document_category_id, type: Integer
      end

      get do
        documents = if params[:document_category_id].present?
                      document_category = DocumentCategory.find_by(id: params[:document_category_id])
                      error!('Document Category not found', HTTP_CODE[:NOT_FOUND]) unless document_category.present?
                      documents = document_category.documents
                      if params[:name].present?
                        documents = documents.where("lower(name) LIKE ?", "%#{params[:name].downcase}%")
                      end
                      documents.order(id: :desc)
                    else
                      if params[:name].present?
                        Document.where("lower(name) LIKE ?", "%#{params[:name].downcase}%").order(id: :desc)
                      else
                        Document.order(id: :desc)
                      end
                    end
        authorize documents, :read?
        Admin::Entities::DocumentIndexes.represent(paginate(documents.order(id: :desc)))
      end

      desc 'Document Create'
      params do
        use :document_create_params
      end
      post do
        document_category = DocumentCategory.find_by(id: params[:document_category_id])
        error!('Document Category not found', HTTP_CODE[:NOT_FOUND]) unless document_category.present?
        document = document_category.documents.new(declared(params, include_missing: false).merge!(created_by: current_user.id))
        authorize document, :create?
        document.save!
        Admin::Entities::Documents.represent(document)
      end

      route_param :id do
        desc 'Document Details'

        get do
          document = Document.find_by(id: params[:id])
          error!('Document not Found', HTTP_CODE[:NOT_FOUND]) unless document.present?
          authorize document, :read?
          Admin::Entities::Documents.represent(document)
        end

        desc 'Document Update'

        params do
          use :document_update_params
        end

        put do
          document_category = DocumentCategory.find_by(id: params[:document_category_id])
          error!('Document Category not found', HTTP_CODE[:NOT_FOUND]) unless document_category.present?
          document = Document.find_by(id: params[:id])
          error!('Document not Found', HTTP_CODE[:NOT_FOUND]) unless document.present?
          authorize document, :update?
          document.update!(declared(params, include_missing: false).merge!(created_by: current_user.id))
          Admin::Entities::Documents.represent(document)
        end

        desc 'Document Delete'

        delete do
          document = Document.find_by(id: params[:id])
          error!('Document not Found', HTTP_CODE[:NOT_FOUND]) unless document.present?
          authorize document, :delete?
          document.destroy
        end
      end
    end
  end
end
