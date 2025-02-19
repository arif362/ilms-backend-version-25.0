# frozen_string_literal: true

module BiblioItemManagement
  class ValidateBiblioItem
    include Interactor

    delegate :request_params, :biblio, :current_library, to: :context

    def remove_locations
      # code here
    end

    def call
      if request_params[:biblio_item_type] == 'e_biblio'
        validate_ebook
        remove_library_locations
      else
        validate_library_locations
        context.fail!(error: 'Remove E-book file') unless request_params[:full_ebook_file].blank?
      end
    end

    private

    def validate_ebook
      context.fail!(error: 'E-book already exist') unless biblio.biblio_items.e_biblio.blank?
      context.fail!(error: 'Book preview file is missing') unless request_params[:preview_file].present?
      context.fail!(error: 'E-book file is missing') unless request_params[:full_ebook_file].present?
    end

    def validate_library_locations
      location_types = library_location_types
      location_types.each do |location_type|
        next unless request_params["#{location_type}_library_location_id"].present?

        library_location = LibraryLocation.find_by(id: request_params["#{location_type}_library_location_id"])
        context.fail!(error: "#{location_type.capitalize} library location not found") unless library_location.present?
      end
    end

    def library_location_types
      %w[permanent current shelving]
    end

    def remove_library_locations
      location_types = library_location_types
      flag = 0
      location_types.each do |location_type|
        flag = 1 if request_params["#{location_type}_library_location_id"].present?
        break if flag == 1
      end
      context.fail!(error: 'Remove library location for ebook') if flag == 1
    end
  end
end
