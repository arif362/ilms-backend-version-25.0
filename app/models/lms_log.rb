# frozen_string_literal: true

class LmsLog < ApplicationRecord
  belongs_to :user_able, polymorphic: true, optional: true

  def self.add_log(request, response, user_able = nil, status = nil)
    create(api_response: response,
           api_request: request,
           user_able:,
           status:)
  end
end
