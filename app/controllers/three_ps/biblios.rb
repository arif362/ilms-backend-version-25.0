# frozen_string_literal: true

module ThreePs
  class Biblios < ThreePs::Base

    resources :biblios do

      desc 'library card status update home'
      params do
        use :pagination, per_page: 5
        optional :search_term, type: String
      end

      route_setting :authentication, optional: true

      get do
        biblios = if params[:search_term].present?
                    paginate(Biblio.where('lower(title) like :search_term or lower(isbn) like :search_term',
                                          search_term: "%#{params[:search_term].downcase}%").order(id: :desc))
                  else
                    paginate(Biblio.all.order(id: :desc))
                  end

        {
          data: ThreePs::Entities::Biblios.represent(biblios),
          success: biblios.present?,
          message: 'Successful',
          status: 200
        }
      end

      route_setting :authentication, optional: true

      get 'is_biblio_available' do
        if params[:search_term].present?
          is_biblio_available = Biblio.where('lower(title) like :search_term or lower(isbn) like :search_term',
                                             search_term: "%#{params[:search_term].downcase}%").present?
        else
          is_biblio_available = Biblio.present?
        end
        {
          attributes: {
            book_found: is_biblio_available ? 'Y' : 'N'
          },
          status: 200
        }
      end

      desc 'Biblios List'
      params do
        use :pagination, per_page: 25
        optional :isbn, type: String, allow_blank: false
        optional :title, type: String, allow_blank: false
        optional :author_id, type: Integer, allow_blank: false
        optional :publisher_id, type: Integer, allow_blank: false
        optional :subject_id, type: Integer, allow_blank: false
        optional :edition_id, type: Integer, allow_blank: false
        optional :series_statement_volume, type: String, allow_blank: false
      end

      get 'search' do
        biblios = Biblio.all
        biblios = biblios.where('lower(isbn) like ?', "%#{params[:isbn].downcase}%") if params[:isbn].present?
        if params[:title].present?
          biblios = biblios.where('lower(biblios.title) like ?', "%#{params[:title].downcase}%")
        end
        if params[:series_statement_volume].present?
          biblios = biblios.where('lower(series_statement_volume) like ?',
                                  "%#{params[:series_statement_volume].downcase}%")
        end
        if params[:author_id].present?
          author = Author.find(params[:author_id])
          unless author.present?
            error!('Author not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.joins(:author_biblios).where('author_biblios.author_id = ?', params[:author_id])
        end

        if params[:publisher_id].present?
          publication = BiblioPublication.find(params[:publisher_id])
          unless publication.present?
            error!('Publisher not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.where(biblio_publication: publication)
        end

        if params[:subject_id].present?
          subject = BiblioSubject.find(params[:subject_id])
          unless subject.present?
            error!('Subject not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.joins(:biblio_subject_biblios).where('biblio_subject_biblios.biblio_subject_id',
                                                                 params[:subject_id])
        end

        if params[:edition_id].present?
          edition = BiblioEdition.find(params[:edition_id])
          unless edition.present?
            error!('Edition not found', HTTP_CODE[:NOT_FOUND])
          end
          biblios = biblios.where(biblio_edition: edition)
        end
        Lms::Entities::BiblioDetails.represent(paginate(biblios.order(id: :desc)))
      end
    end
  end
end
