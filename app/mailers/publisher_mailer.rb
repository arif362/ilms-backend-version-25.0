class PublisherMailer < ApplicationMailer
  def send_mail_to_publisher(publisher, status)
    @greeting = 'Hi'
    @publisher = publisher
    @status = status

    mail to: @publisher.user.email, subject: 'Purchase Order Update'
  end
end
