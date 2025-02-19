FactoryBot.define do
  factory :suggested_biblio do
    user_id { 1 }
    biblio_id { 1 }
    read_count { 1 }
    borrow_count { 1 }
    points { 1 }
  end
end
