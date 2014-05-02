class Resource < ActiveRecord::Base
  #disable Single Table Inheritance
  self.inheritance_column = nil
  
  belongs_to :player, :inverse_of => :resources

  validates_presence_of :player, :type, :count
  validates_uniqueness_of :type, :scope => :player_id

  validates :type, :numericality => {:only_integer => true}
  validates :count, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  def name
    case type
    when DESERT
      return "DESERT"
    when WHEAT
      return "WHEAT"
    when BRICK
      return "BRICK"
    when WOOD
      return "WOOD"
    when WOOL
      return "WOOL"
    when ORE
      return "ORE"
    else
      raise "Invalid resource type"
    end
  end
end
