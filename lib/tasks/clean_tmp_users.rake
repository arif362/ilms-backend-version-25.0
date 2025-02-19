namespace :clean_tmp_users do
  desc 'Clean TmpUser data created more than half an hour ago'
  task tmp_users: :environment do
    puts 'Cleaning TmpUser data...'

    # Calculate the timestamp for half an hour ago
    half_hour_ago = Time.now - 30.minutes

    # Delete TmpUser records created more than half an hour ago
    TmpUser.where('created_at < ?', half_hour_ago).destroy_all

    puts 'TmpUser data cleaned successfully.'
  end
end
