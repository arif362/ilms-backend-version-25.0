class PasswordMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.password_mailer.forgot_password.subject
  #
  def forgot_password(token, staff)
    @token = token
    @staff = staff

    mail to: staff.email, subject: 'Reset Password'
  end
end
