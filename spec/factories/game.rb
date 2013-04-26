FactoryGirl.define do
  factory :game do
    num_players 3
    #the rest of the attributes have default values

    factory :partially_filled_game do
      ignore do
        player_count 2
      end
      after(:create) do |game, evaluator|
        FactoryGirl.create_list(:player, evaluator.player_count, game: game)
      end

      factory :full_game do
        after(:create) do |game, evaluator|
          FactoryGirl.create_list(:player, game.num_players - evaluator.player_count, game: game)
        end

        factory :game_started do
          status 2
        end
      end
    end
  end
end