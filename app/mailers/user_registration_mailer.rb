class UserRegistrationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.password_mailer.forgot_password.subject
  #
  def registration_mailer(user)
    @staff = user
    @name = user&.full_name

    mail to: user.email, subject: 'Registration Done successfully.'
  end
end
