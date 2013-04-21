class Player < ActiveRecord::Base
  belongs_to :game, :inverse_of => :players
  belongs_to :user
  has_many :resources, :inverse_of => :player
  has_many :development_cards, :inverse_of => :player
  has_many :settlements, :inverse_of => :player
  has_many :roads, :inverse_of => :player

  attr_accessible :color, :turn_num, :turn_status, :turn_deadline

  validates_presence_of :game_id, :user_id

  validates :color, :presence => true, :numericality => {:only_integer => true}
  
  validates :turn_num, :presence => true, :inclusion => { :in => 1.upto(4) },
            :numericality => {:only_integer => true }

  validates :turn_status, :allow_nil => true, :numericality => {:only_integer => true}
end
