FactoryGirl.define do
  factory :game do
    num_players 3
    association :creator, factory: :confirmed_user
    #the rest of the attributes have default values and don't need to be set

    factory :partially_filled_game do
      after(:create) do |game, evaluator|
        game.players.concat FactoryGirl.create_list(:player, game.num_players - 2, game: game)
        game.save
      end
    end

    factory :game_turn_1 do
      after(:create) do |game, evaluator|
        (game.num_players - 1).times { game.add_user?(FactoryGirl.create(:confirmed_user)) }
      end
    end
  end
end