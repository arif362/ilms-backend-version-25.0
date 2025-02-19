# frozen_string_literal: true

module Admin
  class GalleryAlbums < Admin::Base
    resources :gallery_albums do
      include Admin::Helpers::AuthorizationHelpers
      helpers Admin::QueryParams::AlbumParams
      desc 'Album List'
      params do
        use :pagination, per_page: 25
        optional :is_event_album, type: Boolean
        optional :album_type, type: String, values: %w[photo video]
      end
      get do
        albums = Album.approved.all
        albums = albums.where(is_event_album: params[:is_event_album]) if params[:is_event_album].present?
        albums = albums.params[:album_type] if params[:album_type].present?
        authorize albums, :read?
        Admin::Entities::Albums.represent(paginate(albums.order(id: :desc)))
      end

      desc 'Album Request List'
      params do
        use :pagination, per_page: 25
        optional :library_code, type: String
        optional :status, type: String, values: %w[pending approved rejected]
        optional :album_type, type: String, values: %w[photo video]
      end
      get 'requests' do
        albums = Album.where(is_album_request: true)
        if params[:library_code].present?
          library = Library.find_by(code: params[:library_code])
          error!('Library not found', HTTP_CODE[:NOT_FOUND]) unless library.present?
          albums = albums.where(library_id: library.id)
        end
        albums = albums.where(album_type: params[:album_type]) if params[:album_type].present?
        albums = albums.where(status: params[:status]) if params[:status].present?
        authorize albums, :read?
        Admin::Entities::AlbumRequests.represent(paginate(albums.order(id: :desc)))
      end

      desc 'Create album'
      params do
        use :album_create_params
      end

      post do
        if params[:is_event_album].present? && params[:is_event_album] == true
          error!('Event must be present', HTTP_CODE[:NOT_ACCEPTABLE]) unless params[:event_id].present?
          event = Event.find_by(id: params[:event_id])
          error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
        else
          params.update(event_id: nil)
        end
        params[:album_items_attributes].each do |album_item|
          if params[:album_type] == 'photo'
            error!('Image file is missing', HTTP_CODE[:NOT_ACCEPTABLE]) unless album_item[:image_file].present?
            unless album_item[:video_link].blank?
              error!('Please remove video link from image album', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          else
            error!('Video link is missing', HTTP_CODE[:NOT_ACCEPTABLE]) unless album_item[:video_link].present?
            unless album_item[:image_file].blank?
              error!('Please remove image file from image album', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end
        end
        published_at = params[:is_visible] ? DateTime.now : nil
        album = Album.new(declared(params, include_missing: false).merge!(created_by_id: @current_staff.id,
                                                                          published_at:,
                                                                          status: Album.statuses[:approved]))
        authorize album, :create?
        Admin::Entities::AlbumDetails.represent(album) if album.save!
      end

      route_param :id do
        desc 'Album Details'

        get do
          album = Album.find_by(id: params[:id])
          error!('Album not found', HTTP_CODE[:NOT_FOUND]) unless album.present?
          authorize album, :read?
          Admin::Entities::AlbumDetails.represent(album)
        end

        desc 'Update album'
        params do
          use :album_update_params
        end

        put do
          album = Album.find_by(id: params[:id])
          error!('Album not found', HTTP_CODE[:NOT_FOUND]) unless album.present?
          if params[:is_event_album].present? && params[:is_event_album] == true
            error!('Event must be present', HTTP_CODE[:NOT_FOUND]) unless params[:event_id].present?
            event = Event.find_by(id: params[:event_id])
            error!('Event not found', HTTP_CODE[:NOT_FOUND]) unless event.present?
          else
            params.update(event_id: nil)
          end
          if params[:album_items_attributes].present?
            params[:album_items_attributes].each do |album_item|
              next if album_item[:_destroy] == true

              if params[:album_type] == 'photo'
                unless album_item[:video_link].blank?
                  error!('Please remove video link from image album', HTTP_CODE[:NOT_ACCEPTABLE])
                end
                next if album_item[:id].present?

                error!('Image file is missing', HTTP_CODE[:NOT_ACCEPTABLE]) unless album_item[:image_file].present?
              else
                unless album_item[:image_file].blank?
                  error!('Please remove image file from image album', HTTP_CODE[:NOT_ACCEPTABLE])
                end
                next if album_item[:id].present?

                error!('Video link is missing', HTTP_CODE[:NOT_ACCEPTABLE]) unless album_item[:video_link].present?
              end
            end
          end
          authorize album, :update?
          album.update!(declared(params, include_missing: false).merge!(updated_by_id: @current_staff.id))
          Admin::Entities::AlbumDetails.represent(album)
        end

        desc 'Approve album requests'

        put 'approve' do
          album = Album.pending.find_by(id: params[:id], is_album_request: true)
          error!('Album request not found', HTTP_CODE[:NOT_FOUND]) unless album.present?
          authorize album, :update?
          album.update!(updated_by_id: @current_staff.id, status: Album.statuses[:approved])
          Admin::Entities::AlbumDetails.represent(album)
        end

        desc 'Reject album requests'

        put 'reject' do
          album = Album.pending.find_by(id: params[:id], is_album_request: true)
          error!('Album request not found', HTTP_CODE[:NOT_FOUND]) unless album.present?
          authorize album, :update?
          album.update!(updated_by_id: @current_staff.id, status: Album.statuses[:rejected])
          Admin::Entities::AlbumDetails.represent(album)
        end

        desc 'Album delete'

        delete do
          album = Album.find_by(id: params[:id])
          error!('Album not found', HTTP_CODE[:NOT_FOUND]) unless album.present?
          authorize album, :delete?
          album.destroy!
          { message: 'Successfully deleted' }
        end
      end
    end
  end
end
