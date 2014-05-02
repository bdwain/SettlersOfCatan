class Map < ActiveRecord::Base
  has_many :hexes, :inverse_of => :map, :autosave => true, :dependent => :destroy
  has_many :harbors, :inverse_of => :map, :autosave => true, :dependent => :destroy
  
  validates :name, :presence => true, :length => { :in => 3..50 }

  validates :middle_row_width, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 5}

  validates :num_middle_rows, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 0}

  validates :num_rows, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 5}
end
