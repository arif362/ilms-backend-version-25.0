# app/helpers/cart_helper.rb
module Lms::Helpers
  module DeliveryChargeHelper
    extend Grape::API::Helpers
    include Rails.application.routes.url_helpers

    def calculate_delivery_charge(library, biblio_ids)
      delivery_charge = 0
      books_at_all_libraries = BiblioLibrary.where(biblio_id: biblio_ids, available_quantity: 1...)
      delivery_charge = 0 if books_at_all_libraries.blank?

      books_at_selected_library = library.biblio_libraries.where(biblio_id: biblio_ids, available_quantity: 1...)
      books_without_selected_libraries = books_at_all_libraries - books_at_selected_library

      if books_at_selected_library.present?
        if books_at_selected_library.map(&:biblio_id).compact.uniq.sort == biblio_ids.sort
          delivery_charge += ENV['SHIPPING_CHARGE_SAME_DISTRICT'].to_i
        elsif books_without_selected_libraries.present?
          delivery_charge += ENV['SHIPPING_CHARGE_SAME_DISTRICT'].to_i +
            ENV['SHIPPING_CHARGE_OTHER_DISTRICT'].to_i * books_without_selected_libraries.map(&:library_id).uniq.count
        end
      elsif books_at_all_libraries.present? && books_at_all_libraries.map(&:biblio_id).compact.uniq.sort == biblio_ids.sort
        if books_at_all_libraries.map(&:library_id).uniq.count == 1
          delivery_charge += ENV['SHIPPING_CHARGE_OTHER_DISTRICT'].to_i
        elsif books_at_all_libraries.map(&:library_id).uniq.count > 1
          delivery_charge += ENV['SHIPPING_CHARGE_OTHER_DISTRICT'].to_i * books_at_all_libraries.map(&:library_id).uniq.count
        end
      end

      delivery_charge
    end
  end
end
