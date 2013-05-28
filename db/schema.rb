# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130420052235) do

  create_table "development_cards", :force => true do |t|
    t.integer "player_id"
    t.integer "game_id",                      :null => false
    t.integer "type",                         :null => false
    t.integer "position"
    t.boolean "was_used",  :default => false, :null => false
  end

  add_index "development_cards", ["game_id"], :name => "index_development_cards_on_game_id"
  add_index "development_cards", ["player_id"], :name => "index_development_cards_on_player_id"

  create_table "games", :force => true do |t|
    t.integer  "num_players",                :null => false
    t.integer  "status",      :default => 1, :null => false
    t.integer  "creator_id",                 :null => false
    t.integer  "winner_id"
    t.integer  "map_id",      :default => 1, :null => false
    t.integer  "robber_x",    :default => 0, :null => false
    t.integer  "robber_y",    :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "games", ["creator_id"], :name => "index_games_on_creator_id"
  add_index "games", ["map_id"], :name => "index_games_on_map_id"
  add_index "games", ["winner_id"], :name => "index_games_on_winner_id"

  create_table "harbors", :force => true do |t|
    t.integer "map_id",        :null => false
    t.integer "edge_x",        :null => false
    t.integer "edge_y",        :null => false
    t.integer "resource_type"
  end

  add_index "harbors", ["map_id"], :name => "index_harbors_on_map_id"

  create_table "hexes", :force => true do |t|
    t.integer "map_id",        :null => false
    t.integer "pos_x",         :null => false
    t.integer "pos_y",         :null => false
    t.integer "resource_type", :null => false
    t.integer "dice_num"
  end

  add_index "hexes", ["map_id"], :name => "index_hexes_on_map_id"

  create_table "maps", :force => true do |t|
    t.string   "name",             :limit => 50,                :null => false
    t.integer  "middle_row_width",               :default => 5, :null => false
    t.integer  "num_rows",                       :default => 5, :null => false
    t.integer  "num_middle_rows",                :default => 1, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  create_table "players", :force => true do |t|
    t.integer  "game_id",                      :null => false
    t.integer  "user_id",                      :null => false
    t.integer  "turn_num",      :default => 1, :null => false
    t.integer  "turn_status",   :default => 0, :null => false
    t.datetime "turn_deadline"
  end

  add_index "players", ["game_id"], :name => "index_players_on_game_id"
  add_index "players", ["user_id", "game_id"], :name => "index_players_on_user_id_and_game_id", :unique => true
  add_index "players", ["user_id"], :name => "index_players_on_user_id"

  create_table "resources", :force => true do |t|
    t.integer "player_id",                :null => false
    t.integer "type",                     :null => false
    t.integer "count",     :default => 0, :null => false
  end

  add_index "resources", ["player_id", "type"], :name => "index_resources_on_player_id_and_type", :unique => true
  add_index "resources", ["player_id"], :name => "index_resources_on_player_id"

  create_table "roads", :force => true do |t|
    t.integer "player_id", :null => false
    t.integer "edge_x",    :null => false
    t.integer "edge_y",    :null => false
  end

  add_index "roads", ["player_id"], :name => "index_roads_on_player_id"

  create_table "settlements", :force => true do |t|
    t.integer "player_id",                    :null => false
    t.integer "vertex_x",                     :null => false
    t.integer "vertex_y",                     :null => false
    t.boolean "is_city",   :default => false, :null => false
  end

  add_index "settlements", ["player_id"], :name => "index_settlements_on_player_id"

  create_table "users", :force => true do |t|
    t.string   "displayname",            :limit => 20,                 :null => false
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
