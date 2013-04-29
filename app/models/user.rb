class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :trackable, :lockable, and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :confirmable, :validatable

  #don't use dependent => destroy because of http://goo.gl/YTOkw
  has_many :players, :inverse_of => :user 

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :displayname
                  
  validates :displayname, :presence => true, 
            :length => {:minimum => 3, :maximum => 20}

  #before deleting, abandon games
  before_destroy do |u|
    u.players.each do |p|
      p.game.player_account_deleted(p)
      p.destroy
    end
  end
end
