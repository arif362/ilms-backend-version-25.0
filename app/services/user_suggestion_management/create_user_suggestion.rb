# frozen_string_literal: true

module UserSuggestionManagement
  class CreateUserSuggestion
    include Interactor

    delegate :biblio_title, :biblio_ids, :author_ids, :biblio_subject_ids, :user, :action_type, to: :context

    def call
      multiple_user_suggestions
      create_user_suggestion('biblio_title', biblio_title) if biblio_title.present?
    end

    private

    def multiple_user_suggestions
      multiple_attr_set = %w[biblio_ids author_ids biblio_subject_ids]
      multiple_attr_set.each do |attribute_ids|
        if context.send(attribute_ids).present?
          context.send(attribute_ids).each { |attr_id| create_user_suggestion(attribute_ids[0...-1], attr_id) }
        end
      end
    end

    def create_user_suggestion(attr_key, attr_val)
      user_suggestion = user.user_suggestions.find_by(user.user_suggestions.arel_table[attr_key].eq(attr_val))
      if user_suggestion.present?
        user_suggestion.increment!("#{action_type}_count")
      else
        user_suggestion = user.user_suggestions.new
        user_suggestion[attr_key] = attr_val
        user_suggestion["#{action_type}_count"] = 1
        user_suggestion.save!
      end
    end
  end
end
