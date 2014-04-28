class UpdateGameLogTargets < ActiveRecord::Migration
  def change
    rename_column :game_logs, :recipient_id, :target_id
    change_column :game_logs, :target_id, :integer, :null => false
    add_index :game_logs, :target_id
    add_column :game_logs, :is_private, :boolean, :null => false, :default => false
  end
end
