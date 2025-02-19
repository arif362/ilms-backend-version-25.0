class Otp < ApplicationRecord
  include OtpExpiration

  belongs_to :otp_able, polymorphic: true

  enum otp_type: { phone_change: 0, reset_password: 1, security_money_withdraw: 2, temporary_user: 3,
                   registered_user: 4 }

  # Default Scope
  scope :active, -> { where(is_used: false) }
  before_create :exit_otp_limit, :will_otp_send
  after_create :send_otp



  def self.create_otp(phone)
    create!(phone:, code: generate_otp, expiry: 5.minute.from_now, send_interval_time: 2.minute.from_now)
  end

  def exit_otp_limit
    if temporary_user? || phone_change?
      return if self.class.unscoped.where(phone:).send(otp_type.to_s).length < 3
    else
      return if self.class.where('created_at >= ? AND phone = ?', 1.hours.ago, phone).length < 3
    end

    raise 'Too many otp requests'
  end

  def will_otp_send
    otp = if temporary_user? || phone_change?
            self.class.unscoped.active.where(phone:).send(otp_type.to_s).last
          else
            self.class.active.where(phone:).last
          end

    return if otp.blank?

    return if otp.send_interval_time.to_i <= Time.now.to_i

    raise 'Please Wait 2 min before send new Otp'
  end

  def self.generate_otp
    Array.new(4) { rand(10) }.join
  end

  private

  def send_otp
    Sms::SendOtp.call(phone:, message: "Your OTP for DPL is #{code}, Validity is 2 minutes. Help: 01914-321117")
  end

end
