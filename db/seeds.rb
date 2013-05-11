# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl_rails'

3.times { FactoryGirl.create(:confirmed_user) } if Rails.env == "development"

#NOTE: right now x is vertical and y is horizontal. Maybe change that?
#create default map
map = Map.create({ name: 'Default', middle_row_width: 5, num_middle_rows: 1, num_rows: 5})
resources = [WOOD, WOOL, WHEAT, BRICK, ORE, BRICK, WOOL, DESERT, WOOD, 
             WHEAT, WOOD, WHEAT, BRICK, WOOL, WOOL, ORE, ORE, WHEAT, WOOD]

resources.each { |type| map.hexes.build(:resource_type => type) }

dice_nums = [5,2,6,3,8,10,9,12,11,4,8,10,9,4,5,6,3,11]
map.num_rows.times do |x|
  init_y = (x == 0 || x == 4 ? 1 : 0)
  final_y = (x == 2 ? 4 : 3)
  (init_y..final_y).each do |y|
    map.hexes.first.dice_num = dice_nums.shift unless map.hexes.first.resource_type == DESERT
    map.hexes.first.pos_x = x
    map.hexes.first.pos_y = y
    map.hexes.push(map.hexes.shift)
  end
end

#maybe add something to the model to make this easier?
map.harbors.build(edge_x: 0, edge_y: 2) #hex 0,1 top-left
map.harbors.build(edge_x: 2, edge_y: 8) #hex 1,3 top-right
map.harbors.build(edge_x: 5, edge_y: 10) #hex 2,4 right
map.harbors.build(edge_x: 10, edge_y: 2) #hex 4,1 bottom left
map.harbors.build(resource_type: WOOL, edge_x: 0, edge_y: 5) #hex 0,2 top-right
map.harbors.build(resource_type: WHEAT, edge_x: 7, edge_y: 1) #hex 3,0 left
map.harbors.build(resource_type: WOOD, edge_x: 10, edge_y: 5) #hex 4,2 bottom-right
map.harbors.build(resource_type: ORE, edge_x: 3, edge_y: 1) #hex 1,0 left
map.harbors.build(resource_type: BRICK, edge_x: 8, edge_y: 8) #hex 3,3 bottom-right

map.save