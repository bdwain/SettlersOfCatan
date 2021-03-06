class DevelopmentCard < ActiveRecord::Base
  #disable Single Table Inheritance
  self.inheritance_column = nil
  
  belongs_to :player, :inverse_of => :development_cards
  belongs_to :game, :inverse_of => :development_cards

  validates_presence_of :game

  validates :position, :allow_nil=> true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :type, :presence => true, :numericality => {:only_integer => true}

  validates :turn_bought, :allow_nil=> true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :turn_used, :allow_nil=> true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end
