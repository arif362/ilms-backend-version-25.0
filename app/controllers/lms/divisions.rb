# frozen_string_literal: true

module Lms
  class Divisions < Lms::Base
    helpers Lms::QueryParams::DivisionParams

    resources :divisions do
      desc 'Divisions dropdown List'

      get 'dropdown' do
        divisions = Division.not_deleted.order(name: :asc)
        Lms::Entities::Divisions.represent(divisions)
      end

      desc 'Divisions List'

      params do
        optional :name, type: String
      end

      get do
        divisions = if params[:name].present?
                      Division.not_deleted.where("name LIKE ?", "%#{params[:name]}%").order(name: :asc)
                    else
                      Division.not_deleted.order(name: :asc)
                    end
        Lms::Entities::Divisions.represent(divisions)
      end

      desc 'Division Create'
      params do
        use :division_create_params
      end
      post do
        division = Division.new(declared(params, include_missing: false))
        if division.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
          Lms::Entities::Divisions.represent(division)
        end
      end

      route_param :id do
        desc 'Division Details'

        get do
          division = Division.not_deleted.find_by(id: params[:id])
          unless division.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Division not found' },
                                    @current_library, false)
            error!('Division not found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::Divisions.represent(division)
        end

        desc 'Division Update'

        params do
          use :division_update_params
        end

        put do
          division = Division.not_deleted.find_by(id: params[:id])
          unless division.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Division not found' },
                                    @current_library, false)
            error!('Division not found', HTTP_CODE[:NOT_FOUND])
          end
          if division.update!(declared(params, include_missing: false))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::Divisions.represent(division)
          end
        end

        desc 'Division Delete'

        patch do
          division = Division.not_deleted.find_by(id: params[:id])
          unless division.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Division not found' },
                                    @current_library, false)
            error!('Division not found', HTTP_CODE[:NOT_FOUND])
          end
          if division.update!(is_deleted: true)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::Divisions.represent(division)
          end
        end
      end
    end
  end
end
