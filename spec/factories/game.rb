FactoryGirl.define do
  factory :game do
    num_players 3
    association :creator, factory: :confirmed_user
    #the rest of the attributes have default values and don't need to be set

    factory :partially_filled_game do
      ignore do
        additional_players 1
      end

      after(:create) do |game, evaluator|
        FactoryGirl.create_list(:player, evaluator.additional_players, game: game)
      end

      factory :game_playing do
        status 2
        additional_players 2
      end
    end
  end
end