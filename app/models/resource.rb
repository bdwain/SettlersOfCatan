class Resource < ActiveRecord::Base
  #disable Single Table Inheritance
  self.inheritance_column = nil
  
  belongs_to :player, :inverse_of => :resources
  attr_accessible :type

  validates_presence_of :player_id

  validates :type, :presence => true, :numericality => {:only_integer => true}
  
end
