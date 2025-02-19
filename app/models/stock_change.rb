class StockChange < ApplicationRecord
  belongs_to :stock_changeable, polymorphic: true
  belongs_to :library, optional: true
  belongs_to :biblio, optional: true
  belongs_to :biblio_library, optional: true
  belongs_to :biblio_item, optional: true
  belongs_to :circulation, optional: true

  enum stock_transaction_type:
         {
           initial_stock: 0,
           biblio_item_assign_by_library: 1,
           order_placed: 2,
           cancel_from_order_placed: 3,
           received_a_cancelled_customer_order: 4,
           order_pack: 5,
           order_in_3pl: 6,
           order_delivered: 7,
           returned_at_library: 8,
           borrowed_at_circulation: 9,
           returned_at_circulation: 10,
           rebind_biblio_pending: 11,
           rebind_biblio_completed: 14,
           reject_from_order_placed: 12,
           three_pl_delivered_to_library: 13
         }
end
