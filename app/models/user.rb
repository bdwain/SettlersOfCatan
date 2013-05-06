class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :trackable, :lockable, and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :confirmable, :validatable

  has_many :players, :inverse_of => :user

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :displayname
                  
  validates :displayname, :presence => true, 
            :length => {:minimum => 3, :maximum => 20}

  #destroy all games that a player can't still leave conventionally
  before_destroy do
    players.each do |player|
      player.game.destroy unless player.game.remove_player?(player)
    end
  end
end
