# frozen_string_literal: true

module PublicLibrary
  class BiblioSubjects < PublicLibrary::Base
    resources :biblio_subjects do
      desc 'biblio subject list'
      params do
        use :pagination, per_page: 25
        optional :count, type: Integer
        optional :search_term, type: String
      end
      route_setting :authentication, optional: true
      get do
        biblio_subjects = BiblioSubject.not_deleted.all
        if params[:search_term].present?
          biblio_subjects = biblio_subjects.where('lower(personal_name) like :search_term
                                                  or lower(bn_personal_name) like :search_term',
                                                  search_term: "#{params[:search_term].downcase}%")
        end
        if params[:count].present?
          error!('Count must be positive', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:count].positive?
          biblio_subjects = biblio_subjects.order(id: :desc).first(params[:count])
        else
          biblio_subjects = paginate(biblio_subjects.order(id: :desc))
        end
        PublicLibrary::Entities::BiblioSubjects.represent(biblio_subjects, locale: @locale)
      end

      desc 'biblio subject dropdown list'
      route_setting :authentication, optional: true
      get 'dropdown' do
        biblio_subjects = BiblioSubject.not_deleted
        biblio_subjects = if @locale == :en
                            biblio_subjects.order(personal_name: :asc)
                          else
                            biblio_subjects.order(bn_personal_name: :asc)
                          end
        PublicLibrary::Entities::BiblioSubjects.represent(biblio_subjects, locale: @locale)
      end
    end
  end
end
