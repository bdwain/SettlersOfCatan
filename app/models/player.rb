class Player < ActiveRecord::Base
  belongs_to :game, :inverse_of => :players
  belongs_to :user, :inverse_of => :players
  has_many :resources, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :settlements, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :roads, :inverse_of => :player, :autosave => true, :dependent => :destroy

  validates_presence_of :game, :user
  validates_uniqueness_of :user_id, :scope => :game_id
  
  validates :turn_num, :presence => true, :inclusion => { :in => 1.upto(4) },
            :numericality => {:only_integer => true }

  validates :turn_status, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end
