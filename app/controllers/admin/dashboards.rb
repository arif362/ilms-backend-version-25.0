# frozen_string_literal: true

module Admin
  class Dashboards < Admin::Base
    resources :dashboards do
      desc 'admin dashboard'
      params do
        optional :month_filter, type: Date
      end
      get do
        start_of_month = params[:month_filter].present? ? params[:month_filter].beginning_of_month : Date.current.beginning_of_month
        start_of_month = start_of_month.prev_month(5)
        end_of_month = params[:month_filter].present? ? params[:month_filter].end_of_month : Date.current.end_of_month
        total_fine = Invoice.fine.where('DATE(created_at) between ? and ?', start_of_month, end_of_month)
        total_security_money = Payment.security_money.where('DATE(created_at) between ? and ?',
                                                            start_of_month, end_of_month)
        total_security_money_withdraw = Payment.security_money_withdraw.where('DATE(created_at) between ? and ?',
                                                                              start_of_month, end_of_month)
        active_members = Member.where('is_active = ? AND DATE(created_at) between ? and ?', true, start_of_month, end_of_month)
        visitors = LibraryEntryLog.where('DATE(created_at) between ? and ?', start_of_month, end_of_month)

        # total_membership_requests = MembershipRequest.initial.where('DATE(created_at) between ? and ?',
        #                                                             start_of_month, end_of_month).count
        # total_borrowed_biblios = Order.where('DATE(created_at) between ? and ?',
        #                                      start_of_month, end_of_month).count
        # total_inter_library_transfers = LibraryTransferOrder.where('DATE(created_at) between ? and ?',
        #                                                            start_of_month, end_of_month).count
        # total_events = Event.published.where('DATE(end_date) between ? and ?', start_of_month, end_of_month).count
        # total_user_registrations = User.where('DATE(created_at) between ? and ?',
        #                                       start_of_month, end_of_month).count
        # total_biblio_demands = RequestedBiblio.where('DATE(created_at) between ? and ?',
        #                                              start_of_month, end_of_month).count
        # total_physical_reviews = PhysicalReview.where('DATE(created_at) between ? and ?',
        #                                               start_of_month, end_of_month).count
        # total_online_reviews = Review.where('DATE(created_at) between ? and ?',
        #                                     start_of_month, end_of_month).count
        # total_payment = Payment.success.where('DATE(created_at) between ? and ?',
        #                                       start_of_month, end_of_month).sum(&:amount)
        # total_pickups = Order.pickup.where(order_status_id: OrderStatus.get_status(OrderStatus.status_keys[:delivered]).id)
        #                      .where('DATE(created_at) between ? and ?', start_of_month, end_of_month).count
        # total_home_deliveries = Order.home_delivery.where(order_status_id: OrderStatus.get_status(OrderStatus.status_keys[:delivered]).id)
        #                              .where('DATE(created_at) between ? and ?', start_of_month, end_of_month).count

        {
          overview: {
            total_libraries: Library.all.count,
            total_users: User.all.count,
            total_admins: Staff.admin.count,
            total_librarians: Staff.library.count,
            total_biblios: Biblio.paper_books.count,
            total_e_biblios: Biblio.e_books.count
          },
          member_info_count: {
            no_of_active_members: active_members.count,
            no_of_males: active_members.male.count,
            no_of_females: active_members.female.count,
            membership_category_wise_count: {
              general: active_members.general.count,
              student: active_members.student.count,
              child: active_members.child.count
            },
            age_wise_member_count: {
              five_to_ten: active_members.where('age between ? and ?', 5, 10).count,
              eleven_to_seventeen: active_members.where('age between ? and ?', 11, 17).count,
              eighteen_to_thirty: active_members.where('age between ? and ?', 18, 30).count,
              thirty_one_to_fourty: active_members.where('age between ? and ?', 30, 40).count,
              fourty_one_to_sixty: active_members.where('age between ? and ?', 41, 60).count
            }
          },

          visitor_info: {
            no_of_total_visitors: visitors.count,
            no_of_males: visitors.male.count,
            no_of_females: visitors.female.count,
            age_wise_visitors_count: {
              five_to_ten: visitors.where('age between ? and ?', 5, 10).count,
              eleven_to_seventeen: visitors.where('age between ? and ?', 11, 17).count,
              eighteen_to_thirty: visitors.where('age between ? and ?', 18, 30).count,
              thirty_one_to_fourty: visitors.where('age between ? and ?', 30, 40).count,
              fourty_one_to_sixty: visitors.where('age between ? and ?', 41, 60).count
            }
          },
          services_accounts: {
            total_fine_amount: total_fine&.sum(:invoice_amount),
            total_due_amount: total_fine.pending&.sum(:invoice_amount),
            total_paid_amount: total_fine.where(invoice_status: %w[paid partial])&.sum(:invoice_amount),
            total_security_money: total_security_money&.success&.sum(&:amount),
            total_security_money_withdraw: total_security_money_withdraw&.success&.sum(&:amount)
          },
          member_wise_top_ten_libraries: Library.order(total_member_count: :desc).first(10).map do |lib|
                                           { name: lib.name, total_member_count: lib.total_member_count }
                                         end,
          visitor_wise_top_ten_libraries: Library.order(total_guest_count: :desc).first(10).map do |lib|
                                            { name: lib.name, total_guest_count: lib.total_guest_count}
                                          end
          # user_engagement: {
          #   total_membership_requests: total_membership_requests,
          #   total_borrowed_biblios: total_borrowed_biblios,
          #   total_inter_library_transfers: total_inter_library_transfers,
          #   total_events: total_events,
          #   total_user_registrations: total_user_registrations,
          #   total_biblio_demands: total_biblio_demands,
          #   total_physical_reviews: total_physical_reviews,
          #   total_online_reviews: total_online_reviews
          # },
        }
      end
    end
  end
end
