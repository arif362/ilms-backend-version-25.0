class LibraryNewspaper < ApplicationRecord
  belongs_to :newspaper
  belongs_to :library

  enum language: { english: 0, bangla: 1 }
end
