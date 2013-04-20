FactoryGirl.define do
  factory :game do
    middle_row_width 5
    num_middle_rows 1
    num_rows 5
    robber_x 0
    robber_y 0
    #numplayers and game_status have default values
  end  
end