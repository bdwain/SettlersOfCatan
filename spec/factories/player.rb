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
    end
  end  
end