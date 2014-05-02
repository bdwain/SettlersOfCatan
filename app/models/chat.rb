class Chat < ActiveRecord::Base
  belongs_to :sender, :class_name => 'Player', :foreign_key => 'sender_id'

  validates_presence_of :sender
  validates :msg, :presence => true, 
          :length => {:minimum => 1, :maximum => 300}
end
