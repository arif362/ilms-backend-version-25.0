# Preview all emails at http://localhost:3000/rails/mailers/admin_forgot_password_mailer
class AdminForgotPasswordMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/admin_forgot_password_mailer/forgot_password
  def forgot_password
    PasswordMailer.forgot_password
  end

end
