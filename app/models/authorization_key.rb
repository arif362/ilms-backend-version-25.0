class AuthorizationKey < ApplicationRecord
  include OtpExpiration

  audited

  belongs_to :authable, polymorphic: true
end
