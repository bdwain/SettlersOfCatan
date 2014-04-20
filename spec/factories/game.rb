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

      factory :game_turn_2 do
        after(:create) do |game, evaluator|
          game.players.sort{|p1, p2| p1.turn_num <=> p2.turn_num}.each do |player|
            index = player.turn_num
            if(index < 4)
              player.add_settlement?(index, index, 0)
              player.add_road?(index - 1, index + 1, 2)
            elsif(index == 4)
              player.add_settlement?(3, 1, 0)
              player.add_road?(2, 2, 2)
            end
          end
        end

        factory :game_started do
          after(:create) do |game, evaluator|
            game.players.sort{|p1, p2| p2.turn_num <=> p1.turn_num}.each do |player|
              case player.turn_num
              when 4
                player.add_settlement?(0, 3, 0)
                player.add_road?(0, 3, 0)                
              when 3
                player.add_settlement?(1, 5, 1)
                player.add_road?(1, 4, 1)
              when 2
                player.add_settlement?(1, 2, 0)
                player.add_road?(0, 3, 1)                
              when 1
                player.add_settlement?(4, 0, 0)
                player.add_road?(3, 1, 1)                
              end
            end
          end
        end
      end
    end
  end
end