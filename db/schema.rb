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

ActiveRecord::Schema.define(:version => 20130420045235) do

  create_table "game_development_cards", :force => true do |t|
    t.integer  "game_player_id"
    t.integer  "game_id"
    t.integer  "card_type",      :null => false
    t.integer  "card_position",  :null => false
    t.boolean  "was_used",       :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "game_development_cards", ["game_id"], :name => "index_game_development_cards_on_game_id"
  add_index "game_development_cards", ["game_player_id"], :name => "index_game_development_cards_on_game_player_id"

  create_table "game_harbors", :force => true do |t|
    t.integer  "game_id",       :null => false
    t.integer  "edge_x",        :null => false
    t.integer  "edge_y",        :null => false
    t.integer  "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "game_harbors", ["game_id"], :name => "index_game_harbors_on_game_id"

  create_table "game_hexes", :force => true do |t|
    t.integer  "game_id",       :null => false
    t.integer  "pos_x",         :null => false
    t.integer  "pos_y",         :null => false
    t.integer  "resource_type", :null => false
    t.integer  "dice_num",      :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "game_hexes", ["game_id"], :name => "index_game_hexes_on_game_id"

  create_table "game_player_resources", :force => true do |t|
    t.integer  "game_player_id", :null => false
    t.integer  "resource_type",  :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "game_player_resources", ["game_player_id"], :name => "index_game_player_resources_on_game_player_id"

  create_table "game_players", :force => true do |t|
    t.integer  "game_id",     :null => false
    t.integer  "user_id",     :null => false
    t.integer  "turn_num",    :null => false
    t.integer  "turn_status", :null => false
    t.integer  "color",       :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "game_players", ["game_id"], :name => "index_game_players_on_game_id"
  add_index "game_players", ["user_id"], :name => "index_game_players_on_user_id"

  create_table "games", :force => true do |t|
    t.integer  "num_players",      :null => false
    t.integer  "game_status",      :null => false
    t.integer  "winner_id"
    t.integer  "robber_x",         :null => false
    t.integer  "robber_y",         :null => false
    t.integer  "middle_row_width", :null => false
    t.integer  "num_rows",         :null => false
    t.integer  "num_middle_rows",  :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "games", ["winner_id"], :name => "index_games_on_winner_id"

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
