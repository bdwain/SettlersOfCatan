class Resource < ActiveRecord::Base
  #disable Single Table Inheritance
  self.inheritance_column = nil
  
  belongs_to :player, :inverse_of => :resources

  attr_accessible :type

  validates_presence_of :player, :type, :count
  validates_uniqueness_of :type, :scope => :player_id

  validates :type, :numericality => {:only_integer => true}
  validates :count, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end
