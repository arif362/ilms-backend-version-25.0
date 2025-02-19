# frozen_string_literal: true

class Role < ApplicationRecord
  audited
  serialize :permission_codes, Array

  has_many :staffs, dependent: :restrict_with_exception

  validates :title, presence: true, uniqueness: true

  CODE_DETAILS = {
    ADMIN: [
      {
        value: 'admin-read',
        label: 'Admin list/details view permission.'
      },
      {
        value: 'admin-create',
        label: 'Admin create permission.'
      },
      {
        value: 'admin-update',
        label: 'Admin update permission.'
      },
      {
        value: 'admin-type_change',
        label: 'Admin type change permission.'
      },
      {
        value: 'admin-delete',
        label: 'Admin delete permission.'
      }
    ],
    LIBRARIAN: [
      {
        value: 'librarian-read',
        label: 'Librarian list/details view permission.'
      },
      {
        value: 'librarian-create',
        label: 'Librarian create permission.'
      },
      {
        value: 'librarian-update',
        label: 'Librarian update permission.'
      },
      {
        value: 'librarian-type_change',
        label: 'Librarian type change permission.'
      },
      {
        value: 'librarian-delete',
        label: 'Librarian delete permission.'
      }
    ],
    ROLE: [
      {
        value: 'role-read',
        label: 'Role list/details view permission'
      },
      {
        value: 'role-create',
        label: 'Role create permission'
      },
      {
        value: 'role-update',
        label: 'Role update permission'
      },
      {
        value: 'role-delete',
        label: 'Role delete permission'
      }
    ],
    DESIGNATION: [
      {
        value: 'designation-read',
        label: 'Designation list/details view permission'
      },
      {
        value: 'designation-create',
        label: 'Designation create permission'
      },
      {
        value: 'designation-update',
        label: 'Designation update permission'
      },
      {
        value: 'designation-delete',
        label: 'Designation delete permission'
      }
    ],
    PAGE: [
      {
        value: 'page-read',
        label: 'Page list/details view permission'
      },
      {
        value: 'page-create',
        label: 'Page create permission'
      },
      {
        value: 'page-update',
        label: 'Page update permission'
      },
      {
        value: 'page-delete',
        label: 'Page delete permission'
      }
    ],
    LIBRARY: [
      {
        value: 'library-read',
        label: 'Library list/details view permission'
      },
      {
        value: 'library-update',
        label: 'Library update permission.'
      },
      {
        value: 'library-create',
        label: 'Library create permission.'
      },
      {
        value: 'library-change_password',
        label: 'library change password'
      },
      {
        value: 'library-change_ip',
        label: 'library change ip'
      }
    ],
    LIBRARY_ENTRY_LOG: [
      {
        value: 'library_entry_log-read',
        label: 'LibraryEntryLog list/details view permission.'
      }
    ],
    USER: [
      {
        value: 'user-read',
        label: 'User list/details view permission.'
      },
      {
        value: 'user-create',
        label: 'User create permission.'
      },
      {
        value: 'user-update',
        label: 'User update permission.'
      },
      {
        value: 'user-delete',
        label: 'User delete permission.'
      }
    ],
    MEMBER: [
      {
        value: 'member-read',
        label: 'Member list/details view permission.'
      },
      {
        value: 'member-create',
        label: 'Member create permission.'
      },
      {
        value: 'member-update',
        label: 'Member update permission.'
      },
      {
        value: 'member-delete',
        label: 'Member delete permission.'
      }
    ],
    BIBLIO: [
      {
        value: 'biblio-read',
        label: 'Biblio list/details view permission.'
      },
      {
        value: 'biblio-create',
        label: 'Biblio create permission.'
      },
      {
        value: 'biblio-update',
        label: 'Biblio update permission.'
      },
      {
        value: 'biblio-delete',
        label: 'Biblio delete permission.'
      }
    ],
    MEMBERSHIP_REQUEST: [
      {
        value: 'membership-request-read',
        label: 'Membership Request list/details view permission.'
      },
      {
        value: 'membership-request-create',
        label: 'Membership Request create permission.'
      },
      {
        value: 'membership-request-update',
        label: 'Membership Request update permission.'
      },
      {
        value: 'membership-request-delete',
        label: 'Membership Request delete permission.'
      },
      {
        value: 'membership-request-accept-reject',
        label: 'Membership Request accept/reject permission.'
      }
    ],
    KEY_PERSON: [
      {
        value: 'key_person-read',
        label: 'Key person list/details view permission.'
      },
      {
        value: 'key_person-create',
        label: 'Key person create permission.'
      },
      {
        value: 'key_person-update',
        label: 'Key person update permission.'
      },
      {
        value: 'key_person-delete',
        label: 'Key person delete permission.'
      }
    ],
    ALBUM: [
      {
        value: 'album-read',
        label: 'Album list/details view permission.'
      },
      {
        value: 'album-create',
        label: 'Album create permission.'
      },
      {
        value: 'album-update',
        label: 'Album update permission.'
      },
      {
        value: 'album-delete',
        label: 'Album delete permission.'
      }
    ],
    HOMEPAGE_SLIDER: [
      {
        value: 'homepage_slider-read',
        label: 'homepage slider list/details view permission.'
      },
      {
        value: 'homepage_slider-create',
        label: 'homepage slider create permission.'
      },
      {
        value: 'homepage_slider-update',
        label: 'homepage slider update permission.'
      },
      {
        value: 'homepage_slider-delete',
        label: 'homepage slider delete permission.'
      }
    ],
    BANNER: [
      {
        value: 'banner-read',
        label: 'banner list/details view permission.'
      },
      {
        value: 'banner-create',
        label: 'banner create permission.'
      },
      {
        value: 'banner-update',
        label: 'banner update permission.'
      },
      {
        value: 'banner-delete',
        label: 'banner delete permission.'
      }
    ],
    PURCHASE_ORDER: [
      {
        value: 'purchase_order-read',
        label: 'purchase_order list/details view permission.'
      },
      {
        value: 'purchase_order-create',
        label: 'purchase_order create permission.'
      },
      {
        value: 'purchase_order-receive',
        label: 'Admin purchase order receive.'
      },
      {
        value: 'purchase_order-update',
        label: 'purchase_order update permission.'
      },
      {
        value: 'purchase_order-delete',
        label: 'purchase_order delete permission.'
      }
    ],
    NOTICE: [
      {
        value: 'notice-read',
        label: 'notice list/details view permission.'
      },
      {
        value: 'notice-create',
        label: 'notice create permission.'
      },
      {
        value: 'notice-update',
        label: 'notice update permission.'
      },
      {
        value: 'notice-delete',
        label: 'notice delete permission.'
      }
    ],
    ORDER: [
      {
        value: 'order-read',
        label: 'order list/details view permission.'
      },
      {
        value: 'order-create',
        label: 'order create permission.'
      },
      {
        value: 'order-update',
        label: 'order update permission.'
      },
      {
        value: 'order-delete',
        label: 'order delete permission.'
      }
    ],
    COMPLAIN: [
      {
        value: 'complain-read',
        label: 'complain list/details view permission.'
      },
      {
        value: 'complain-update',
        label: 'complain update permission.'
      },
      {
        value: 'complain-delete',
        label: 'complain delete permission.'
      }
    ],
    EVENT: [
      {
        value: 'event-read',
        label: 'event list/details view permission.'
      },
      {
        value: 'event-create',
        label: 'event create permission.'
      },
      {
        value: 'event-update',
        label: 'event update permission.'
      },
      {
        value: 'event-delete',
        label: 'event delete permission.'
      }
    ],
    LMS_REPORT: [
      {
        value: 'lms_report-read',
        label: 'lms_report list/details view permission.'
      },
      {
        value: 'lms_report-create',
        label: 'lms_report create permission.'
      },
      {
        value: 'lms_report-update',
        label: 'lms_report update permission.'
      },
      {
        value: 'lms_report-delete',
        label: 'lms_report delete permission.'
      }
    ],
    BIBLIO_SUBJECT: [
      {
        value: 'biblio_subject-read',
        label: 'biblio subject list/details view permission.'
      }
    ],
    EVENT_LIBRARY: [
      {
        value: 'event_library-read',
        label: 'event_library list/details view permission.'
      },
      {
        value: 'event_library-create',
        label: 'event_library create permission.'
      },
      {
        value: 'event_library-update',
        label: 'event_library update permission.'
      },
      {
        value: 'event_library-delete',
        label: 'event_library delete permission.'
      }
    ],
    EVENT_REGISTRATION: [
      {
        value: 'event_registration-read',
        label: 'event_registration list/details view permission.'
      },
      {
        value: 'event_registration-create',
        label: 'event_registration create permission.'
      },
      {
        value: 'event_registration-update',
        label: 'event_registration update permission.'
      },
      {
        value: 'event_registration-delete',
        label: 'event_registration delete permission.'
      }
    ],
    PAGE_TYPE: [
      {
        value: 'page_type-read',
        label: 'page type list/details view permission.'
      },
      {
        value: 'page_type-create',
        label: 'page type create permission.'
      },
      {
        value: 'page_type-update',
        label: 'page type update permission.'
      },
      {
        value: 'page_type-delete',
        label: 'page type delete permission.'
      }
    ],
    BIBLIO_LIBRARY: [
      {
        value: 'biblio_library-read',
        label: 'biblio library list/details view permission.'
      },
      {
        value: 'biblio_library-create',
        label: 'biblio library create permission.'
      },
      {
        value: 'biblio_library-update',
        label: 'biblio library update permission.'
      },
      {
        value: 'biblio_library-delete',
        label: 'biblio library delete permission.'
      }
    ],
    CIRCULATION: [
      {
        value: 'circulation-read',
        label: 'circulation list/details view permission.'
      },
      {
        value: 'circulation-create',
        label: 'circulation create permission.'
      },
      {
        value: 'circulation-update',
        label: 'circulation update permission.'
      },
      {
        value: 'circulation-delete',
        label: 'circulation delete permission.'
      }
    ],
    LIBRARY_CARD_REQUEST: [
      {
        value: 'library-card-request-read',
        label: 'Library Card Request list/details view permission.'
      },
      {
        value: 'library_card_request-update',
        label: 'Library Card Request update permission.'
      }
    ],
    PAYMENT: [
      {
        value: 'payment-read',
        label: 'payment list/details view permission.'
      },
      {
        value: 'payment-create',
        label: 'payment create permission.'
      },
      {
        value: 'payment-update',
        label: 'payment update permission.'
      },
      {
        value: 'payment-delete',
        label: 'payment delete permission.'
      }
    ],
    REQUESTED_BIBLIO: [
      {
        value: 'requested_biblio-read',
        label: 'requested biblio list/details view permission.'
      },
      {
        value: 'requested_biblio-create',
        label: 'requested biblio create permission.'
      },
      {
        value: 'requested_biblio-update',
        label: 'requested biblio update permission.'
      },
      {
        value: 'requested_biblio-delete',
        label: 'requested biblio delete permission.'
      }
    ],
    FAQ: [
      {
        value: 'faq-read',
        label: 'faq list/details view permission.'
      },
      {
        value: 'faq-create',
        label: 'faq create permission.'
      },
      {
        value: 'faq-update',
        label: 'faq update permission.'
      },
      {
        value: 'faq-delete',
        label: 'faq delete permission.'
      }
    ],
    FAQ_CATEGORY: [
      {
        value: 'faq_category-read',
        label: 'faq category list/details view permission.'
      },
      {
        value: 'faq_category-create',
        label: 'faq category create permission.'
      },
      {
        value: 'faq_category-update',
        label: 'faq category update permission.'
      },
      {
        value: 'faq_category-delete',
        label: 'faq category delete permission.'
      }
    ],
    SECURITY_MONEY: [
      {
        value: 'security_money-read',
        label: 'security money list/details view permission.'
      },
      {
        value: 'security_money-create',
        label: 'security money create permission.'
      },
      {
        value: 'security_money-update',
        label: 'security money update permission.'
      },
      {
        value: 'security_money-delete',
        label: 'security money delete permission.'
      }
    ],
    SECURITY_MONEY_REQUEST: [
      {
        value: 'security_money_request-read',
        label: 'security money request list/details view permission.'
      },
      {
        value: 'security_money_request-create',
        label: 'security money request create permission.'
      },
      {
        value: 'security_money_request-update',
        label: 'security money request update permission.'
      },
      {
        value: 'security_money_request-delete',
        label: 'security money request delete permission.'
      }
    ],
    ANNOUNCEMENT: [
      {
        value: 'announcement-create',
        label: 'announcement create permission'
      },
      {
        value: 'announcement-update',
        label: 'announcement update permission'
      },
      {
        value: 'announcement-delete',
        label: 'announcement delete permission'
      },
      {
        value: 'announcement-read',
        label: 'announcement details view permission'
      }
    ],
    DIVISION: [
      {
        value: 'division-read',
        label: 'division list/details view permission.'
      },
      {
        value: 'division-create',
        label: 'division create permission.'
      },
      {
        value: 'division-update',
        label: 'division update permission.'
      },
      {
        value: 'division-delete',
        label: 'division delete permission.'
      }
    ],
    DISTRICT: [
      {
        value: 'district-read',
        label: 'district list/details view permission.'
      },
      {
        value: 'district-create',
        label: 'district create permission.'
      },
      {
        value: 'district-update',
        label: 'district update permission.'
      },
      {
        value: 'district-delete',
        label: 'district delete permission.'
      }
    ],
    DISTRIBUTION: [
      {
        value: 'distribution-read',
        label: 'distribution list/details view permission.'
      },
      {
        value: 'distribution-create',
        label: 'distribution create permission.'
      },
      {
        value: 'distribution-update',
        label: 'distribution update permission.'
      },
      {
        value: 'distribution-delete',
        label: 'distribution delete permission.'
      }
    ],
    Thana: [
      {
        value: 'thana-read',
        label: 'thana list/details view permission.'
      },
      {
        value: 'thana-create',
        label: 'thana create permission.'
      },
      {
        value: 'thana-update',
        label: 'thana update permission.'
      },
      {
        value: 'thana-delete',
        label: 'thana delete permission.'
      }
    ],
    DOCUMENT_CATEGORY: [
      {
        value: 'document_category-read',
        label: 'document_category list/details view permission.'
      },
      {
        value: 'document_category-create',
        label: 'document_category create permission.'
      },
      {
        value: 'document_category-update',
        label: 'document_category update permission.'
      },
      {
        value: 'document_category-delete',
        label: 'document_category delete permission.'
      }
    ],
    DOCUMENT: [
      {
        value: 'document-read',
        label: 'document list/details view permission.'
      },
      {
        value: 'document-create',
        label: 'document create permission.'
      },
      {
        value: 'document-update',
        label: 'document update permission.'
      },
      {
        value: 'document-delete',
        label: 'document delete permission.'
      }
    ],
    PHYSICAL_REVIEW: [
      {
        value: 'physical_review-read',
        label: 'physical_review list/details view permission.'
      }
    ],
    FAILED_SEARCH: [
      {
        value: 'failed_search-read',
        label: 'failed_search list/details view permission.'
      }
    ],
    THIRD_PARTYU_USER: [
      {
        value: 'third_party_user-read',
        label: 'third_party_user list/details view permission.'
      },
      {
        value: 'third_party_user-create',
        label: 'third_party_user create permission.'
      },
      {
        value: 'third_party_user-update',
        label: 'third_party_user update permission.'
      },
      {
        value: 'third_party_user-delete',
        label: 'third_party_user delete permission.'
      }
    ],
    ACCOUNT_DELETION_REQUEST: [
      {
        value: 'account_deletion_request-read',
        label: 'account_deletion_request list/details view permission.'
      },
      {
        value: 'account_deletion_request-update',
        label: 'account_deletion_request update permission.'
      }
    ],
    REBIND_BIBLIO: [
      {
        value: 'rebind_biblio-read',
        label: 'rebind_biblio list/details view permission.'
      }
    ],
    MEMORANDUM: [
      {
        value: 'memorandum-read',
        label: 'memorandum list/details view permission'
      },
      {
        value: 'memorandum-create',
        label: 'memorandum create permission'
      },
      {
        value: 'memorandum-update',
        label: 'memorandum update permission'
      },
      {
        value: 'memorandum-delete',
        label: 'memorandum delete permission'
      }
    ],
    PUBLISHER: [
      {
        value: 'publisher-read',
        label: 'publisher list/details view permission'
      }
    ],
    MEMORANDUM_PUBLISHER: [
      {
        value: 'memorandum_publisher-read',
        label: 'memorandum_publisher list/details view permission'
      },
      {
        value: 'memorandum_publisher-update',
        label: 'memorandum_publisher update permission'
      }
    ],
    PUBLISHER_BIBLIO: [
      {
        value: 'publisher_biblio-read',
        label: 'publisher_biblio list/details view permission'
      },
      {
        value: 'publisher_biblio-update',
        label: 'publisher_biblio update permission'
      }
    ],
    ILS_REPORT: [
      {
        value: 'ils_report-read',
        label: 'ils_report list/details view permission.'
      },
      {
        value: 'ils_report-create',
        label: 'ils_report create view permission.'
      },
      {
        value: 'ils_report-update',
        label: 'ils_report update view permission.'
      },
      {
        value: 'ils_report-delete',
        label: 'ils_report delete view permission.'
      }
    ],
    INTL_RESEARCH_GATEWAY: [
      {
        value: 'intl_research_gateway-read',
        label: 'International research gateway list/details view permission.'
      },
      {
        value: 'intl_research_gateway-create',
        label: 'International research gateway create view permission.'
      },
      {
        value: 'intl_research_gateway-update',
        label: 'International research gateway update view permission.'
      },
      {
        value: 'intl_research_gateway-delete',
        label: 'International research gateway delete view permission.'
      }
    ],
    E_BOOK: [
      {
        value: 'e_book-read',
        label: 'e_book list/details view permission.'
      },
      {
        value: 'e_book-create',
        label: 'e_book create view permission.'
      },
      {
        value: 'e_book-update',
        label: 'e_book update view permission.'
      },
      {
        value: 'e_book-delete',
        label: 'e_book delete view permission.'
      },
      {
        value: 'e_book-import',
        label: 'e_book import view permission.'
      },
      {
        value: 'e_book-delete_all',
        label: 'e_book delete_all view permission.'
      }
    ],
    GOODS_RECEIPT: [
      {
        value: 'goods_receipt-read',
        label: 'Goods Receipt view permission.'
      }
    ],
    DEPARTMENT_BIBLIO_ITEM: [
      {
        value: 'department_biblio_item-read',
        label: 'department_biblio_item list/details view permission.'
      },
      {
        value: 'department_biblio_item-update',
        label: 'Department Biblio Item update permission'
      }
    ],
    AUTHOR: [
      {
        value: 'author-read',
        label: 'Author Read Permission'
      }
    ],
    BIBLIO_PUBLICATION: [
      {
        read: 'biblio_publication-read',
        label: 'Biblio Publication Read Permission'
      }
    ],
    BIBLIO_CLASSIFICATION_SOURCE: [
      {
        value: 'biblio_classification_source-read',
        label: 'Biblio Classification Source Read Permission'
      }
    ],
    LIBRARY_LOCATION: [
      {
        read: 'library_location-read',
        label: 'Library Location Read Permission'
      }
    ],
    BIBLIO_EDITION: [
      {
        read: 'biblio_edition-read',
        label: 'Biblio Edition Read Permission'
      }
    ],
    BIBLIO_STATUS: [
      {
        read: 'biblio_status-read',
        label: 'Biblio Classification Source Read Permission'
      }
    ],
    COLLECTION: [
      {
        read: 'collection-read',
        label: 'Biblio Classification Source Read Permission'
      }
    ],
    BIBLIO_ITEM_TYPE: [
      {
        read: 'biblio_item_type-read',
        label: 'Biblio Classification Source Read Permission'
      }
    ]
  }.freeze

  PERMISSION_GROUP = {
    ADMIN: {
      read: %w[admin-read admin-create admin-update admin-delete type_change],
      create: ['admin-create'],
      update: ['admin-update'],
      delete: ['admin-delete'],
      type_change: ['admin-type_change']
    },
    LIBRARIAN: {
      read: %w[librarian-read librarian-create librarian-update librarian-delete type_change],
      create: ['librarian-create'],
      update: ['librarian-update'],
      delete: ['librarian-delete'],
      type_change: ['librarian-type_change']
    },
    ROLE: {
      read: %w[role-read role-create role-update role-delete],
      create: ['role-create'],
      update: ['role-update'],
      delete: ['role-delete']
    },
    DESIGNATION: {
      read: %w[designation-read designation-create designation-update designation-delete],
      create: ['designation-create'],
      update: ['designation-update'],
      delete: ['designation-delete']
    },
    PAGE: {
      read: %w[page-read page-create page-update page-delete],
      create: ['page-create'],
      update: ['page-update'],
      delete: ['page-delete']
    },
    LIBRARY: {
      read: %w[library-read library-create library-update library-delete library-change_password],
      create: ['library-create'],
      update: ['library-update'],
      delete: ['library-delete'],
      change_password: ['library-change_password'],
      change_ip: ['library-change_ip']
    },
    LIBRARY_ENTRY_LOG: {
      read: %w[library_entry_log-read library_entry_log-create library_entry_log-update library_entry_log-delete],
      create: ['library_entry_log-create'],
      update: ['library_entry_log-update'],
      delete: ['library_entry_log-delete']
    },
    USER: {
      read: %w[user-read user-create user-update user-delete],
      create: ['user-create'],
      update: ['user-update'],
      delete: ['user-delete']
    },
    MEMBER: {
      read: %w[member-read member-create member-update member-delete],
      create: ['member-create'],
      update: ['member-update'],
      delete: ['member-delete']
    },
    BIBLIO: {
      read: %w[biblio-read biblio-create biblio-update biblio-delete],
      create: ['biblio-create'],
      update: ['biblio-update'],
      delete: ['biblio-delete']
    },
    MEMBERSHIP_REQUEST: {
      read: %w[membership-request-read membership-request-create membership-request-update membership-request-delete membership-request-accept-reject],
      create: ['membership-request-create'],
      update: ['membership-request-update'],
      delete: ['membership-request-delete'],
      accept_reject: ['membership-request-accept-reject']
    },
    REVIEW: {
      read: %w[review-read review-update review-delete review-accept-reject],
      update: ['review-update'],
      delete: ['review-delete'],
      accept_reject: ['review-accept-reject']
    },
    ORDER: {
      read: %w[order-read order-update order-delete],
      update: ['order-update'],
      delete: ['order-delete']
    },
    KEY_PERSON: {
      read: %w[key_person-read key_person-create key_person-update key_person-delete],
      create: ['key_person-create'],
      update: ['key_person-update'],
      delete: ['key_person-delete']
    },
    HOMEPAGE_SLIDER: {
      read: %w[homepage_slider-read homepage_slider-create homepage_slider-update homepage_slider-delete],
      create: ['homepage_slider-create'],
      update: ['homepage_slider-update'],
      delete: ['homepage_slider-delete']
    },
    BANNER: {
      read: %w[banner-read banner-create banner-update banner-delete],
      create: ['banner-create'],
      update: ['banner-update'],
      delete: ['banner-delete']
    },
    PURCHASE_ORDER: {
      read: %w[purchase_order-read purchase_order-create purchase_order-update purchase_order-delete],
      create: ['purchase_order-create'],
      update: ['purchase_order-update'],
      delete: ['purchase_order-delete'],
      receive: ['purchase_order-receive']
    },
    ALBUM: {
      read: %w[album-read album-create album-update album-delete],
      create: ['album-create'],
      update: ['album-update'],
      delete: ['album-delete']
    },
    NOTICE: {
      read: %w[notice-read notice-create notice-update notice-delete],
      create: ['notice-create'],
      update: ['notice-update'],
      delete: ['notice-delete']
    },
    COMPLAIN: {
      read: %w[complain-read complain-update complain-delete],
      update: ['complain-update'],
      delete: ['complain-delete']
    },
    EVENT: {
      read: %w[event-read event-create event-update event-delete],
      create: ['event-create'],
      update: ['event-update'],
      delete: ['event-delete']
    },
    LMS_REPORT: {
      read: %w[lms_report-read lms_report-create lms_report-update lms_report-delete],
      create: ['lms_report-create'],
      update: ['lms_report-update'],
      delete: ['lms_report-delete']
    },
    BIBLIO_SUBJECT: {
      read: %w[biblio_subject-read biblio_subject-create biblio_subject-update biblio_subject-delete]
    },
    EVENT_LIBRARY: {
      read: %w[event_library-read event_library-create event_library-update event_library-delete],
      create: ['event_library-create'],
      update: ['event_library-update'],
      delete: ['event_library-delete']
    },
    EVENT_REGISTRATION: {
      read: %w[event_registration-read event_registration-create event_registration-update event_registration-delete],
      create: ['event_registration-create'],
      update: ['event_registration-update'],
      delete: ['event_registration-delete']
    },
    PAGE_TYPE: {
      read: %w[page_type-read page_type-create page_type-update page_type-delete],
      create: ['page_type-create'],
      update: ['page_type-update'],
      delete: ['page_type-delete']
    },
    BIBLIO_LIBRARY: {
      read: %w[biblio_library-read biblio_library-create biblio_library-update biblio_library-delete],
      create: ['biblio_library-create'],
      update: ['biblio_library-update'],
      delete: ['biblio_library-delete']
    },
    CIRCULATION: {
      read: %w[circulation-read circulation-create circulation-update circulation-delete],
      create: ['circulation-create'],
      update: ['circulation-update'],
      delete: ['circulation-delete']
    },
    LIBRARY_CARD_REQUEST: {
      read: %w[library_card_request-read library_card_request-update],
      update: ['library_card_request-update']
    },
    PAYMENT: {
      read: %w[payment-read payment-create payment-update payment-delete],
      create: ['payment-create'],
      update: ['payment-update'],
      delete: ['payment-delete']
    },
    REQUESTED_BIBLIO: {
      read: %w[requested_biblio-read payment-create payment-update payment-delete],
      create: ['requested_biblio-create'],
      update: ['requested_biblio-update'],
      delete: ['requested_biblio-delete']
    },
    FAQ: {
      read: %w[faq-read faq-create faq-update faq-delete],
      create: ['faq-create'],
      update: ['faq-update'],
      delete: ['faq-delete']
    },
    FAQ_CATEGORY: {
      read: %w[faq_category-read faq_category-create faq_category-update faq_category-delete],
      create: ['faq_category-create'],
      update: ['faq_category-update'],
      delete: ['faq_category-delete']
    },
    SECURITY_MONEY: {
      read: %w[security_money-read security_money-create security_money-update security_money-delete],
      create: ['security_money-create'],
      update: ['security_money-update'],
      delete: ['security_money-delete']
    },
    SECURITY_MONEY_REQUEST: {
      read: %w[security_money_request-read security_money_request-create security_money_request-update security_money_request-delete],
      create: ['security_money_request-create'],
      update: ['security_money_request-update'],
      delete: ['security_money_request-delete']
    },
    ANNOUNCEMENT: {
      read: %w[announcement-read announcement-create announcement-delete],
      create: ['announcement-create'],
      update: ['announcement-update'],
      delete: ['announcement-delete']
    },
    DIVISION: {
      read: %w[division-read division-create division-update division-delete],
      create: ['division-create'],
      update: ['division-update'],
      delete: ['division-delete']
    },
    DISTRICT: {
      read: %w[district-read district-create district-update district-delete],
      create: ['district-create'],
      update: ['district-update'],
      delete: ['district-delete']
    },
    DISTRIBUTION: {
      read: %w[distribution-read distribution-create distribution-update distribution-delete],
      create: ['distribution-create'],
      update: ['distribution-update'],
      delete: ['distribution-delete']
    },
    THANA: {
      read: %w[thana-read thana-create thana-update thana-delete],
      create: ['thana-create'],
      update: ['thana-update'],
      delete: ['thana-delete']
    },
    DOCUMENT_CATEGORY: {
      read: %w[document_category-read document_category-create document_category-update document_category-delete],
      create: ['document_category-create'],
      update: ['document_category-update'],
      delete: ['document_category-delete']
    },
    DOCUMENT: {
      read: %w[document-read document-create document-update document-delete],
      create: ['document-create'],
      update: ['document-update'],
      delete: ['document-delete']
    },
    THIRD_PARTY_USER: {
      read: %w[third_party_user-read third_party_user-create third_party_user-update third_party_user-delete],
      create: ['third_party_user-create'],
      update: ['third_party_user-update'],
      delete: ['third_party_user-delete']
    },
    PHYSICAL_REVIEW: {
      read: %w[physical_review-read]
    },
    FAILED_SEARCH: {
      read: %w[failed_search-read]
    },
    ACCOUNT_DELETION_REQUEST: {
      read: %w[account_deletion_request-read account_deletion_request-update],
      update: ['account_deletion_request-update']
    },
    REBIND_BIBLIO: {
      read: %w[rebind_biblio-read]
    },
    MEMORANDUM: {
      read: %w[memorandum-read memorandum-create memorandum-update memorandum-delete],
      create: ['memorandum-create'],
      update: ['memorandum-update'],
      delete: ['memorandum-delete']
    },
    PUBLISHER: {
      read: %w[publisher-read]
    },
    MEMORANDUM_PUBLISHER: {
      read: %w[memorandum_publisher-read memorandum_publisher-update],
      update: ['memorandum_publisher-update']
    },
    PUBLISHER_BIBLIO: {
      read: %w[publisher_biblio-read publisher_biblio-update],
      update: ['publisher_biblio-update']
    },
    ILS_REPORT: {
      read: %w[ils_report-read ils_report-create ils_report-update ils_report-delete],
      create: ['ils_report-create'],
      update: ['ils_report-update'],
      delete: ['ils_report-delete']
    },
    INTL_RESEARCH_GATEWAY: {
      read: %w[intl_research_gateway-read intl_research_gateway-create intl_research_gateway-update intl_research_gateway-delete],
      create: ['intl_research_gateway-create'],
      update: ['intl_research_gateway-update'],
      delete: ['intl_research_gateway-delete']
    },
    E_BOOK: {
      read: %w[e_book-read e_book-create e_book-update e_book-delete e_book-import, e_book-delete_all],
      create: ['e_book-create'],
      update: ['e_book-update'],
      delete: ['e_book-delete'],
      import: ['e_book-import'],
      delete_all: ['e_book-delete_all']
    },
    GOODS_RECEIPT: {
      read: %w[goods_receipt-read]
    },
    DEPARTMENT_BIBLIO_ITEM: {
      read: %w[department_biblio_item-read department_biblio_item-create department_biblio_item-update department_biblio_item-delete],
      update: ['department_biblio_item-update']
    },
    AUTHOR: {
      read: %w[author-read]
    },
    BIBLIO_PUBLICATION: {
      read: %w[biblio_publication-read]
    },
    LIBRARY_LOCATION: {
      read: %w[library_location-read]
    },
    BIBLIO_EDITION: {
      read: %w[biblio_edition-read]
    },
    BIBLIO_STATUS: {
      read: %w[biblio_status-read]
    },
    BIBLIO_CLASSIFICATION_SOURCE: {
      read: %w[biblio_classification_source-read]
    },
    COLLECTION: {
      read: %w[collection-read]
    },
    BIBLIO_ITEM_TYPE: {
      read: %w[biblio_item_type-read]
    }
  }.freeze

end
