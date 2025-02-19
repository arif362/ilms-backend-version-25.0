# Preview all emails at http://localhost:3000/rails/mailers/staff_mailer
class StaffMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/staff_mailer/staff_created
  def staff_created
    StaffMailer.staff_created
  end

end
