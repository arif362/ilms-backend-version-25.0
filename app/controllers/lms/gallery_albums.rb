# frozen_string_literal: true

module Lms
  class GalleryAlbums < Lms::Base
    resources :gallery_albums do
      helpers Lms::QueryParams::AlbumParams

      desc 'Create album'
      params do
        use :album_create_params
      end

      post do
        except_album_images = params.except(:image_file, :album_items_attributes)
        except_items_images = []
        params[:album_items_attributes]&.each do |item|
          except_items_images << item.except(:image_file)
        end
        params_except_images = except_album_images.merge(album_items_attributes: except_items_images)
        staff = @current_library.staffs.find_by(id: params[:staff_id])
        unless staff.present?
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                  @current_library, false)
          error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
        end
        if params[:is_event_album].present? && params[:is_event_album] == true
          unless params[:event_id].present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event must be present' },
                                    staff, false)
            error!('Event must be present', HTTP_CODE[:NOT_FOUND])
          end
          event = Event.published.find_by(id: params[:event_id])
          unless event.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event not found for LMS' },
                                    staff, false)
            error!('Event not found for LMS', HTTP_CODE[:NOT_FOUND])
          end
        else
          params.update(event_id: nil)
        end
        params[:album_items_attributes].each do |album_item|
          if params[:album_type] == 'photo'
            unless album_item[:image_file].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Image file is missing' },
                                      staff, false)
              error!('Item image file is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            unless album_item[:video_link].blank?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Please remove video link from image album' },
                                      staff, false)
              error!('Please remove video link from image album', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          else
            unless album_item[:video_link].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Video link is missing' },
                                      staff, false)
              error!('Video link is missing', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            unless album_item[:image_file].blank?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Please remove image file from image album' },
                                      staff, false)
              error!('Please remove image file from image album', HTTP_CODE[:NOT_ACCEPTABLE])
            end
          end
        end
        album = Album.new(declared(params, include_missing: false).except(:staff_id)
                                                                  .merge!(created_by_id: staff.id,
                                                                          library_id: @current_library.id,
                                                                          status: Album.statuses[:pending],
                                                                          is_album_request: true))
        if album.save!
          BatchNotificationJob.perform_later(notificationable: album,
                                             permission: 'album-create',
                                             message: "Album request from #{@current_library.name}",
                                             message_bn: "#{@current_library.bn_name} থেকে অ্যালবামের অনুরোধ।")
          LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                  { status_code: HTTP_CODE[:CREATED]},
                                  staff, true)
          Lms::Entities::AlbumDetails.represent(album)
        end
      end

      route_param :id do
        desc 'Update album'
        params do
          use :album_update_params
        end

        put do
          params_except_images = params.except(:image_file)
          params_except_images[:album_items_attributes]&.each do |item|
            item.except!(:image_file)
          end
          staff = @current_library.staffs.find_by(id: params[:staff_id], is_album_request: true)
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          album = @current_library.albums.pending.find_by(id: params[:id], is_album_request: true)
          unless album.present?
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Album not found for lms' },
                                    staff, false)
            error!('Album not found for lms', HTTP_CODE[:NOT_FOUND])
          end
          if params[:is_event_album].present? && params[:is_event_album] == true
            unless params[:event_id].present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Event must be present' },
                                      staff, false)
              error!('Event must be present', HTTP_CODE[:NOT_ACCEPTABLE])
            end
            event = Event.published.find_by(id: params[:event_id])
            unless event.present?
              LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                      { status_code: HTTP_CODE[:NOT_FOUND], error: 'Event not found for LMS' },
                                      staff, false)
              error!('Event not found for LMS', HTTP_CODE[:NOT_FOUND])
            end
          else
            params.update(event_id: nil)
          end
          if params[:album_items_attributes].present?
            params[:album_items_attributes].each do |album_item|
              next if album_item[:_destroy] == true

              if params[:album_type] == 'photo'
                unless album_item[:video_link].blank?
                  LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                          { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Please remove video link from image album' },
                                          staff, false)
                  error!('Please remove video link from image album', HTTP_CODE[:NOT_ACCEPTABLE])
                end

                next if album_item[:id].present?

                unless album_item[:image_file].present?
                  LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                          { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Image file is missing' },
                                          staff, false)
                  error!('Image file is missing', HTTP_CODE[:NOT_ACCEPTABLE])
                end
              else
                unless album_item[:image_file].blank?
                  LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                          { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Please remove image file from image album' },
                                          staff, false)
                  error!('Please remove image file from image album', HTTP_CODE[:NOT_ACCEPTABLE])
                end
                next if album_item[:id].present?

                unless album_item[:video_link].present?
                  LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                          { status_code: HTTP_CODE[:NOT_ACCEPTABLE], error: 'Video link is missing' },
                                          staff, false)
                  error!('Video link is missing', HTTP_CODE[:NOT_ACCEPTABLE])
                end
              end
            end
          end
          if album.update!(declared(params, include_missing: false).except(:staff_id).merge!(updated_by_id: staff.id))
            LmsLogJob.perform_later(request.headers.merge(params_except_images:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            Lms::Entities::AlbumDetails.represent(album)
          end
        end

        desc 'Album delete'
        params do
          use :album_delete_params
        end
        delete do
          staff = @current_library.staffs.find_by(id: params[:staff_id])
          unless staff.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Staff doesn\'t exist in ILMS' },
                                    @current_library, false)
            error!('Staff doesn\'t exist in ILMS', HTTP_CODE[:NOT_FOUND])
          end
          album = @current_library.albums.pending.find_by(id: params[:id], is_album_request: true)
          unless album.present?
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:NOT_FOUND], error: 'Album not found for lms' },
                                    staff, false)
            error!('Album not found for lms', HTTP_CODE[:NOT_FOUND])
          end
          if album.destroy!
            LmsLogJob.perform_later(request.headers.merge(params:),
                                    { status_code: HTTP_CODE[:OK] },
                                    staff, true)
            { message: 'Successfully deleted' }
          end
        end
      end
    end
  end
end
