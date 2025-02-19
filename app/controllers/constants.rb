# frozen_string_literal: true
module Constants
  HTTP_CODE = {
    OK: 200,
    CREATED: 201,
    NO_CONTENT: 204,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    PAYMENT_REQUIRED: 402,
    FORBIDDEN: 403,
    NOT_FOUND: 404,
    METHOD_NOT_ALLOWED: 405,
    NOT_ACCEPTABLE: 406,
    REQUEST_TIMEOUT: 408,
    UNSUPPORTED_MEDIA_TYPE: 415,
    UNPROCESSABLE_ENTITY: 422,
    INTERNAL_SERVER_ERROR: 500,
    MOVED_PERMANENTLY: 301,
    TOO_MANY_REQUESTS: 429,
    CONFLICT: 409
  }.freeze

  HTTP_CUSTOM_CODE = {
    MEMBER_NOT_FOUND: 600,
    INVALID_MEMBERSHIP: 601,
    STAFF_ID_REQUIRED: 602,
    STAFF_NOT_FOUND: 603,
    PENDING_INVOICE: 604,
    BIBLIO_NOT_FOUND: 605,
    MAX_BORROW_EXCEEDED: 606,
    BIBLIO_ITEM_NOT_FOUND: 607,
    ALREADY_BORROWED: 608,
    BIBLIO_NOT_AVAILABLE_IN_LIBRARY: 609,
    BOOK_NOT_IN_CIRCULATION: 612,
    BOOK_ALREADY_RETURNED: 613,
    NOT_IN_BORROWED_LIST: 614,
    ALREADY_REQUESTED: 615,
    NOT_AVAILABLE: 616,
    NOT_ELIGIBLE: 617,
    BORROWED_BOOK_EXIST: 618,
    IMMATURE_MEMBERSHIP: 619
  }.freeze

  AUDITABLE_TYPES = %w[Album Announcement Banner Biblio BiblioSubject
                       BookTransferOrder BookTransferOrder Circulation Complain Designation District
                       Division Event EventLibrary EventRegistration Faq HomepageSlider Invoice Library
                       LibraryTransferOrder LmsReport Member Notice Role SecurityMoney SecurityMoneyRequest Staff
                       Thana].freeze

  USER_TYPES = %w[Staff User ThirdPartyUser].freeze

  INVALID = 'invalid record'
end
