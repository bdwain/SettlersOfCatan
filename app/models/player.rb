class Player < ActiveRecord::Base
  belongs_to :game, :inverse_of => :players
  belongs_to :user, :inverse_of => :players
  has_many :resources, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :settlements, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :roads, :inverse_of => :player, :autosave => true, :dependent => :destroy

  attr_accessible :color, :turn_num, :turn_status, :turn_deadline

  validates_presence_of :game, :user
  validates_uniqueness_of :user_id, :scope => :game_id

  validates :color, :presence => true, :numericality => {:only_integer => true}
  
  validates :turn_num, :presence => true, :inclusion => { :in => 1.upto(4) },
            :numericality => {:only_integer => true }

  validates :turn_status, :allow_nil => true, :numericality => {:only_integer => true}
end
