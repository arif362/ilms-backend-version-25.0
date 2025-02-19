# frozen_string_literal: true

module PublicLibrary
  class Memorandums < PublicLibrary::Base
    resources :memorandums do
      desc 'Get a list of memorandums'
      params do
        use :pagination, per_page: 25
        optional :count, type: Integer, values: { value: ->(v) { v.positive? }, message: 'must be greater than zero' }
      end
      route_setting :authentication, optional: true
      get do
        memorandums = Memorandum.not_deleted.is_visible.all
        memorandums = if params[:count].present?
                        memorandums.order(id: :desc).limit(params[:count])
                      else
                        paginate(memorandums.order(id: :desc))
                      end

        PublicLibrary::Entities::Memorandums.represent(memorandums)
      end

      desc 'Get latest memorandums'
      route_setting :authentication, optional: true
      get 'latest' do
        memorandums = Memorandum.not_deleted.is_visible.last
        PublicLibrary::Entities::Memorandums.represent(memorandums, current_user: @current_user || nil)
      end

      route_param :id do
        desc 'meorandum details'
        route_setting :authentication, optional: true
        get do
          memorandum = Memorandum.not_deleted.is_visible.find_by(id: params[:id])
          error!('Memorandum Not Found', HTTP_CODE[:NOT_FOUND]) unless memorandum.present?
          PublicLibrary::Entities::Memorandums.represent(memorandum)
        end

      end
    end
  end
end
