# frozen_string_literal: true

class AuthToken
  def self.generate_access_token(user, user_agent = nil)
    expiry = 1.month.from_now
    rand = SecureRandom.hex(10)
    token = BCrypt::Password.create(rand)

    auth_key = AuthorizationKey.create!(authable: user,
                                        user_agent: ,
                                        token:,
                                        expiry:)

    {
      token: auth_key.token,
      expired_at: auth_key.expiry
    }
  end

  def self.generate_staff_token(user)
    expiry = 1.month.from_now
    rand = SecureRandom.hex(10)
    token = BCrypt::Password.create(rand)
    auth_key = AuthorizationKey.find_or_create_by(authable: user) do |auth|
      auth.token = token
      auth.expiry = expiry
    end
    auth_key.update!(token:, expiry:)
    {
      token: auth_key.token,
      expired_at: auth_key.expiry
    }
  end

  def self.remove_access_token(current_user, user_agent = nil)
    auth_key = AuthorizationKey.find_by(authable: current_user, user_agent:)
    auth_key.destroy! if auth_key.present?
    auth_key&.destroyed? || false
  end
end
