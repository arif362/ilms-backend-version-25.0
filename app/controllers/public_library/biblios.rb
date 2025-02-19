# frozen_string_literal: true

module PublicLibrary
  class Biblios < PublicLibrary::Base
    helpers PublicLibrary::Helpers::FailedSearchHelper
    helpers PublicLibrary::QueryParams::ReviewParams
    resources :biblios do
      desc 'Biblios List'
      params do
        use :pagination, per_page: 25
        optional :sort_by, type: String, values: %w[asc desc]
        optional :title, type: String
        optional :filter_with, type: Array, values: %w[subject author publication]
        optional :collection_type, type: String, values: %w[trending new_arrival most_borrowed most_read popular_author most_reviewed ]
        optional :is_ebook, type: Boolean, values: [true]
        optional :subject_ids, type: Array
        optional :author_ids, type: Array
        optional :publication_ids, type: Array
        optional :rating, type: Integer, values: { value: ->(v) { v.positive? }, message: 'must be greater than zero' }
        optional :count, type: Integer, values: { value: ->(v) { v.positive? }, message: 'must be greater than zero' }
      end
      route_setting :authentication, optional: true
      get do
        filter_list = {}
        biblio_list = Biblio.published.all
        if params[:title].present?
          biblio_list = biblio_list.where('lower(title) like ?', "%#{params[:title].downcase}%")
        end
        unless params[:collection_type].blank?
          biblio_list = case params[:collection_type]
                        when 'trending'
                          trending_point = ENV['TRENDING_THRESHOLD'].to_i
                          biblio_list.where('biblios.read_count >= :trending_point or
                                            biblios.borrow_count >= :trending_point', trending_point:).distinct
                        when 'new_arrival'
                          biblio_list.where('DATE(created_at) in (?)', 1.months.ago.to_date..Date.today)
                        when 'most_borrowed'
                          biblio_list.where('biblios.borrow_count >= 10')
                        when 'most_read'
                          biblio_list.where('read_count >= 10')
                        when 'popular_author'
                          biblio_list.joins(:authors).where('authors.popular_count >= 10')
                        when 'most_reviewed'
                          biblio_list.where('total_reviews >= 10')
                        end
        end
        unless params[:filter_with].blank?
          if params[:filter_with].include?('subject')
            filter_list[:subjects] = BiblioSubject.joins(:biblios).where(biblios: { id: biblio_list.ids }).distinct
          end
          if params[:filter_with].include?('author')
            filter_list[:authors] = Author.includes(:author_biblios)
                                          .where(author_biblios: { biblio_id: biblio_list.ids })
                                          .distinct
          end
          if params[:filter_with].include?('publication')
            filter_list[:publications] = BiblioPublication.where(id: biblio_list.pluck(:biblio_publication_id)).distinct
          end
        end
        biblio_list = biblio_list.where(is_e_biblio: params[:is_ebook]) if params[:is_ebook].present?
        if params[:author_ids].present? && params[:author_ids].length
          biblio_list = biblio_list.includes(:author_biblios).where(author_biblios: { author_id: params[:author_ids] })
        end
        if params[:subject_ids].present? && params[:subject_ids].length
          biblio_list = biblio_list.joins(:biblio_subjects).where(biblio_subjects: { id: params[:subject_ids] })
        end
        if params[:publication_ids].present? && params[:publication_ids].length
          biblio_list = biblio_list.where(biblio_publication_id: params[:publication_ids])
        end
        if params[:rating].present?
          rating = params[:rating].to_f
          biblio_list = biblio_list.where("TRUNCATE(average_rating, #{1}) BETWEEN ? AND ?", rating, rating + 0.9)
        end
        # create or update failed search
        add_failed_search(params[:title]) if params[:title].present? && biblio_list.blank?

        if @current_user.present?
          CreateUserSuggestionJob.perform_later(user: @current_user,
                                                biblio_title: params[:title],
                                                author_ids: params[:author_ids],
                                                biblio_subject_ids: params[:subject_ids],
                                                action_type: 'search')
        end
        biblio_list = if params[:count].present?
                        biblio_list.order('RAND()').limit(params[:count])
                      elsif params[:sort_by].present?
                        paginate(biblio_list.order(title: params[:sort_by]))
                      else
                        paginate(biblio_list.order(id: :desc))
                      end
        {
          filter_with: PublicLibrary::Entities::BiblioFilter.represent(filter_list, locale: @locale,
                                                                                    request_source: @request_source),
          biblio_list: PublicLibrary::Entities::BiblioList.represent(biblio_list,
                                                                     locale: @locale, request_source: @request_source,
                                                                     current_user: @current_user)
        }
      end


      desc ' online Biblios List'
      params do
        use :pagination, per_page: 25
        optional :title, type: String
        requires :item_type, type: String, values: %w[OB]
      end
      route_setting :authentication, optional: true
      get 'online-book' do
        item_type = ItemType.find_by(option_value: params[:item_type])
        error!('Online Item Type Not Found.', HTTP_CODE[:NOT_FOUND]) unless item_type.present?

        biblio_list = Biblio.where(item_type: item_type)

        if params[:title].present?
          biblio_list = biblio_list.where('lower(title) like ?', "%#{params[:title].downcase}%")
        end


        PublicLibrary::Entities::BiblioList.represent(paginate(biblio_list.order(id: :desc)),
                                                      locale: @locale, request_source: @request_source,
                                                      current_user: @current_user)

      end


      desc 'advance search on biblio list'
      params do
        optional :biblio_title, type: String
        optional :authors, type: Array[Integer]
        optional :biblio_subjects, type: Array[Integer]
        optional :isbn, type: String
        optional :publication, type: String
        optional :edition, type: String
        optional :volume, type: String
      end

      route_setting :authentication, optional: true
      get 'advance_search' do
        unless params[:isbn].present?
          error!('Minimum two fields are required', HTTP_CODE[:NOT_ACCEPTABLE]) unless params.count >= 2
        end
        biblios = Biblio.all
        unless params[:authors].blank?
          params[:authors].each do |author_id|
            author = Author.find_by(id: author_id)
            error!('Author not found', HTTP_CODE[:NOT_FOUND]) unless author.present?
          end
          author_biblios = AuthorBiblio.where(author_id: params[:authors])
          biblios = biblios.where(id: author_biblios.pluck(:biblio_id))
        end
        if params[:biblio_title].present?
          biblios = biblios.where('lower(biblios.title) LIKE ?',
                                  "%#{params[:biblio_title].downcase}%")
        end
        unless params[:biblio_subjects].blank?
          params[:biblio_subjects].each do |biblio_subject_id|
            biblio_subject = BiblioSubject.find_by(id: biblio_subject_id)
            error!('Biblio subject not found', HTTP_CODE[:NOT_FOUND]) unless biblio_subject.present?
          end
          biblio_subject_biblio = BiblioSubjectBiblio.where(biblio_subject_id: params[:biblio_subjects])
          biblios = biblios.where(id: biblio_subject_biblio.pluck(:biblio_id))
        end
        if params[:volume].present?
          biblios = biblios.where('lower(series_statement_volume) like ?',
                                  "%#{params[:volume].downcase}%")
        end
        if params[:edition].present?
          editions = BiblioEdition.where('lower(title) like ?', "%#{params[:edition].downcase}%")
          biblios = biblios.where(biblio_edition_id: editions.ids)
        end
        if params[:publication].present?
          publications = BiblioPublication.where('lower(title) like :publication or lower(bn_title) like :publication ',
                                                 publication: "%#{params[:publication].downcase}%")
          biblios = biblios.where(biblio_publication_id: publications.ids)
        end
        biblios = biblios.where(isbn: params[:isbn]) if params[:isbn].present?
        # create or update failed search
        add_failed_search(params[:biblio_title]) if params[:biblio_title].present? && biblios.blank?

        PublicLibrary::Entities::BiblioList.represent(biblios,
                                                      locale: @locale,
                                                      request_source: @request_source,
                                                      current_user: @current_user)
      end

      desc 'User suggestions biblios list'
      params do
        use :pagination, per_page: 25
        optional :sort_by, type: String, values: %w[asc desc]
        optional :title, type: String
        optional :filter_with, type: Array, values: %w[subject author publication]
        optional :subject_ids, type: Array
        optional :author_ids, type: Array
        optional :publication_ids, type: Array
        optional :rating, type: Integer, values: { value: ->(v) { v.positive? }, message: 'must be greater than zero' }
        optional :count, type: Integer, values: { value: ->(v) { v.positive? }, message: 'must be greater than zero' }
      end
      get 'user_suggestions' do
        filter_list = {}
        user_suggestions = @current_user.user_suggestions
        error!('User suggestions not found', HTTP_CODE[:NOT_FOUND]) unless user_suggestions.present?

        author_ids = user_suggestions.pluck(:author_id)
        biblio_subject_ids = user_suggestions.pluck(:biblio_subject_id)
        biblio_list = Biblio.joins(:authors, :biblio_subjects)
                            .where('authors.id in (?) or biblio_subjects.id in (?) or biblios.id in (?)',
                                   author_ids,
                                   biblio_subject_ids,
                                   user_suggestions.pluck(:biblio_id)).distinct
        if params[:title].present?
          biblio_list = biblio_list.where('lower(biblios.title) like ?', "%#{params[:title].downcase}%")
        end
        unless params[:filter_with].blank?
          filter_list[:subjects] = BiblioSubject.where(id: author_ids) if params[:filter_with].include?('subject')
          filter_list[:authors] = Author.where(id: author_ids) if params[:filter_with].include?('author')
          if params[:filter_with].include?('publication')
            filter_list[:publications] = BiblioPublication.where(id: biblio_list.pluck(:biblio_publication_id)).distinct
          end
        end
        if params[:author_ids].present? && params[:author_ids].length
          biblio_list = biblio_list.includes(:author_biblios).where(author_biblios: { author_id: params[:author_ids] })
        end
        if params[:subject_ids].present? && params[:subject_ids].length
          biblio_list = biblio_list.includes(:biblio_subjects).where(biblio_subjects: { id: params[:subject_ids] })
        end
        if params[:publication_ids].present? && params[:publication_ids].length
          biblio_list = biblio_list.where(biblio_publication_id: params[:publication_ids])
        end
        if params[:rating].present?
          rating = params[:rating].to_f
          biblio_list = biblio_list.where("TRUNCATE(average_rating, #{1}) BETWEEN ? AND ?", rating, rating + 0.9)
        end
        biblio_list = if params[:count].present?
                        biblio_list.order('RAND()').limit(params[:count])
                      elsif params[:sort_by].present?
                        paginate(biblio_list.order(title: params[:sort_by]))
                      else
                        paginate(biblio_list.order("RAND()"))
                      end
        {
          filter_with: PublicLibrary::Entities::BiblioFilter.represent(filter_list, locale: @locale,
                                                                       request_source: @request_source),
          biblio_list: PublicLibrary::Entities::BiblioList.represent(biblio_list,
                                                                     locale: @locale, request_source: @request_source,
                                                                     current_user: @current_user)
        }
      end

      route_param :id do
        desc 'Biblio details'
        route_setting :authentication, optional: true
        get do
          biblio = set_biblio(params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          biblio.update_columns(read_count: biblio.read_count + 1)
          biblio.suggest_biblio_read_count(@current_user) if @current_user.present?
          PublicLibrary::Entities::BiblioDetails.represent(biblio,
                                                           locale: @locale, request_source: @request_source,
                                                           current_user: @current_user)
        end

        desc 'Biblio availability Paper biblio in all libraries or not'

        route_setting :authentication, optional: true

        get :available do
          biblio = set_biblio(params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          { available: BiblioLibrary.where('biblio_id = ? AND available_quantity > ?', biblio.id, 0).present? }
        end

        desc 'Library Wise Paper biblio Biblio Availability'
        params do
          requires :library_code, type: String
        end
        route_setting :authentication, optional: true

        get :library_wise_availability do
          biblio = set_biblio(params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?

          library = Library.find_by(code: params[:library_code])
          error!('Library Not Found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          biblio_library = biblio.biblio_libraries.find_or_create_by!(library_id: library.id)

          {
            "is_available": biblio_library&.available_quantity&.positive?,
            "biblio": biblio.as_json(only: %i[id title]),
            "library_name": @locale == :en ? library.name : library.bn_name,
            "shelves": biblio_library&.available_quantity&.positive? ? biblio_library.library_locations.pluck(:code).compact : []
          }
        end

        desc 'Biblio Availability Paper biblio In All Libraries'
        params do
          use :pagination, max_per_page: 25
        end
        route_setting :authentication, optional: true

        get :all_library_availability do
          biblio = set_biblio(params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?

          libraries = Library.joins(:biblio_libraries)
                             .where('biblio_libraries.biblio_id = ? and biblio_libraries.available_quantity > 0', biblio.id).distinct

          PublicLibrary::Entities::LibraryList.represent(paginate(libraries.order(name: :asc)), locale: @locale)
        end

        desc 'Review List of a biblio'
        params do
          use :pagination, per_page: 25
        end
        route_setting :authentication, optional: true

        get :reviews do
          biblio = set_biblio(params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?
          reviews = []
          reviews = reviews << biblio.reviews.approved
          reviews = reviews << @current_user&.reviews if @current_user.present?
          reviews = reviews.compact.flatten.uniq
          reviews = reviews.sort_by(&:id).reverse
          reviews = Kaminari.paginate_array(reviews).page(params[:page]).per(params[:per_page])
          PublicLibrary::Entities::ReviewList.represent(paginate(reviews))
        end

        desc 'Review Create'
        params do
          use :review_create_params
        end
        post :reviews do
          biblio = set_biblio(params[:id])
          error!('Biblio not found', HTTP_CODE[:NOT_FOUND]) unless biblio.present?

          review = biblio.reviews.find_by(user_id: @current_user.id)
          error!('Already review exist', HTTP_CODE[:NOT_ACCEPTABLE]) unless review.blank?

          params.merge!(user_id: @current_user.id)
          review = biblio.reviews.build(declared(params).merge(user_id: @current_user.id))
          PublicLibrary::Entities::ReviewList.represent(review) if review.save!
        end
      end
    end
    helpers do
      def set_biblio(id_or_slug)
        Biblio.find_by_id(id_or_slug) || Biblio.find_by_slug(id_or_slug)
      end
    end
  end
end
