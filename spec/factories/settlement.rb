FactoryGirl.define do
  factory :settlement do
    vertex_x 1
    vertex_y 1
    side 1
    is_city 0
    player
  end  
end