# frozen_string_literal: true

class CreateUserSuggestionJob < ApplicationJob
  queue_as :default

  def perform(args)
    user = args[:user]
    action_type = args[:action_type]
    biblio_title = args[:biblio_title]
    biblio_ids = args[:biblio_ids]
    author_ids = args[:author_ids]
    biblio_subject_ids = args[:biblio_subject_ids]
    UserSuggestionManagement::CreateUserSuggestion.call(user:,
                                                        biblio_title:,
                                                        biblio_ids:,
                                                        author_ids:,
                                                        biblio_subject_ids:,
                                                        action_type:)
  end
end
