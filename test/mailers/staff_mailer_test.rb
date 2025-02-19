require "test_helper"

class StaffMailerTest < ActionMailer::TestCase
  test "staff_created" do
    mail = StaffMailer.staff_created
    assert_equal "Staff created", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
