# frozen_string_literal: true

module Admin
  class Distributions < Admin::Base
    include Admin::Helpers::AuthorizationHelpers
    helpers Admin::QueryParams::DesignationParams
    resources :distributions do

      desc 'distribution List'
      params do
        use :pagination, per_page: 25
      end

      get do
        distributions = Distribution.all.order(id: :desc)
        authorize distributions, :read?
        Admin::Entities::DistributionList.represent(paginate(distributions))
      end

      route_param :id do
        desc 'Distribution Details'
        params do
          use :pagination, per_page: 25
        end

        get do
          distribution = Distribution.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless distribution.present?
          authorize distribution, :read?

          publisher_biblio_ids = distribution.department_biblio_items.pluck(:publisher_biblio_id).uniq

          publisher_biblios = PublisherBiblio.where(id: publisher_biblio_ids)

          library = Library.find_by(id: distribution.library_id)&.as_json(only: %i[id name])

          {
            library: library,
            status: distribution.status,
            publisher_biblios: Admin::Entities::DistributionPublisherBiblios.represent(paginate(publisher_biblios), id: params[:id])
          }
        end

        desc 'in_transit'

        put 'in_transit' do
          distribution = Distribution.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless distribution.present?

          error!('Distribution Not In Pending/Processing state', HTTP_CODE[:NOT_FOUND]) unless distribution.pending?
          authorize distribution, :update?

          distribution.update!(status: 'in_transit')

          {
            id: distribution.id,
            status: distribution.status,
            created_at: distribution.created_at,
            updated_at: distribution.updated_at,
            item_count: distribution.item_count,
            library_id: distribution.library_id
          }

        end
      end
    end
  end
end

