class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.text :msg, :null => false, :limit => 300
      t.integer :sender_id, :null => false
      t.timestamps
    end
    add_index :chats, :sender_id
  end
end
