# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_12_02_055440) do
  create_table "active_storage_attachments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "album_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "album_id"
    t.text "caption"
    t.text "bn_caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "video_link"
    t.index ["album_id"], name: "index_album_items_on_album_id"
  end

  create_table "albums", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title", null: false
    t.string "bn_title", null: false
    t.boolean "is_visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id"
    t.bigint "library_id"
    t.bigint "event_id"
    t.integer "status", default: 0
    t.integer "album_type", default: 0
    t.boolean "is_event_album", default: false
    t.datetime "published_at"
    t.integer "total_items", default: 0
    t.boolean "is_album_request", default: false
    t.string "slug"
    t.index ["slug"], name: "index_albums_on_slug", unique: true
  end

  create_table "announcements", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title", null: false
    t.string "bn_title", null: false
    t.integer "notification_type", null: false
    t.text "description", null: false
    t.text "bn_description", null: false
    t.integer "announcement_for", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_published", default: false, null: false
  end

  create_table "audits", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "author_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "biblio_id", null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "responsibility"
    t.index ["author_id"], name: "index_author_biblios_on_author_id"
    t.index ["biblio_id"], name: "index_author_biblios_on_biblio_id"
  end

  create_table "author_requested_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "requested_biblio_id"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authorization_keys", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "token"
    t.datetime "expiry"
    t.string "authable_type"
    t.bigint "authable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["authable_type", "authable_id"], name: "index_authorization_keys_on_authable"
  end

  create_table "authors", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "first_name", null: false
    t.integer "dob"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bn_first_name", null: false
    t.integer "popular_count", default: 0
    t.string "middle_name"
    t.string "bn_middle_name"
    t.string "last_name"
    t.string "bn_last_name"
    t.string "title"
    t.string "bn_title"
    t.integer "updated_by_id"
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.string "pob"
    t.integer "dod"
    t.string "type"
  end

  create_table "banners", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.boolean "is_visible", default: true
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bn_title", null: false
    t.boolean "is_deleted", default: false
    t.bigint "page_type_id", null: false
    t.integer "position", default: 1
    t.index ["page_type_id"], name: "index_banners_on_page_type_id"
  end

  create_table "biblio_classification_sources", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "deleted_at"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.boolean "is_deleted", default: false
  end

  create_table "biblio_editions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "description", size: :long
    t.datetime "deleted_at"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by_id"
    t.boolean "is_deleted", default: false
  end

  create_table "biblio_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "barcode"
    t.string "full_call_number"
    t.string "note"
    t.string "copy_number"
    t.boolean "not_for_loan"
    t.datetime "date_accessioned"
    t.bigint "biblio_id"
    t.integer "library_id"
    t.integer "permanent_library_location_id"
    t.integer "current_library_location_id"
    t.integer "shelving_library_location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price", precision: 10, scale: 4, default: "0.0"
    t.string "accession_no", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "central_accession_no"
    t.integer "item_collection_type"
    t.integer "biblio_item_type", default: 0
    t.index ["biblio_id"], name: "index_biblio_items_on_biblio_id"
  end

  create_table "biblio_libraries", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "available_quantity", default: 0
    t.integer "booked_quantity", default: 0
    t.integer "borrowed_quantity", default: 0
    t.integer "in_transit_quantity", default: 0
    t.integer "not_for_borrow_quantity", default: 0
    t.integer "lost_quantity", default: 0
    t.integer "damaged_quantity", default: 0
    t.bigint "library_id"
    t.bigint "biblio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "on_desk_quantity", default: 0, null: false
    t.integer "return_on_desk_quantity", default: 0, null: false
    t.integer "cancelled_on_desk_quantity", default: 0, null: false
    t.integer "three_pl_quantity", default: 0, null: false
    t.integer "return_3pl_quantity", default: 0, null: false
    t.integer "cancelled_3pl_quantity", default: 0, null: false
    t.integer "in_library_quantity", default: 0
    t.integer "return_in_library_quantity", default: 0
    t.integer "rebind_biblio_quantity", default: 0
    t.integer "delivered_to_library_quantity", default: 0, null: false
    t.integer "return_rct_3pl_quantity", default: 0
    t.index ["biblio_id"], name: "index_biblio_libraries_on_biblio_id"
    t.index ["library_id"], name: "index_biblio_libraries_on_library_id"
  end

  create_table "biblio_library_locations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "biblio_library_id"
    t.integer "quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_location_id"
    t.integer "biblio_id"
    t.index ["biblio_library_id"], name: "index_biblio_library_locations_on_biblio_library_id"
  end

  create_table "biblio_publications", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "deleted_at"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bn_title", null: false
    t.bigint "updated_by_id"
    t.boolean "is_deleted", default: false
  end

  create_table "biblio_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "status_type"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "created_by_id"
    t.integer "updated_by_id"
  end

  create_table "biblio_subject_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "biblio_id"
    t.bigint "biblio_subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biblio_id"], name: "index_biblio_subject_biblios_on_biblio_id"
    t.index ["biblio_subject_id"], name: "index_biblio_subject_biblios_on_biblio_subject_id"
  end

  create_table "biblio_subject_requested_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "requested_biblio_id"
    t.bigint "biblio_subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "biblio_subjects", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "personal_name"
    t.string "bn_personal_name"
    t.string "corporate_name"
    t.string "topical_name"
    t.string "geographic_name"
    t.boolean "is_deleted", default: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
  end

  create_table "biblio_wishlists", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "biblio_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biblio_id"], name: "index_biblio_wishlists_on_biblio_id"
    t.index ["user_id"], name: "index_biblio_wishlists_on_user_id"
  end

  create_table "biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "author_id"
    t.string "title"
    t.string "remainder_of_title"
    t.string "copyright_date"
    t.bigint "item_type_id"
    t.string "isbn"
    t.string "original_cataloging_agency", limit: 25
    t.string "calaloging_language", limit: 40
    t.string "ddc_edition_number", limit: 40
    t.string "ddc_classification_number", limit: 40
    t.string "ddc_item_number", limit: 40
    t.bigint "biblio_edition_id"
    t.bigint "biblio_publication_id"
    t.string "physical_details"
    t.string "other_physical_details"
    t.string "dimentions", limit: 35
    t.string "series_statement_title"
    t.string "series_statement_volume"
    t.string "issn", limit: 15
    t.string "series_statement", limit: 35
    t.string "general_note"
    t.string "bibliography_note"
    t.string "contents_note"
    t.string "topical_term"
    t.string "full_call_number", limit: 35
    t.integer "pages", default: 0
    t.string "age_restriction", limit: 35
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "corporate_name"
    t.string "statement_of_responsibility"
    t.string "edition_statement"
    t.string "place_of_publication"
    t.string "date_of_publication"
    t.string "extent"
    t.string "unique_biblio", default: ""
    t.string "slug", null: false
    t.boolean "is_e_biblio", default: false, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.string "preview_ebook_file_url"
    t.string "full_ebook_file_url"
    t.boolean "is_paper_biblio", default: false
    t.boolean "is_ebook", default: false, null: false
    t.float "average_rating", default: 0.0, null: false
    t.integer "total_reviews", default: 0, null: false
    t.integer "item_number"
    t.string "varing_of_the_title"
    t.integer "price"
    t.string "bn_title"
    t.boolean "is_published", default: true
    t.string "full_pdf_file_url"
    t.index ["author_id"], name: "index_biblios_on_author_id"
    t.index ["biblio_edition_id"], name: "index_biblios_on_biblio_edition_id"
    t.index ["biblio_publication_id"], name: "index_biblios_on_biblio_publication_id"
    t.index ["item_type_id"], name: "index_biblios_on_item_type_id"
    t.index ["title"], name: "index_biblios_on_title"
  end

  create_table "book_transfer_orders", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "biblio_id"
    t.integer "library_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.datetime "arrived_at"
    t.text "note"
  end

  create_table "borrow_policies", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "item_type_id"
    t.integer "category", default: 0
    t.text "note"
    t.integer "checkout_allowed", default: 0
    t.integer "fine_changing_interval", default: 0
    t.integer "overdue", default: 0
    t.boolean "is_renewal_allowed", default: false
    t.integer "renewal_period", default: 0
    t.integer "renewal_times", default: 0
    t.boolean "is_automatic_renewal", default: false
    t.integer "max_renewal_day", default: 0
    t.integer "hold_allowed_daily", default: 0
    t.integer "hold_allowed_total", default: 0
    t.integer "fine_discount", default: 0
    t.integer "status", default: 0
    t.integer "not_loanable", default: 0
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "library_card_id"
    t.bigint "card_status_id"
    t.bigint "changed_by_id"
    t.string "changed_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_status_id"], name: "index_card_status_changes_on_card_status_id"
    t.index ["library_card_id"], name: "index_card_status_changes_on_library_card_id"
  end

  create_table "card_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "admin_status"
    t.string "patron_status"
    t.string "bn_patron_status"
    t.string "lms_status"
    t.integer "status_key"
    t.boolean "is_active"
    t.boolean "is_deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cart_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "cart_id"
    t.bigint "biblio_id"
    t.bigint "biblio_item_id"
    t.decimal "price", precision: 10, scale: 4, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biblio_id"], name: "index_cart_items_on_biblio_id"
    t.index ["biblio_item_id"], name: "index_cart_items_on_biblio_item_id"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
  end

  create_table "carts", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "library_id"
    t.decimal "total", precision: 10, scale: 4, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_id"], name: "index_carts_on_library_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "circulation_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "circulation_id"
    t.bigint "circulation_status_id"
    t.bigint "changed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "changed_by_type"
    t.index ["circulation_id"], name: "index_circulation_status_changes_on_circulation_id"
    t.index ["circulation_status_id"], name: "index_circulation_status_changes_on_circulation_status_id"
  end

  create_table "circulation_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "system_status", null: false
    t.string "admin_status", null: false
    t.string "patron_status", null: false
    t.string "bn_patron_status", null: false
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_key", default: 0
    t.string "lms_status", null: false
  end

  create_table "circulations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "library_id"
    t.bigint "biblio_item_id"
    t.bigint "member_id"
    t.bigint "circulation_status_id"
    t.datetime "return_at"
    t.datetime "returned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.integer "order_id"
    t.integer "return_order_id"
    t.datetime "extended_at"
    t.integer "late_days"
    t.boolean "is_machine", default: false
    t.index ["biblio_item_id"], name: "index_circulations_on_biblio_item_id"
    t.index ["circulation_status_id"], name: "index_circulations_on_circulation_status_id"
    t.index ["library_id"], name: "index_circulations_on_library_id"
    t.index ["member_id"], name: "index_circulations_on_member_id"
  end

  create_table "collections", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.boolean "is_deleted", default: false
  end

  create_table "complains", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "complain_type", default: 0
    t.integer "action_type", default: 0
    t.bigint "library_id"
    t.bigint "user_id"
    t.boolean "is_deleted", default: false
    t.boolean "is_anonymous", default: false
    t.text "description", collation: "utf8mb4_bin"
    t.text "reply", collation: "utf8mb4_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "subject"
    t.string "email"
    t.datetime "closed_or_resolved_at"
    t.integer "closed_or_resolved_by_staff_id"
    t.text "action_note"
    t.index ["library_id"], name: "index_complains_on_library_id"
    t.index ["user_id"], name: "index_complains_on_user_id"
  end

  create_table "dep_biblio_item_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "department_biblio_item_id"
    t.bigint "department_biblio_item_status_id"
    t.integer "changed_by_id"
    t.string "changed_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_biblio_item_id"], name: "index_dbis_on_dbi_id"
    t.index ["department_biblio_item_status_id"], name: "index_dbis_changes_on_dbi_id"
  end

  create_table "department_biblio_item_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "system_status"
    t.string "admin_status"
    t.string "publisher_status"
    t.string "bn_publisher_status"
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.integer "status_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "department_biblio_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "goods_receipt_id"
    t.bigint "publisher_biblio_id"
    t.bigint "library_id"
    t.bigint "po_line_item_id"
    t.string "central_accession_no"
    t.bigint "department_biblio_item_status_id"
    t.datetime "deleted_at"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "biblio_item_id"
    t.integer "distribution_id"
    t.boolean "is_existing_item"
    t.index ["department_biblio_item_status_id"], name: "index_dbis_on_dbi_status_id"
    t.index ["goods_receipt_id"], name: "index_department_biblio_items_on_goods_receipt_id"
    t.index ["library_id"], name: "index_department_biblio_items_on_library_id"
    t.index ["po_line_item_id"], name: "index_department_biblio_items_on_po_line_item_id"
    t.index ["publisher_biblio_id"], name: "index_department_biblio_items_on_publisher_biblio_id"
  end

  create_table "designations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
  end

  create_table "distributions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
    t.integer "item_count"
  end

  create_table "districts", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "bn_name"
    t.bigint "division_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
    t.index ["division_id"], name: "index_districts_on_division_id"
  end

  create_table "divisions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "bn_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
  end

  create_table "document_categories", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "bn_name"
    t.string "description"
    t.string "bn_description"
    t.integer "document_category_id"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "e_books", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "book_type", default: 0
    t.string "title"
    t.string "author"
    t.string "author_url"
    t.string "book_url"
    t.integer "year"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "publisher"
    t.boolean "is_published", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ebooks", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "flip_book_location_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_libraries", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "library_id"
    t.bigint "event_id"
    t.integer "total_registered", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_libraries_on_event_id"
    t.index ["library_id"], name: "index_event_libraries_on_library_id"
  end

  create_table "event_registrations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "email"
    t.string "address"
    t.integer "identity_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "father_name"
    t.string "mother_name"
    t.string "profession"
    t.bigint "event_id"
    t.bigint "library_id"
    t.string "name"
    t.string "phone"
    t.string "identity_number"
    t.string "membership_category"
    t.string "competition_name"
    t.integer "participate_group"
    t.integer "status", default: 0
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "rejection_note"
    t.boolean "is_winner", default: false
    t.string "winner_position"
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["library_id"], name: "index_event_registrations_on_library_id"
    t.index ["user_id"], name: "index_event_registrations_on_user_id"
  end

  create_table "events", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.string "bn_title"
    t.text "details", size: :long, collation: "utf8mb4_bin"
    t.text "bn_details", size: :long, collation: "utf8mb4_bin"
    t.boolean "is_published", default: false
    t.boolean "is_deleted", default: false
    t.boolean "is_all_library", default: false
    t.boolean "is_registerable", default: false
    t.date "start_date"
    t.date "end_date"
    t.time "start_time"
    t.time "end_time"
    t.integer "total_registered", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.boolean "is_local", default: false
    t.text "registration_fields"
    t.datetime "registration_last_date"
    t.integer "created_by"
    t.integer "updated_by"
    t.string "phone"
    t.string "email"
    t.text "competition_info"
  end

  create_table "extend_requests", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "library_id"
    t.bigint "circulation_id"
    t.integer "status", default: 0
    t.string "reason"
    t.bigint "member_id"
    t.bigint "order_id"
    t.bigint "created_by_id"
    t.string "created_by_type"
    t.bigint "updated_by_id"
    t.string "updated_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "failed_searches", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "keyword"
    t.integer "search_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faq_categories", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.string "title"
    t.string "bn_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faqs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "faq_category_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.text "question"
    t.text "bn_question"
    t.text "answer"
    t.text "bn_answer"
    t.boolean "is_published", default: false
    t.integer "position", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goods_receipts", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "purchase_order_id"
    t.bigint "publisher_id"
    t.bigint "memorandum_publisher_id"
    t.bigint "publisher_biblio_id"
    t.bigint "po_line_item_id"
    t.integer "quantity", default: 0
    t.float "price", default: 0.0
    t.integer "sub_total", default: 0
    t.string "bar_code"
    t.string "purchase_code"
    t.integer "created_by_id"
    t.integer "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memorandum_publisher_id"], name: "index_goods_receipts_on_memorandum_publisher_id"
    t.index ["po_line_item_id"], name: "index_goods_receipts_on_po_line_item_id"
    t.index ["publisher_biblio_id"], name: "index_goods_receipts_on_publisher_biblio_id"
    t.index ["publisher_id"], name: "index_goods_receipts_on_publisher_id"
    t.index ["purchase_order_id"], name: "index_goods_receipts_on_purchase_order_id"
  end

  create_table "guests", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.integer "gender"
    t.date "dob"
    t.integer "library_id", null: false
    t.string "token", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_guests_on_token"
  end

  create_table "homepage_sliders", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.boolean "is_visible", default: true
    t.string "link"
    t.integer "serial_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
  end

  create_table "ils_lms_reports", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "lms_report_id", null: false
    t.bigint "ils_report_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ils_report_id"], name: "index_ils_lms_reports_on_ils_report_id"
    t.index ["lms_report_id"], name: "index_ils_lms_reports_on_lms_report_id"
  end

  create_table "ils_reports", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "biblio_bangla_new_item", default: 0
    t.integer "biblio_english_new_item", default: 0
    t.integer "biblio_other_new_item", default: 0
    t.integer "biblio_new_item_total", default: 0
    t.integer "biblio_bangla_last_month_total", default: 0
    t.integer "biblio_english_last_month_total", default: 0
    t.integer "biblio_other_last_month_total", default: 0
    t.integer "biblio_last_month_total", default: 0
    t.integer "biblio_bangla_total_item", default: 0
    t.integer "biblio_english_total_item", default: 0
    t.integer "biblio_other_total_item", default: 0
    t.integer "biblio_total_item_total", default: 0
    t.integer "biblio_bangla_current_item", default: 0
    t.integer "biblio_english_current_item", default: 0
    t.integer "biblio_other_current_item", default: 0
    t.integer "biblio_current_item_total", default: 0
    t.integer "bind_paper_bangla", default: 0
    t.integer "bind_paper_english", default: 0
    t.integer "bind_magazine_bangla", default: 0
    t.integer "bind_magazine_english", default: 0
    t.integer "book_reader_total", default: 0
    t.integer "paper_magazine_reader_total", default: 0
    t.integer "book_paper_magazine_reader_total", default: 0
    t.integer "book_paper_magazine_reader_male_total", default: 0
    t.integer "book_paper_magazine_reader_female_total", default: 0
    t.integer "book_paper_magazine_reader_child_total", default: 0
    t.integer "book_paper_magazine_reader_other_total", default: 0
    t.integer "reference_question_male", default: 0
    t.integer "reference_question_female", default: 0
    t.integer "reference_question_child", default: 0
    t.integer "reference_question_total", default: 0
    t.integer "mobile_library_reader_male", default: 0
    t.integer "mobile_library_reader_female", default: 0
    t.integer "mobile_library_reader_child", default: 0
    t.integer "mobile_library_reader_other", default: 0
    t.integer "mobile_library_reader_total", default: 0
    t.text "event", size: :long, collation: "utf8mb4_bin"
    t.integer "lending_system_total", default: 0
    t.integer "lost_total_lost", default: 0
    t.integer "lost_total_lost_amount", default: 0
    t.integer "discarded_lost_book_total_lost", default: 0
    t.integer "discarded_lost_book_total_lost_amount", default: 0
    t.integer "burn_book_total", default: 0
    t.integer "burn_book_total_amount", default: 0
    t.integer "pruned_book_total", default: 0
    t.integer "pruned_book_total_amount", default: 0
    t.integer "discarded_pruned_book_total", default: 0
    t.integer "discarded_pruned_book_total_amount", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "printer_wb_working", default: 0
    t.integer "printer_wb_not_working", default: 0
    t.integer "printer_c_working", default: 0
    t.integer "printer_c_not_working", default: 0
    t.integer "cctv_working_working", default: 0
    t.integer "cctv_not_working", default: 0
    t.integer "photo_copy_working", default: 0
    t.integer "photo_copy_not_working", default: 0
    t.integer "registered_private_library", default: 0
    t.integer "robi_cafe", default: 0
    t.integer "library_internet_user", default: 0
    t.integer "library_computers", default: 0
    t.integer "lending_system_issue_book", default: 0
    t.integer "lending_system_issue_book_return", default: 0
    t.date "month"
    t.text "papers_bangla"
    t.text "papers_english"
    t.text "magazine_bangla"
    t.text "magazine_english"
    t.check_constraint "json_valid(`event`)", name: "event"
  end

  create_table "int_lib_extensions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "library_transfer_order_id"
    t.bigint "sender_library_id"
    t.bigint "receiver_library_id"
    t.datetime "extend_end_date"
    t.integer "status", default: 0
    t.bigint "created_by_id"
    t.string "created_by_type"
    t.bigint "updated_by_id"
    t.string "updated_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "intl_research_gateways", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.boolean "is_deleted"
    t.boolean "is_published"
    t.integer "created_by"
    t.integer "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "invoiceable_id", null: false
    t.string "invoiceable_type", null: false
    t.integer "invoice_type", null: false
    t.integer "invoice_status", default: 0, null: false
    t.integer "invoice_amount", default: 0, null: false
    t.bigint "user_id", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shipping_charge", default: 0, null: false
    t.decimal "shipping_charge_vat", precision: 6, scale: 2, default: "0.0"
  end

  create_table "invoices_payments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "payment_id"
    t.integer "invoice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_types", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.string "option_value"
  end

  create_table "key_people", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "bn_name"
    t.string "designation"
    t.string "bn_designation"
    t.text "description"
    t.text "bn_description"
    t.integer "position"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
  end

  create_table "libraries", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.text "description"
    t.text "bn_description"
    t.string "phone"
    t.string "bn_name", null: false
    t.integer "library_type", null: false
    t.string "lat"
    t.string "long"
    t.string "address"
    t.string "bn_address"
    t.string "ip_address", null: false
    t.string "code", null: false
    t.integer "total_member_count", default: 0
    t.integer "total_user_count", default: 0
    t.integer "total_guest_count", default: 0
    t.bigint "created_by", null: false
    t.bigint "updated_by", null: false
    t.bigint "thana_id"
    t.string "username"
    t.string "password_hash"
    t.integer "current_borrow_count", default: 0
    t.string "email"
    t.bigint "district_id"
    t.boolean "is_default_working_days", default: true
    t.text "map_iframe"
    t.integer "redx_pickup_store_id"
    t.integer "redx_area_id"
    t.index ["district_id"], name: "index_libraries_on_district_id"
    t.index ["thana_id"], name: "index_libraries_on_thana_id"
  end

  create_table "library_cards", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "member_id"
    t.integer "issued_library_id"
    t.string "name"
    t.datetime "issue_date"
    t.datetime "expire_date"
    t.integer "membership_category"
    t.string "barcode"
    t.string "recipient_name"
    t.string "recipient_phone"
    t.integer "address_type"
    t.integer "division_id"
    t.integer "district_id"
    t.integer "thana_id"
    t.integer "card_status_id"
    t.integer "delivery_type", default: 0
    t.boolean "is_active", default: true
    t.boolean "is_lost", default: false
    t.boolean "is_damaged", default: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "delivery_address"
    t.integer "pay_type", default: 0
    t.integer "reference_card_id"
    t.string "smart_card_number"
    t.integer "printing_library_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "created_by_type"
    t.string "updated_by_type"
    t.boolean "is_expired"
    t.datetime "expired_at"
    t.string "delivery_area"
    t.integer "delivery_area_id"
    t.index ["barcode"], name: "index_library_cards_on_barcode"
    t.index ["member_id"], name: "index_library_cards_on_member_id"
  end

  create_table "library_entries", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "entered_by_type"
    t.bigint "entered_by_id"
    t.string "stored_otp"
    t.datetime "expiry_date"
    t.datetime "in_time"
    t.datetime "out_time"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "library_entry_logs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "entryable_type", null: false
    t.bigint "entryable_id", null: false
    t.integer "library_id", null: false
    t.text "services"
    t.string "name"
    t.integer "gender"
    t.integer "age"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "thana_id"
    t.bigint "district_id"
    t.index ["entryable_type", "entryable_id"], name: "index_library_entry_logs_on_entryable"
  end

  create_table "library_locations", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "code"
    t.bigint "library_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.string "name"
    t.integer "location_type"
    t.index ["library_id"], name: "index_library_locations_on_library_id"
  end

  create_table "library_newspapers", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "library_id"
    t.integer "newspaper_id"
    t.integer "language"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.boolean "is_continue", default: false
    t.integer "created_by"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_binding"
  end

  create_table "library_transfer_orders", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "biblio_id"
    t.bigint "user_id"
    t.integer "sender_library_id"
    t.integer "receiver_library_id"
    t.bigint "transfer_order_status_id"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transferable_type"
    t.integer "transferable_id"
    t.integer "order_type", default: 0
    t.datetime "return_at"
    t.string "reference_no"
    t.datetime "start_date"
    t.datetime "end_date"
    t.index ["biblio_id"], name: "index_library_transfer_orders_on_biblio_id"
    t.index ["transfer_order_status_id"], name: "index_library_transfer_orders_on_transfer_order_status_id"
    t.index ["user_id"], name: "index_library_transfer_orders_on_user_id"
  end

  create_table "library_working_days", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "library_id"
    t.integer "week_days"
    t.boolean "is_default", default: false
    t.boolean "is_holiday", default: false
    t.string "start_time"
    t.string "end_time"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "biblio_id"
    t.bigint "biblio_item_id"
    t.decimal "price", precision: 10, scale: 4, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.index ["biblio_id"], name: "index_line_items_on_biblio_id"
    t.index ["biblio_item_id"], name: "index_line_items_on_biblio_item_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "lms_logs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.text "api_response", size: :long, collation: "utf8mb4_bin"
    t.string "user_able_type"
    t.integer "user_able_id"
    t.boolean "status"
    t.text "api_request", size: :long, collation: "utf8mb4_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "json_valid(`api_request`)", name: "api_request"
    t.check_constraint "json_valid(`api_response`)", name: "api_response"
  end

  create_table "lms_reports", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "library_id"
    t.datetime "month"
    t.integer "working_days"
    t.integer "biblio_bangla_last_month_total"
    t.integer "biblio_bangla_new_item"
    t.integer "biblio_bangla_total_item"
    t.integer "biblio_bangla_current_item"
    t.integer "biblio_english_last_month_total"
    t.integer "biblio_english_new_item"
    t.integer "biblio_english_total_item"
    t.integer "biblio_english_current_item"
    t.integer "biblio_other_last_month_total"
    t.integer "biblio_other_new_item"
    t.integer "biblio_other_total_item"
    t.integer "biblio_other_current_item"
    t.text "papers_bangla"
    t.text "papers_english"
    t.text "magazine_bangla"
    t.text "magazine_english"
    t.integer "mobile_library_reader_male"
    t.integer "mobile_library_reader_female"
    t.integer "mobile_library_reader_child"
    t.integer "mobile_library_reader_other"
    t.integer "book_reader_male"
    t.integer "book_reader_female"
    t.integer "book_reader_child"
    t.integer "book_reader_other"
    t.integer "paper_magazine_reader_male"
    t.integer "paper_magazine_reader_female"
    t.integer "paper_magazine_reader_child"
    t.integer "paper_magazine_reader_other"
    t.integer "reference_question_male"
    t.integer "reference_question_female"
    t.integer "reference_question_child"
    t.text "event_current_month"
    t.text "event_upcoming_2month"
    t.text "event", size: :long, collation: "utf8mb4_bin"
    t.text "inspection_inspector_name"
    t.datetime "inspection_date"
    t.text "inspection_purpose"
    t.text "inspection_notes"
    t.integer "lending_system_male"
    t.integer "lending_system_female"
    t.integer "lending_system_child"
    t.integer "lending_system_issue_book"
    t.integer "lending_system_issue_book_return"
    t.text "lost_start_end_year"
    t.integer "lost_total_lost"
    t.text "lost_total_lost_in_text"
    t.float "lost_amount"
    t.text "discarded_lost_book_start_end_year"
    t.integer "discarded_lost_book_total_lost"
    t.text "discarded_lost_lost_total_lost_in_text"
    t.float "discarded_lost_amount"
    t.integer "burn_discarded_lost_book_total_burn"
    t.float "burn_discarded_lost_book_amount"
    t.text "pruned_book_start_end_year"
    t.float "pruned_book_total"
    t.text "pruned_book_total_in_text"
    t.float "pruned_book_amount"
    t.text "discarded_pruned_book_start_end_year"
    t.float "discarded_pruned_book_total"
    t.text "discarded_pruned_book_total_in_text"
    t.float "discarded_pruned_book_amount"
    t.text "staff_ids"
    t.text "present_main_staff_ids"
    t.text "edited_fields_default_values", collation: "utf8mb4_bin"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.string "created_by_type"
    t.string "updated_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "event_participants", collation: "utf8mb4_bin"
    t.text "event_winners", collation: "utf8mb4_bin"
    t.text "bind_paper_bangla", collation: "utf8mb4_bin"
    t.text "bind_paper_english", collation: "utf8mb4_bin"
    t.text "bind_magazine_bangla", collation: "utf8mb4_bin"
    t.text "bind_magazine_english", collation: "utf8mb4_bin"
    t.integer "biblio_bangla_lost_total"
    t.integer "biblio_bangla_discarded_total"
    t.integer "biblio_english_lost_total"
    t.integer "biblio_english_discarded_total"
    t.integer "biblio_other_lost_total"
    t.integer "biblio_other_discarded_total"
    t.boolean "land_record"
    t.string "library_building"
    t.float "library_area"
    t.integer "library_room"
    t.string "library_land_comment"
    t.integer "computer_active"
    t.integer "computer_inactive"
    t.integer "computer_server_active"
    t.integer "computer_server_inactive"
    t.integer "printer_bw_active"
    t.integer "printer_bw_inactive"
    t.integer "printer_color_active"
    t.integer "printer_color_inactive"
    t.integer "scanner_active"
    t.integer "scanner_inactive"
    t.integer "cc_camera_active"
    t.integer "cc_camera_inactive"
    t.integer "photocopier_active"
    t.integer "photocopier_inactive"
    t.string "device_remarks"
    t.boolean "office_telephone_exist"
    t.integer "quantity_of_office_telephone"
    t.boolean "accommodation_telephone_exist"
    t.integer "quantity_of_accommodation_telephone"
    t.boolean "fax_exist"
    t.integer "quantity_of_fax"
    t.boolean "transport_exist"
    t.integer "quantity_of_transport"
    t.string "connection_remarks"
    t.boolean "photocopy_use_office"
    t.boolean "photocopy_use_user"
    t.boolean "internet_connect"
    t.string "internet_speed"
    t.boolean "solar_system"
    t.integer "solar_system_active"
    t.integer "solar_system_inactive"
    t.string "ict_equipment_comment"
    t.integer "non_govt_library"
    t.text "development_project"
    t.check_constraint "json_valid(`event`)", name: "event"
  end

  create_table "lost_damaged_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "member_id"
    t.integer "library_id", null: false
    t.integer "biblio_item_id", null: false
    t.integer "circulation_id"
    t.integer "request_type", default: 0
    t.integer "status", default: 0
    t.integer "biblio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "created_by_type"
    t.string "updated_by_type"
  end

  create_table "lto_line_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "library_transfer_order_id"
    t.integer "biblio_id"
    t.integer "biblio_item_id"
    t.integer "price", default: 0
    t.integer "quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "library_id"
    t.bigint "membership_request_id"
    t.string "mother_name"
    t.string "father_Name"
    t.integer "identity_type", default: 0
    t.string "identity_number"
    t.string "present_address"
    t.string "permanent_address"
    t.string "profession"
    t.string "institute_name"
    t.boolean "is_active", default: false
    t.integer "membership_category", default: 0
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "expire_date"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gender"
    t.integer "present_division_id"
    t.integer "present_district_id"
    t.integer "present_thana_id"
    t.integer "permanent_division_id"
    t.integer "permanent_district_id"
    t.integer "permanent_thana_id"
    t.string "institute_address"
    t.string "student_class"
    t.string "student_section"
    t.string "student_id"
    t.string "created_by_type"
    t.string "updated_by_type"
    t.integer "age"
    t.integer "staff_id"
    t.index ["library_id"], name: "index_members_on_library_id"
    t.index ["membership_request_id"], name: "index_members_on_membership_request_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "membership_requests", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "request_type", default: 0
    t.integer "status", default: 0
    t.integer "request_detail_id"
    t.bigint "invoice_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.string "created_by_type"
    t.string "updated_by_type"
  end

  create_table "memorandum_publishers", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "publisher_id"
    t.bigint "memorandum_id"
    t.string "track_no"
    t.boolean "is_shortlisted", default: false
    t.boolean "is_final_submitted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
  end

  create_table "memorandums", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "memorandum_no", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.string "tender_session", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id"
    t.boolean "is_deleted", default: false
    t.string "memorandum_details"
    t.boolean "is_visible", default: true
    t.date "last_submission_date"
    t.text "description"
  end

  create_table "money_request_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "security_money_request_id", null: false
    t.integer "created_by_id"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["security_money_request_id"], name: "index_money_request_status_changes_on_security_money_request_id"
  end

  create_table "newspapers", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "is_published", default: false
    t.integer "created_by"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "category"
    t.integer "language"
    t.string "bn_name"
    t.index ["slug"], name: "index_newspapers_on_slug", unique: true
  end

  create_table "notices", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.boolean "is_published", default: false
    t.datetime "published_date"
    t.bigint "published_by_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bn_title"
    t.text "bn_description"
    t.boolean "is_deleted", default: false
    t.string "slug"
    t.integer "notice_type", default: 0
    t.index ["slug"], name: "index_notices_on_slug", unique: true
  end

  create_table "notifications", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "notificationable_type"
    t.bigint "notificationable_id"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.text "message"
    t.text "message_bn"
    t.boolean "is_read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "bn_title"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["notificationable_type", "notificationable_id"], name: "index_notifications_on_notificationable"
  end

  create_table "order_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "order_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "changed_by_id"
    t.string "changed_by_type"
  end

  create_table "order_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "system_status", null: false
    t.string "admin_status", null: false
    t.string "patron_status", null: false
    t.string "bn_patron_status", null: false
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_key", null: false
    t.string "lms_status", null: false
    t.string "three_ps_status"
  end

  create_table "orders", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "library_id"
    t.bigint "division_id"
    t.bigint "district_id"
    t.bigint "thana_id"
    t.text "address"
    t.decimal "total", precision: 10, scale: 4, default: "0.0"
    t.integer "delivery_type", default: 0
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recipient_name"
    t.string "recipient_phone"
    t.integer "address_type", default: 0
    t.integer "order_status_id"
    t.integer "pay_status", default: 0
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.integer "pay_type", default: 0
    t.integer "pick_up_library_id"
    t.string "delivery_area"
    t.integer "delivery_area_id"
    t.string "tracking_id"
    t.integer "pickup_store_id"
    t.index ["district_id"], name: "index_orders_on_district_id"
    t.index ["division_id"], name: "index_orders_on_division_id"
    t.index ["library_id"], name: "index_orders_on_library_id"
    t.index ["thana_id"], name: "index_orders_on_thana_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "other_library_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "permanent_library_id"
    t.bigint "current_library_id"
    t.bigint "biblio_item_id"
    t.bigint "biblio_id"
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_other_library_biblios_on_trackable"
  end

  create_table "otps", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "otp_able_type"
    t.integer "otp_able_id"
    t.datetime "expiry"
    t.datetime "send_interval_time"
    t.boolean "is_used", default: false
    t.boolean "is_otp_verified", default: false
    t.string "phone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "otp_type"
    t.index ["phone"], name: "index_otps_on_phone"
  end

  create_table "page_types", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", size: :long, null: false
    t.string "bn_title", null: false
    t.string "slug", null: false
    t.text "bn_description", size: :long, null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_deletable", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "payment_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.bigint "invoice_id"
    t.integer "amount", default: 0, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "trx_id"
    t.integer "member_id"
    t.integer "transaction_type", default: 0
    t.integer "user_id"
    t.string "created_by_type"
    t.string "updated_by_type"
    t.integer "purpose", default: 0
  end

  create_table "phone_change_requests", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "phone"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_phone_change_requests_on_user_id"
  end

  create_table "physical_reviews", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "biblio_item_id"
    t.text "review_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
  end

  create_table "po_line_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "purchase_order_id"
    t.bigint "publisher_biblio_id"
    t.integer "quantity", default: 0
    t.float "price", default: 0.0
    t.datetime "received_at"
    t.integer "sub_total", default: 0
    t.string "bar_code"
    t.string "purchase_code"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "received_quantity", default: 0
    t.index ["publisher_biblio_id"], name: "index_po_line_items_on_publisher_biblio_id"
    t.index ["purchase_order_id"], name: "index_po_line_items_on_purchase_order_id"
  end

  create_table "po_payments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "payment_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "form_of_payment"
    t.bigint "invoice_id", null: false
    t.integer "amount", default: 0, null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "po_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "purchase_order_id"
    t.bigint "purchase_order_status_id"
    t.integer "changed_by_id"
    t.string "changed_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_order_id"], name: "index_po_status_changes_on_purchase_order_id"
    t.index ["purchase_order_status_id"], name: "index_po_status_changes_on_purchase_order_status_id"
  end

  create_table "preferences", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "max_borrow", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publisher_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "memorandum_publisher_id"
    t.string "author_name"
    t.string "title"
    t.string "publisher_name"
    t.string "publisher_phone"
    t.string "publisher_address"
    t.date "publication_date"
    t.string "publisher_website"
    t.string "edition"
    t.string "print"
    t.integer "total_page", default: 0
    t.string "subject"
    t.float "price", default: 0.0
    t.string "isbn"
    t.integer "paper_type", default: 0
    t.integer "binding_type", default: 0
    t.string "comment"
    t.boolean "is_foreign", default: false
    t.boolean "is_shortlisted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
  end

  create_table "publishers", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "publication_name"
    t.string "name"
    t.string "author_name"
    t.string "address"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "track_no"
    t.string "organization_phone"
    t.string "organization_email"
    t.index ["user_id"], name: "index_publishers_on_user_id"
  end

  create_table "purchase_order_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "system_status"
    t.string "admin_status"
    t.string "publisher_status"
    t.string "bn_publisher_status"
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.integer "status_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchase_orders", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "memorandum_id"
    t.bigint "publisher_id"
    t.bigint "memorandum_publisher_id"
    t.bigint "purchase_order_status_id", default: 1
    t.datetime "last_submission_date"
    t.integer "created_by_id"
    t.integer "created_by_type"
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memorandum_id"], name: "index_purchase_orders_on_memorandum_id"
    t.index ["memorandum_publisher_id"], name: "index_purchase_orders_on_memorandum_publisher_id"
    t.index ["publisher_id"], name: "index_purchase_orders_on_publisher_id"
    t.index ["purchase_order_status_id"], name: "index_purchase_orders_on_purchase_order_status_id"
  end

  create_table "rebind_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "biblio_id"
    t.integer "library_id"
    t.integer "biblio_item_id"
    t.integer "status", default: 0
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_details", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "phone"
    t.integer "gender", default: 0
    t.date "dob"
    t.string "mother_name"
    t.string "father_Name"
    t.boolean "status", default: true
    t.integer "identity_type", default: 0
    t.string "identity_number"
    t.string "present_address"
    t.string "permanent_address"
    t.bigint "requested_by_id"
    t.bigint "library_id", null: false
    t.string "profession"
    t.string "institute_name"
    t.integer "membership_category", default: 0
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "present_division_id"
    t.integer "present_district_id"
    t.integer "present_thana_id"
    t.integer "permanent_division_id"
    t.integer "permanent_district_id"
    t.integer "permanent_thana_id"
    t.string "institute_address"
    t.string "student_class"
    t.string "student_section"
    t.string "student_id"
    t.integer "card_delivery_type", default: 0
    t.integer "delivery_address_type", default: 0
    t.string "recipient_name"
    t.string "recipient_phone"
    t.integer "delivery_division_id"
    t.integer "delivery_district_id"
    t.integer "delivery_thana_id"
    t.string "delivery_address"
    t.text "note"
    t.string "created_by_type"
    t.string "updated_by_type"
  end

  create_table "requested_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "biblio_title"
    t.text "authors_name"
    t.text "biblio_subjects_name"
    t.string "isbn"
    t.string "publication"
    t.string "edition"
    t.string "volume"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.string "updated_by_type"
    t.integer "created_by_id"
    t.string "created_by_type"
    t.integer "library_id"
    t.datetime "possible_availability_at"
  end

  create_table "return_circulation_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "return_circulation_transfer_id", null: false
    t.integer "return_circulation_status_id", null: false
    t.bigint "changed_by_id"
    t.string "changed_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "return_circulation_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "system_status", null: false
    t.string "admin_status", null: false
    t.string "lms_status", null: false
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.integer "status_key", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "return_circulation_transfers", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "biblio_item_id"
    t.bigint "user_id"
    t.bigint "circulation_id"
    t.bigint "sender_library_id"
    t.bigint "receiver_library_id"
    t.bigint "updated_by_id"
    t.string "updated_by_type"
    t.bigint "created_by_id"
    t.string "created_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "return_circulation_status_id"
  end

  create_table "return_items", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "biblio_id"
    t.bigint "biblio_item_id"
    t.bigint "line_item_id"
    t.bigint "return_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "circulation_id"
    t.integer "late_days", default: 0
    t.integer "fine_sub_total", default: 0
  end

  create_table "return_orders", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "delivery_type"
    t.integer "address_type"
    t.text "address"
    t.integer "division_id"
    t.integer "district_id"
    t.integer "thana_id"
    t.text "note"
    t.integer "return_status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
    t.integer "total_fine", default: 0
    t.integer "return_type"
    t.string "delivery_area"
    t.integer "delivery_area_id"
  end

  create_table "return_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "return_order_id"
    t.integer "return_status_id"
    t.bigint "changed_by_id"
    t.string "changed_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "return_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "status_key"
    t.string "admin_status"
    t.string "lms_status"
    t.string "patron_status"
    t.string "bn_patron_status"
    t.boolean "is_active"
    t.boolean "is_deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "text"
    t.integer "status", default: 0
    t.integer "rating", default: 0
    t.bigint "biblio_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biblio_id"], name: "index_reviews_on_biblio_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "roles", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "title"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.text "permission_codes"
  end

  create_table "saved_addresses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.bigint "user_id"
    t.bigint "division_id"
    t.bigint "district_id"
    t.bigint "thana_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recipient_name"
    t.string "recipient_phone"
    t.integer "address_type", default: 0
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.string "created_by_type"
    t.string "updated_by_type"
    t.string "delivery_area"
    t.integer "delivery_area_id"
    t.index ["district_id"], name: "index_saved_addresses_on_district_id"
    t.index ["division_id"], name: "index_saved_addresses_on_division_id"
    t.index ["thana_id"], name: "index_saved_addresses_on_thana_id"
    t.index ["user_id"], name: "index_saved_addresses_on_user_id"
  end

  create_table "security_money_requests", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "library_id", null: false
    t.integer "status", default: 0
    t.integer "payment_method", default: 0
    t.integer "amount", default: 0
    t.string "note"
    t.integer "last_updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "created_by_type"
    t.bigint "created_by_id"
    t.string "updated_by_type"
    t.bigint "updated_by_id"
    t.index ["library_id"], name: "index_security_money_requests_on_library_id"
    t.index ["user_id"], name: "index_security_money_requests_on_user_id"
  end

  create_table "security_moneys", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "amount", null: false
    t.integer "member_id", null: false
    t.integer "library_id"
    t.integer "invoice_id"
    t.integer "payment_method"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "created_by_type"
    t.string "updated_by_type"
  end

  create_table "sms_logs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "sms_type"
    t.text "api_request", size: :long, collation: "utf8mb4_bin"
    t.text "api_response", size: :long, collation: "utf8mb4_bin"
    t.string "content", null: false
    t.string "phone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_sms_logs_on_phone"
    t.check_constraint "json_valid(`api_request`)", name: "api_request"
    t.check_constraint "json_valid(`api_response`)", name: "api_response"
  end

  create_table "staffs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_hash"
    t.string "phone"
    t.boolean "is_active", default: true
    t.bigint "library_id"
    t.bigint "role_id"
    t.bigint "designation_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
    t.integer "staff_type"
    t.boolean "is_library_head", default: false
    t.integer "gender", default: 0
    t.datetime "dob"
    t.datetime "joining_date"
    t.string "staff_class"
    t.string "staff_grade"
    t.string "sanctioned_post"
    t.integer "joining_library_id"
    t.boolean "is_ils_system_admin", default: false
    t.boolean "is_lms_system_admin", default: false
    t.datetime "retired_date"
    t.index ["designation_id"], name: "index_staffs_on_designation_id"
    t.index ["library_id"], name: "index_staffs_on_library_id"
    t.index ["role_id"], name: "index_staffs_on_role_id"
  end

  create_table "stock_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "stock_transaction_type", null: false
    t.integer "available_quantity", default: 0
    t.integer "booked_quantity", default: 0
    t.integer "borrowed_quantity", default: 0
    t.integer "three_pl_quantity", default: 0
    t.integer "not_for_borrow_quantity", default: 0
    t.integer "lost_quantity", default: 0
    t.integer "damaged_quantity", default: 0
    t.integer "on_desk_quantity", default: 0
    t.integer "return_on_desk_quantity", default: 0
    t.integer "cancelled_on_desk_quantity", default: 0
    t.integer "return_3pl_quantity", default: 0
    t.integer "cancelled_3pl_quantity", default: 0
    t.integer "in_library_quantity", default: 0
    t.integer "return_in_library_quantity", default: 0
    t.integer "available_quantity_change", default: 0
    t.integer "booked_quantity_change", default: 0
    t.integer "borrowed_quantity_change", default: 0
    t.integer "three_pl_quantity_change", default: 0
    t.integer "not_for_borrow_quantity_change", default: 0
    t.integer "lost_quantity_change", default: 0
    t.integer "damaged_quantity_change", default: 0
    t.integer "on_desk_quantity_change", default: 0
    t.integer "return_on_desk_quantity_change", default: 0
    t.integer "in_library_quantity_change", default: 0
    t.integer "return_in_library_quantity_change", default: 0
    t.integer "cancelled_on_desk_quantity_change", default: 0
    t.integer "return_3pl_quantity_change", default: 0
    t.integer "cancelled_3pl_quantity_change", default: 0
    t.integer "library_id"
    t.integer "biblio_library_id"
    t.integer "biblio_id"
    t.integer "stock_changeable_id"
    t.string "stock_changeable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.bigint "biblio_item_id"
    t.integer "circulation_id"
    t.integer "rebind_biblio_quantity", default: 0
    t.integer "rebind_biblio_quantity_change", default: 0
    t.integer "delivered_to_library_quantity", default: 0
    t.integer "delivered_to_library_quantity_change", default: 0
    t.integer "return_rct_3pl_quantity", default: 0
    t.integer "return_rct_3pl_quantity_change", default: 0
  end

  create_table "suggested_biblios", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "biblio_id"
    t.integer "read_count", default: 0
    t.integer "borrow_count", default: 0
    t.integer "points", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thanas", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "bn_name"
    t.bigint "district_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
    t.index ["district_id"], name: "index_thanas_on_district_id"
  end

  create_table "third_party_users", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_hash"
    t.string "phone"
    t.string "company"
    t.integer "created_by"
    t.integer "updated_by"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "service_type", default: 0
    t.string "name"
  end

  create_table "tmp_users", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "phone"
    t.string "otp"
    t.boolean "is_otp_verified", default: false
    t.datetime "dob"
    t.integer "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfer_order_status_changes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "library_transfer_order_id", null: false
    t.integer "transfer_order_status_id", null: false
    t.integer "changed_by_id"
    t.string "changed_by_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfer_order_statuses", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "system_status", null: false
    t.string "admin_status", null: false
    t.string "patron_status", null: false
    t.string "bn_patron_status", null: false
    t.boolean "is_active", default: true
    t.boolean "is_deleted", default: false
    t.integer "status_key", default: 0
    t.string "lms_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_qr_codes", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "qr_code"
    t.datetime "expired_at"
    t.bigint "library_id"
    t.text "services"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_suggestions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "biblio_id"
    t.string "biblio_title"
    t.integer "biblio_subject_id"
    t.integer "author_id"
    t.integer "read_count", default: 0
    t.integer "search_count", default: 0
    t.integer "borrow_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "phone"
    t.datetime "dob"
    t.integer "tmp_id"
    t.integer "gender"
    t.string "password_hash"
    t.string "user_code"
    t.boolean "is_active", default: false
    t.datetime "deleted_at"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "biblios_on_hand", default: 0, null: false
    t.boolean "is_deleted", default: false
    t.string "created_by_type"
    t.string "updated_by_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ils_lms_reports", "ils_reports"
  add_foreign_key "ils_lms_reports", "lms_reports"
  add_foreign_key "libraries", "districts"
  add_foreign_key "libraries", "thanas"
  add_foreign_key "money_request_status_changes", "security_money_requests"
  add_foreign_key "phone_change_requests", "users"
  add_foreign_key "publishers", "users"
  add_foreign_key "security_money_requests", "libraries"
  add_foreign_key "security_money_requests", "users"
end
