# frozen_string_literal: true

module PublicLibrary
  class GalleryAlbums < PublicLibrary::Base
    resources :gallery_albums do
      desc 'Album List'
      params do
        use :pagination, per_page: 25
        requires :album_type, type: String, values: %w[photo video]
        optional :search_term, type: String
        optional :start_date, type: Date
        optional :end_date, type: Date
      end
      route_setting :authentication, optional: true
      get do
        albums = if params[:album_type] == 'photo'
                   Album.approved.visible.photo
                 else
                   Album.approved.visible.video
                 end
        if params[:start_date].present? && params[:end_date].blank?
          error!('End date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        if params[:start_date].blank? && params[:end_date].present?
          error!('Start date is missing', HTTP_CODE[:NOT_ACCEPTABLE])
        end
        unless params[:start_date].blank?
          error!('Invalid date range', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:start_date] <= params[:end_date]
          albums = albums.where('date(published_at) in (?)', params[:start_date]..params[:end_date])
        end
        unless params[:search_term].blank?
          albums = albums.where('lower(title) like :search_term or lower(bn_title) like :search_term',
                                search_term: "%#{params[:search_term].downcase}%")
        end
        PublicLibrary::Entities::Albums.represent(paginate(albums.order(id: :desc)),
                                                  locale: @locale,
                                                  request_source: @request_source)
      end

      route_param :id do
        desc 'Album Details'
        route_setting :authentication, optional: true
        get do
          album = Album.approved.visible.find_by(id: params[:id])
          error!('Album not found', HTTP_CODE[:NOT_FOUND]) unless album.present?
          PublicLibrary::Entities::AlbumDetails.represent(album, locale: @locale, request_source: @request_source)
        end

        desc 'Album Item Details'
        route_setting :authentication, optional: true
        get 'album_items/:album_item_id' do
          album = Album.approved.visible.find_by(id: params[:id])
          error!('Album not found', HTTP_CODE[:NOT_FOUND]) unless album.present?

          album_item = album.album_items.find_by(id: params[:album_item_id])
          error!('Album item not found', HTTP_CODE[:NOT_FOUND]) unless album_item.present?
          PublicLibrary::Entities::AlbumItems.represent(album_item,
                                                        locale: @locale,
                                                        request_source: @request_source)
        end
      end
    end
  end
end
