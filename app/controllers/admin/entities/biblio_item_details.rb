# frozen_string_literal: true

module Admin
  module Entities
    class BiblioItemDetails < Grape::Entity
      include Admin::Helpers::ImageHelpers

      expose :id
      expose :title
      expose :image_url
      expose :authors
      expose :subjects
      expose :accession_no
      expose :central_accession_no
      expose :library
      expose :current_circulation_status
      expose :circulation_history

      def title
        biblio.title
      end

      def authors
        biblio.authors.as_json(only: %i[id first_name last_name])
      end

      def subjects
        biblio.biblio_subjects.as_json(only: %i[id personal_name])
      end

      def image_url
        mobile_large_image(biblio.image)
      end

      def current_circulation_status
        object&.circulations&.last&.circulation_status&.borrowed? ? 'Borrowed' : 'Available'
      end

      def library
        object.library.as_json(only: %i[id name])
      end

      def circulation_history
        object.circulations.map do |circulation|
          pending_fine_amount = circulation.invoices&.fine&.pending&.sum(:invoice_amount)
          {
            member_id: circulation.member_id,
            member_name: circulation.member.user.full_name,
            borrow_date: circulation.created_at,
            return_date: circulation.return_at,
            pending_fine_amount:,
            payment_status: pending_fine_amount.positive? ? 'pending' : 'success'
          }
        end
      end

      def biblio
        object.biblio
      end

    end
  end
end
