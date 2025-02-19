class SuggestedBiblio < ApplicationRecord
  belongs_to :user
  belongs_to :biblio

  before_save :points_update

  def points_update
    self.points = borrow_count + read_count
  end
end
