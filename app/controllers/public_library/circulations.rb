# frozen_string_literal: true

module PublicLibrary
  class Circulations < PublicLibrary::Base
    resources :circulations do
      before do
        error!('Membership required', HTTP_CODE[:NOT_FOUND]) unless @current_user.member.present?
      end

      desc 'Circulation info of current user'

      params do
        use :pagination, per_page: 25
        requires :status_key, type: String, values: CirculationStatus.status_keys.keys, allow_blank: false
      end

      get do
        circulations = @current_user.member.circulations.where(circulation_status: CirculationStatus.get_status(params[:status_key]))
        PublicLibrary::Entities::Circulations.represent(paginate(circulations), locale: @locale, request_source: @request_source)
      end

      route_param :id do
        desc 'details of a circulation book'
        get do
          circulation = @current_user.member.circulations.find_by(id: params[:id])
          error!('Biblio Not Found', HTTP_CODE[:NOT_FOUND]) unless circulation.present?

          PublicLibrary::Entities::Circulations.represent(circulation,
                                                          locale: @locale, request_source: @request_source)
        end

        desc 'Lost initiate and adding into circulation'

        patch 'lost' do
          member = @current_user.member
          circulation = member.circulations.find_by(id: params[:id])
          error!('Circulation Not Found', HTTP_CODE[:NOT_FOUND]) unless circulation.present?

          if member.lost_damaged_biblios.find_by(circulation_id: circulation.id).present?
            error!('You have already initiated a lost request', HTTP_CODE[:BAD_REQUEST])
          end

          lost_damaged_biblio = member.lost_damaged_biblios.new(library_id: circulation.library_id,
                                                                biblio_item_id: circulation.biblio_item_id,
                                                                circulation_id: circulation.id,
                                                                request_type: 'patron',
                                                                status: 'lost',
                                                                biblio_id: circulation.biblio_item.biblio_id,
                                                                created_by: @current_user,
                                                                updated_by: @current_user)
          Lms::LostBookToLms.perform_later(circulation) if lost_damaged_biblio.save!
          PublicLibrary::Entities::Circulations.represent(circulation, locale: @locale, request_source: @request_source)
        end

        desc 'Extend circulation'

        patch 'extend' do
          circulation = @current_user.member.circulations.find_by(id: params[:id])
          error!('Circulation Not Found', HTTP_CODE[:NOT_FOUND]) unless circulation.present?

          unless circulation.circulation_status.borrowed?
            error!('Circulation not in borrowed state', HTTP_CODE[:NOT_ACCEPTABLE])
          end

          if circulation.extended_at.present?
            error!('Extension not possible more than one time', HTTP_CODE[:NOT_ACCEPTABLE])
          end


          circulation.update_columns(extended_at: Time.now, return_at: circulation.return_at.advance(days: ENV['EXTENSION_DAYS'].to_i))

          PublicLibrary::Entities::Circulations.represent(circulation, locale: @locale, request_source: @request_source)
        end

      end

    end
  end
end
