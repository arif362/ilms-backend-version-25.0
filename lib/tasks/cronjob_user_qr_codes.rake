# frozen_string_literal: true

desc 'Whenever rake to remove expired user qr codes'
task remove_expired_user_qr_codes: :environment do
  UserQrCode.inactive.each do |user_qr_code|
    Rails.logger.info "Removed user qr code for usr #{user_qr_code.user_id}"
    user_qr_code.destroy
  end
end
