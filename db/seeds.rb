# frozen_string_literal: true
#
require 'csv'
# require 'faker'
#
# def create_staff(params, staff_type)
#   index = Staff.all.count + 1
#   admin_email = Faker::Internet.email(name: "test_role#{index}", domain:"@misfit.tech")
#   librarian_email = Faker::Internet.email(name:"test_librarian#{index}", domain:"@misfit.tech")
#   # email = staff_type == :admin ? "test_#{params[:role_title]}_#{index}@misfit.tech" : "test_librarian#{index}@misfit.tech"
#   email = staff_type == :admin ? admin_email : librarian_email
#   phone_number = "01812345#{index.to_s.rjust(3, '0')}"
#   password = '@Pass123'
#   staff = Staff.find_or_initialize_by(email:) do |staff|
#     staff.name = Faker::Name.unique.name
#     staff.phone = phone_number
#     staff.staff_type = staff_type
#     staff.designation_id = params[:designation_id]
#     staff.password = password
#     staff.password_confirmation = password
#   end
#   if staff_type == :admin
#     staff.role_id = params[:role_id]
#   else
#     staff.library_id = params[:library_id]
#   end
#   staff.save!
# end
#
roles = ['Super Admin', 'Admin']
designations = %w[President Prime-minister Secretary Librarian]

puts '..........  Designation seeding ............'

designations.each do |designation|
  Designation.find_or_create_by!(title: designation)
end

puts '.............. Role Seeding...................'

roles.each do |role|
  role = Role.find_or_create_by!(title: role)
  role.update!(permission_codes: Role::PERMISSION_GROUP.values.map(&:values).flatten.uniq)
end

puts '.............. System Admin Creating ...................'

Staff.create!(designation_id: 1, role_id: 1, gender: 0, name: 'System Admin', email: 'system_admin@dpl.gov.bd',
              password: '@Admin1@', password_confirmation: '@Admin1@', staff_type: :admin, phone: '01710623272')


puts '................. Division Seeding  .........................'

divisions = CSV.read(Rails.root.join('tmp/csv/division.csv'),
                     headers: true, col_sep: ',', header_converters: :symbol)
fail_divisions = []
fail_divisions << %w[SL Name BN_Name]
divisions.each do |row|
  data = row.to_h
  division = Division.find_or_create_by!(name: data[:name]) do |division|
    division.name = data[:name]
    division.bn_name = data[:bn_name]
  end
  fail_divisions << row unless division.present?
end
failed_div_file = 'tmp/csv/failed_divisions.csv'
File.write(failed_div_file, fail_divisions.map(&:to_csv).join) if fail_divisions.length.positive?

puts '.................. Districts seeding .................'

districts = CSV.read(Rails.root.join('tmp/csv/district.csv'),
                     headers: true, col_sep: ',', header_converters: :symbol)
fail_districts = []
fail_districts << %w[Name BN_Name Division_Name]
districts.each do |row|
  data = row.to_h
  district = District.find_or_create_by!(name: data[:name]) do |district|
    district.name = data[:name]
    district.bn_name = data[:bn_name]
    district.division_id = Division.find_by(name: data[:division_name]).id
  end
  fail_districts << row unless district.present?
end
failed_dis_file = 'tmp/csv/failed_districts.csv'
File.write(failed_dis_file, fail_districts.map(&:to_csv).join) if fail_districts.length.positive?

puts '................thana seeding .................................'
thanas = CSV.read(Rails.root.join('tmp/csv/upzillah.csv'),
                  headers: true, col_sep: ',', header_converters: :symbol)
fail_thanas = []
fail_thanas << %w[Name BN_Name District_Name]
thanas.each do |row|
  data = row.to_h
  district_id = District.find_by(name: data[:district_name])&.id
  if district_id.present?
    Thana.find_or_create_by!(name: data[:name]) do |thana|
      thana.name = data[:name]
      thana.bn_name = data[:bn_name]
      thana.district_id = district_id
    end
  else
    fail_thanas << row
  end
end
failed_thana_file = 'tmp/csv/failed_thanas.csv'
File.write(failed_thana_file, fail_thanas.map(&:to_csv).join) if fail_thanas.length.positive?

# # # library seeding
# thanas = Thana.all
# thanas.each do |thana|
#   Library.find_or_create_by!(name: "#{thana.name} Library",
#                              bn_name: "#{thana.bn_name} - #{thana.id} গণগ্রন্থাগার",
#                              thana_id: thana.id,
#                              library_type: :district,
#                              username: "library_#{thana.id}",
#                              password: "@Pass123",
#                              ip_address: Faker::Internet.unique.public_ip_v4_address,
#                              phone: "01#{Faker::PhoneNumber.unique.subscriber_number(length: 9)}",
#                              created_by: Staff.admin.first.id,
#                              updated_by: Staff.admin.first.id)
#
# end

# # # create librarian for each library
# libraries = Library.all
# libraries.each do |library|
#   params = {
#     library_id: library.id,
#     library_name: library.name,
#     designation_id: Designation.find_by(title: 'Librarian').id
#   }
#   create_staff(params, :library)
# end
#
puts '................... Creating page types .............................'
page_types = ['About Us', 'Mission', 'Vision', 'History', 'Privacy Policy', 'Terms and Condition',
              'Membership Policy']

page_types.each do |page_type|
  Page.find_or_create_by!(title: page_type,
                          bn_title: "Bangle #{page_type}",
                          description: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
                          bn_description: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
                          is_deletable: false)
end

puts '................. Creating Book Borrow/order Request Statuses .................'

OrderStatus::STATUSES.each do |system_status, other|
  OrderStatus.find_or_create_by!(
    status_key: system_status,
    system_status:,
    admin_status: other[:admin],
    patron_status: other[:patron],
    bn_patron_status: other[:bn_patron_status],
    lms_status: other[:lms_status],
    three_ps_status: other[:three_ps_status]
  )
end

puts '................. Creating Library Card Statuses .................'

CardStatus::STATUSES.each do |status_key, other|
  CardStatus.find_or_create_by!(
    status_key:,
    admin_status: other[:admin],
    patron_status: other[:patron],
    bn_patron_status: other[:bn_patron_status],
    lms_status: other[:lms_status]
  )
end
#
puts '................. Item Types  .................'

item_types = %w[Books Journal Newspaper Binding_news_papers Gazzette Library_bulletin Magazine Reference Reports Online_book]
item_types.each do |item_type|
  ItemType.find_or_create_by!(title: item_type.titleize, option_value: item_type.titleize)
end

# # Creating biblio subject
# biblio_subjects = %w[Drama Mystery Adventure Novel Action]
#
# biblio_subjects.each do |biblio_suject|
#   next if BiblioSubject.find_by(personal_name: biblio_suject)
#
#   BiblioSubject.create!(personal_name: biblio_suject,
#                         bn_personal_name: "Bangle #{biblio_suject}",
#                         slug: biblio_suject.parameterize)
# end
#
puts '................. Creating CirculationStatus Statuses .................'

CirculationStatus::STATUSES.each do |status_key, other|
  CirculationStatus.find_or_create_by!(status_key:,
                                       system_status: status_key,
                                       admin_status: other[:admin],
                                       patron_status: other[:patron],
                                       bn_patron_status: other[:bn_patron_status],
                                       lms_status: other[:lms_status])
end

puts '................. Creating transfer order Statuses .................'

TransferOrderStatus::STATUSES.each do |status_key, other|
  TransferOrderStatus.find_or_create_by!(status_key:,
                                         system_status: status_key,
                                         admin_status: other[:admin],
                                         patron_status: other[:patron],
                                         bn_patron_status: other[:bn_patron_status],
                                         lms_status: other[:lms_status])
end

puts '................. Creating Return Order Statuses .................'

ReturnStatus::STATUSES.each do |status_key, other|
  ReturnStatus.find_or_create_by!(status_key:,
                                  admin_status: other[:admin],
                                  patron_status: other[:patron],
                                  bn_patron_status: other[:bn_patron],
                                  lms_status: other[:lms])
end


puts '................. Creating default library working hour .................'

holidays = ['friday']
working_days = LibraryWorkingDay.week_days.keys - holidays
start_time = '09:00'
end_time = '17:00'
# for weekends
holidays.each do |holiday|
  LibraryWorkingDay.find_or_create_by(week_days: holiday, is_default: true) do |lwd|
    lwd.is_holiday = true
  end
end
working_days.each do |working_day|
  # for working days
  LibraryWorkingDay.find_or_create_by(week_days: working_day, is_default: true) do |lwd|
    lwd.is_holiday = false
    lwd.start_time = start_time
    lwd.end_time = end_time
  end
end

puts '................. Creating Return Circulation Status .................'

ReturnCirculationStatus::STATUSES.each do |status_key, other|
  ReturnCirculationStatus.find_or_create_by!(status_key:,
                                             admin_status: other[:admin],
                                             system_status: status_key,
                                             lms_status: other[:lms])
end

puts '................. Creating Purchase Order Status  .................'

PurchaseOrderStatus::STATUSES.each do |status_key, other|
  PurchaseOrderStatus.find_or_create_by!(status_key:,
                                         admin_status: other[:admin],
                                         system_status: status_key,
                                         publisher_status: other[:publisher],
                                         bn_publisher_status: other[:bn_publisher_status],
                                         is_active: true,
                                         is_deleted: false)
end

puts '................. Creating Department Biblio Item Status  .................'

DepartmentBiblioItemStatus::STATUSES.each do |status_key, other|
  DepartmentBiblioItemStatus.find_or_create_by!(status_key:,
                                                admin_status: other[:admin],
                                                system_status: status_key,
                                                publisher_status: other[:publisher],
                                                bn_publisher_status: other[:bn_publisher_status],
                                                is_active: true,
                                                is_deleted: false)
end
