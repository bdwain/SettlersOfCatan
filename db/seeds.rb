# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'

#create default map
map = Map.create({ name: 'Default', middle_row_width: 5, num_middle_rows: 1, num_rows: 5})

map.hexes.build(:resource_type => WOOD, :dice_num => 11, :pos_x => 0, :pos_y => 4)
map.hexes.build(:resource_type => WOOL, :dice_num => 12, :pos_x => 1, :pos_y => 4)
map.hexes.build(:resource_type => WHEAT, :dice_num => 9, :pos_x => 2, :pos_y => 4)
map.hexes.build(:resource_type => BRICK, :dice_num => 4, :pos_x => 0, :pos_y => 3)
map.hexes.build(:resource_type => ORE, :dice_num => 6, :pos_x => 1, :pos_y => 3)
map.hexes.build(:resource_type => BRICK, :dice_num => 5, :pos_x => 2, :pos_y => 3)
map.hexes.build(:resource_type => WOOL, :dice_num => 10, :pos_x => 3, :pos_y => 3)
map.hexes.build(:resource_type => DESERT, :pos_x => 0, :pos_y => 2)
map.hexes.build(:resource_type => WOOD, :dice_num => 3, :pos_x => 1, :pos_y => 2)
map.hexes.build(:resource_type => WHEAT, :dice_num => 11, :pos_x => 2, :pos_y => 2)
map.hexes.build(:resource_type => WOOD, :dice_num => 4, :pos_x => 3, :pos_y => 2)
map.hexes.build(:resource_type => WHEAT, :dice_num => 8, :pos_x => 4, :pos_y => 2)
map.hexes.build(:resource_type => BRICK, :dice_num => 8, :pos_x => 1, :pos_y => 1)
map.hexes.build(:resource_type => WOOL, :dice_num => 10, :pos_x => 2, :pos_y => 1)
map.hexes.build(:resource_type => WOOL, :dice_num => 9, :pos_x => 3, :pos_y => 1)
map.hexes.build(:resource_type => ORE, :dice_num => 3, :pos_x => 4, :pos_y => 1)
map.hexes.build(:resource_type => ORE, :dice_num => 5, :pos_x => 2, :pos_y => 0)
map.hexes.build(:resource_type => WHEAT, :dice_num => 2, :pos_x => 3, :pos_y => 0)
map.hexes.build(:resource_type => WOOD, :dice_num => 6, :pos_x => 4, :pos_y => 0)

#maybe add something to the model to make this easier?
map.harbors.build(edge_x: -1, edge_y: 5, :side => 2)
map.harbors.build(edge_x: 3, edge_y: 3, :side => 0)
map.harbors.build(edge_x: 4, edge_y: 2, :side => 1)
map.harbors.build(edge_x: 2, edge_y: -1, :side => 0)
map.harbors.build(resource_type: WOOL, edge_x: 1, edge_y: 4, :side => 0)
map.harbors.build(resource_type: WHEAT, edge_x: 0, edge_y: 1, :side => 1)
map.harbors.build(resource_type: WOOD, edge_x: 3, edge_y: 0, :side => 2)
map.harbors.build(resource_type: ORE, edge_x: -1, edge_y: 3, :side => 1)
map.harbors.build(resource_type: BRICK, edge_x: 4, edge_y: 1, :side => 2)

map.save

FactoryGirl.create(:game_turn_1) if Rails.env == "development"