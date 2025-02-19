# frozen_string_literal: true

module OtpExpiration
  extend ActiveSupport::Concern

  def expired?
    expiry.to_i < Time.now.to_i
  end
end
