# frozen_string_literal: true

module Admin
  class HomepageSliders < Admin::Base
    resources :homepage_sliders do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::HomepageSliderParams
      desc 'Homepage Sliders List'
      params do
        use :pagination, per_page: 25
      end
      get do
        homepage_sliders = HomepageSlider.not_deleted.all
        authorize homepage_sliders, :read?
        Admin::Entities::HomepageSliders.represent(paginate(homepage_sliders.order(id: :desc)))
      end

      desc 'Create homepage slider'
      params do
        use :homepage_slider_create_params
      end

      post do
        slider_count = HomepageSlider.not_deleted.visible.count
        if params[:is_visible].present? && (slider_count >= 6 && params[:is_visible] == true)
          error!('Six sliders are already active', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        homepage_slider = HomepageSlider.new(declared(params, include_missing: false))
        authorize homepage_slider, :create?
        Admin::Entities::HomepageSliders.represent(homepage_slider) if homepage_slider.save!
      end

      route_param :id do
        desc 'Homepage Slider Details'

        get do
          homepage_slider = HomepageSlider.not_deleted.find_by(id: params[:id])
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless homepage_slider.present?
          authorize homepage_slider, :read?
          Admin::Entities::HomepageSliders.represent(homepage_slider)
        end

        desc 'Update homepage slider'
        params do
          use :homepage_slider_update_params
        end

        put do
          homepage_slider = HomepageSlider.not_deleted.find_by(id: params[:id])
          error!('Not Found', HTTP_CODE[:NOT_FOUND]) unless homepage_slider.present?
          if params[:is_visible].present? && params[:is_visible] == true
            slider_count = HomepageSlider.not_deleted.visible.count
            if slider_count >= 6 && !homepage_slider.is_visible?
              error!('Six sliders are already active', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end
          authorize homepage_slider, :update?
          homepage_slider.update!(declared(params, include_missing: false))
          Admin::Entities::HomepageSliders.represent(homepage_slider)
        end

        desc 'Homepage Slider Delete'

        delete do
          homepage_slider = HomepageSlider.find_by(id: params[:id], is_deleted: false)
          error!('Not found', HTTP_CODE[:NOT_FOUND]) unless homepage_slider.present?
          authorize homepage_slider, :delete?
          homepage_slider.destroy
          {
            message: 'Successfully deleted'
          }
        end
      end
    end
  end
end
