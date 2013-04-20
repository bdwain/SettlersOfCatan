class Game < ActiveRecord::Base
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id'
  has_many :game_hexes, :inverse_of => :game
  has_many :game_harbors, :inverse_of => :game
  
  attr_accessible :game_status, :middle_row_width, :num_middle_rows, :num_players, :num_rows, :robber_x, :robber_y
  
  validates :game_status, :presence => true, :numericality => {:only_integer => true}

  validates :middle_row_width, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 5}

  validates :num_middle_rows, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 0}

  validates :num_rows, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 5}

  validates :num_players, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 2, :less_than => 5}

  validates :robber_x, :presence => true, :numericality => {:only_integer => true}
  validates :robber_y, :presence => true, :numericality => {:only_integer => true}
end
