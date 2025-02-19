# frozen_string_literal: true

module Lms
  class Districts < Lms::Base
    helpers Lms::QueryParams::DistrictParams

    resources :districts do
      desc 'Districts dropdown List'

      params do
        requires :division_id, type: Integer
      end

      get 'dropdown' do
        division = Division.not_deleted.find_by(id: params[:division_id])
        unless division.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Division not found' },
                                  @current_library, false)
          error!('Division not found', HTTP_CODE[:NOT_FOUND])
        end
        districts = division.districts.not_deleted.order(name: :asc)
        Lms::Entities::DistrictDropdown.represent(districts)
      end

      desc 'Districts List'

      params do
        optional :division_id, type: Integer
        optional :name, type: String
      end

      get do
        districts = if params[:division_id].present?
                      division = Division.not_deleted.find_by(id: params[:division_id])
                      unless division.present?
                        LmsLogJob.perform_later(request.headers.merge(params:),
                                                { status_code: HTTP_CODE[:NOT_FOUND], error: 'Division not found' },
                                                @current_library, false)
                        error!('Division not found', HTTP_CODE[:NOT_FOUND])
                      end
                      division.districts.not_deleted
                    else
                      District.not_deleted
                    end
        districts.where("lower(name) LIKE ?", "%#{params[:name].downcase}%").order(name: :asc) if params[:name].present?
        Lms::Entities::Districts.represent(districts.order(name: :asc))
      end

      desc 'District Create'
      params do
        use :district_create_params
      end
      post do
        division = Division.not_deleted.find_by(id: params[:division_id])
        unless division.present?
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Division not found' },
                                  @current_library, false)
          error!('Division not found', HTTP_CODE[:NOT_FOUND])
        end
        district = District.new(declared(params, include_missing: false))
        if district.save!
          LmsLogJob.perform_later(request.headers.merge(params:),
                                  { status_code: HTTP_CODE[:OK] },
                                  @current_library, true)
         Lms::Entities::Districts.represent(district)
        end
      end

      route_param :id do
        desc 'District Details'

        get do
          district = District.not_deleted.find_by(id: params[:id])
          unless district.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'District not found' },
                                    @current_library, false)
            error!('District not found', HTTP_CODE[:NOT_FOUND])
          end
          Lms::Entities::Districts.represent(district)
        end

        desc 'District Update'

        params do
          use :district_update_params
        end

        put do
          division = Division.not_deleted.find_by(id: params[:division_id])
          unless division.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Division not found' },
                                    @current_library, false)
            error!('Division not found', HTTP_CODE[:NOT_FOUND])
          end
          district = District.not_deleted.find_by(id: params[:id])
          unless district.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'District not found' },
                                    @current_library, false)
            error!('District not found', HTTP_CODE[:NOT_FOUND])
          end
          if district.update!(declared(params, include_missing: false))
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::Districts.represent(district)
          end
        end

        desc 'District Delete'

        patch do
          district = District.not_deleted.find_by(id: params[:id])
          unless district.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'District not found' },
                                    @current_library, false)
            error!('District not found', HTTP_CODE[:NOT_FOUND])
          end
          if district.update!(is_deleted: true)
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    @current_library, true)
            Lms::Entities::Districts.represent(district)
          end
        end
      end
    end
  end
end
