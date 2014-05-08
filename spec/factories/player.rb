FactoryGirl.define do
  factory :player do
    #repeat sequences from 1 to 4 to always have a valid number
    sequence(:turn_num, 0) {|n| (n % 4) + 1}
    association :user, factory: :confirmed_user
    game

    factory :in_game_player do
      after(:build) do |player, evaluator|
        player.resources.build(type: WHEAT)
        player.resources.build(type: WOOD)
        player.resources.build(type: WOOL)
        player.resources.build(type: ORE)
        player.resources.build(type: BRICK)
        player.resources.each do |resource|
          resource.count = 0
        end
      end

      factory :player_with_items do
        ignore do
          settlement_points []
          road_points []
          resources Hash.new
        end

        after(:build) do |player, evaluator|
          evaluator.settlement_points.each do |point|
            player.settlements.build(:vertex_x => point[0], :vertex_y => point[1], :side => point[2])
          end
          
          evaluator.road_points.each do |point|
            player.roads.build(:edge_x => point[0], :edge_y => point[1], :side => point[2])
          end

          evaluator.resources.each_pair do |type, amount|
            player.resources.find{|r| r.type == type}.count = amount
          end
        end
      end
    end
  end  
end