class StaffMailer < ApplicationMailer
  # default from: 'smtps3241@gmail.com'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.staff_mailer.staff_created.subject
  #
  def send_mail_to_staff(email, password, lib_ip_of_staff)
    @greeting = 'Hi'
    @email = email
    @password = password
    @login_url = lib_ip_of_staff

    mail to: @email, subject: 'Welcome to Public Library'
  end
end
