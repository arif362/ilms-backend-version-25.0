module UsernameAuthValidation
  extend ActiveSupport::Concern
  include BCrypt


  included do
    # Validations
    validates :password, confirmation: true, presence: true, on: :create
    validates :username, length: { minimum: 4 }, presence: true, uniqueness: true,
                         format: { with: /\A[a-zA-Z0-9_-]+\Z/, message: 'Not a valid username' },
                         on: :create
    validate :check_password_format
  end


  def check_password_format
    return unless password_confirmation.present?

    password_lower_case
    password_uppercase
    password_contains_number
    password_special_char
    password_length
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def password_uppercase
    return unless password_confirmation.match(/\p{Upper}/).nil?

    errors.add :password, ' must contain at least 1 uppercase '
  end

  def password_lower_case
    return unless password_confirmation.match(/\p{Lower}/).nil?

    errors.add :password, ' must contain at least 1 lowercase '
  end

  def password_special_char
    special = "?<>',?[]}{=-)(*&^%$#@`~{}!"
    regex = /[#{special.gsub(/./) { |char| "\\#{char}" }}]/
    return if password_confirmation =~ regex

    errors.add :password, ' must contain special character'
  end

  def password_contains_number
    return if password_confirmation.count('0-9').positive?

    errors.add :password, ' must contain at least one number'
  end

  def password_length
    errors.add :password, ' length at least 6 characters' if password_confirmation.length < 6
    errors.add :password, ' length should maximum 32 characters' if password_confirmation.length > 32
  end

end
