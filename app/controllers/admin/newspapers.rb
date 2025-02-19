# frozen_string_literal: true

module Admin
  class Newspapers < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    resources :newspapers do
      helpers Admin::QueryParams::NewspaperParams

      desc 'Newspapers List'
      params do
        optional :name
      end

      get do
        newspapers = if params[:name]
                       Newspaper.where('lower(name) LIKE ?', "%#{params[:name].downcase}%")
                     else
                       Newspaper.all
                     end
        newspapers = newspapers.order(id: :desc)

        Admin::Entities::Newspapers.represent(newspapers)
      end

      desc 'Create newspaper'

      params do
        use :newspaper_create_params
      end

      post do
        newspaper = Newspaper.create!(declared(params, include_missing: false).merge(created_by: @current_staff.id))

        Admin::Entities::Newspapers.represent(newspaper)
      end

      route_param :id do
        desc 'Newspaper Details'

        get do
          newspaper = Newspaper.find_by(id: params[:id])
          error!('Newspaper Not Found') unless newspaper.present?

          Admin::Entities::NewspaperDetails.represent(newspaper)
        end

        desc 'Newspaper Update'
        params do
          use :newspaper_update_params
        end

        put do
          newspaper = Newspaper.find_by(id: params[:id])
          error!('Newspaper Not Found') unless newspaper.present?
          newspaper.update!(declared(params, include_missing: false).merge(updated_by_id: @current_staff.id))

          Admin::Entities::Newspapers.represent(newspaper)
        end

        desc 'Newspaper Delete'
        delete do
          newspaper = Newspaper.find_by(id: params[:id])
          error!('Newspaper Not Found') unless newspaper.present?

          newspaper.destroy!
        end
      end
    end
  end
end
