require 'spec_helper'

describe Game do
  describe "creator" do
    it { should belong_to(:creator).class_name('User') }
    it { should validate_presence_of(:creator) }
  end

  describe "winner" do
    it { should belong_to(:winner).class_name('User') }
  end

  describe "map" do
    it { should belong_to(:map) }
    it { should validate_presence_of(:map) }
  end

  describe "players" do
    it { should have_many(:players).dependent(:destroy) }
  end

  describe "development_cards" do
    it { should have_many(:development_cards).dependent(:destroy) }
  end

  describe "chats" do
    it { should have_many(:chats).through(:players) }
  end

  describe "game_logs" do
    it { should have_many(:game_logs).through(:players) }
  end

  describe "dice_rolls" do
    it { should have_many(:dice_rolls).through(:players) }
  end

  describe "status" do
    it { should validate_presence_of(:status) }
    it { should ensure_inclusion_of(:status).in_range(1..4) }
  end

  describe "num_players" do
    it { should validate_presence_of(:num_players) }
    it { should validate_numericality_of(:num_players).only_integer }
    it { should ensure_inclusion_of(:num_players).in_range(3..4) } 
  end

  describe "turn_num" do
    it { should validate_presence_of(:turn_num) }
    it { should validate_numericality_of(:turn_num).only_integer }
    it { should_not allow_value(0).for(:turn_num) }
    it { should allow_value(1).for(:turn_num) }
  end

  describe "robber_x" do
    it { should validate_presence_of(:robber_x) }
    it { should validate_numericality_of(:robber_x).only_integer }
  end

  describe "robber_y" do
    it { should validate_presence_of(:robber_y) }
    it { should validate_numericality_of(:robber_y).only_integer }
  end

  describe "game_board" do
    it "returns an up to date version after the board changes" do
      game = FactoryGirl.create(:game_turn_1)
      expect(game.game_board.vertex_is_free_for_building?(2,2,0)).to be true
      game.players.find{|p|p.turn_status == PLACING_INITIAL_SETTLEMENT}.add_settlement?(2,2,0)
      expect(game.game_board.vertex_is_free_for_building?(2,2,0)).to be_falsey
    end
  end

  describe "current_player" do
    context "when the current player is player 1" do
      let(:game) {FactoryGirl.create(:game_turn_1)}

      it "returns the player with id current_player_id" do
        game.current_player.id = game.current_player_id
      end
    end

    context "when the current player is not player 1" do
      let(:game) {FactoryGirl.create(:game_turn_2)}
      
      it "returns the player with id current_player_id" do
        game.current_player.id = game.current_player_id
      end
    end
  end

  describe "current_player=" do
    let(:game) {FactoryGirl.create(:game_turn_1)}
    let(:new_player) {game.players.find{|p| p.id != game.current_player_id}}

    it "sets current_player_id to the player's id" do
      game.current_player = new_player
      expect(game.current_player_id).to eq(new_player.id)
    end
  end

  describe "status_checkers" do
    let(:game) { FactoryGirl.build_stubbed(:game) }

    describe "waiting_for_players?" do
      it "returns true if status is 1" do
        game.status = 1
        expect(game.waiting_for_players?).to be true
      end
      
      it "returns false if status is not 1" do
        game.status = 2
        expect(game.waiting_for_players?).to be_falsey
      end
    end

    describe "placing_initial_pieces?" do
      it "returns true if status is 2" do
        game.status = 2
        expect(game.placing_initial_pieces?).to be true
      end
      
      it "returns false if status is not 2" do
        game.status = 3
        expect(game.placing_initial_pieces?).to be_falsey
      end
    end    

    describe "playing?" do
      it "returns true if status is 3" do
        game.status = 3
        expect(game.playing?).to be true
      end
      
      it "returns false if status is not 2" do
        game.status = 4
        expect(game.playing?).to be_falsey
      end
    end

    describe "completed?" do
      it "returns true if status is 4" do
        game.status = 4
        expect(game.completed?).to be true
      end
      
      it "returns false if status is not 4" do
        game.status = 1
        expect(game.completed?).to be_falsey
      end
    end
  end

  describe "player" do
    let(:game) { FactoryGirl.create(:partially_filled_game) }

    it "returns the first player when passed the corresponding user" do
      expect(game.player(game.players.first.user)).to equal(game.players.first)
    end

    #Added this test after accidentally looking for a player with user_id == id,
    #which caused it to return the wrong player while passing the other tests
    it "returns the last player when passed the corresponding user" do
      expect(game.player(game.players.last.user)).to equal(game.players.last)
    end

    it "returns nil if the user isn't playing" do
      user = FactoryGirl.build_stubbed(:confirmed_user)
      expect(game.player(user)).to be_nil
    end

    it "returs nil if passed nil" do
      expect(game.player(nil)).to be_nil
    end
  end

  describe "player?" do
    let(:game) { FactoryGirl.create(:partially_filled_game) }

    it "returns true if a game's players include user" do
      expect(game.player?(game.players.first.user)).to be true
    end

    it "returns false if a game's players do not include user" do
      user = FactoryGirl.build_stubbed(:confirmed_user)
      expect(game.player?(user)).to be_falsey
    end

    it "returns false if user is nil" do
      expect(game.player?(nil)).to be_falsey
    end
  end

  describe "creation" do
    let(:game) { FactoryGirl.build(:game) }

    it "creates one player when created" do
      expect{
        game.save
      }.to change(game.players, :count).by(1)
    end

    it "the created player is owned by the creator" do
      game.save
      expect(game.players.first.user).to be game.creator
    end

    it "doesn't save the game when creating the player fails" do
      expect(game).to receive(:add_user?).and_return(false)
      expect{
        game.save
      }.to_not change(Game, :count)
    end    
  end

  describe "add_user?" do
    #prevents us from calling add_user? on create. tests for that are separate
    before(:all) do
      Game.skip_callback(:create, :after, :after_create_add_creators_player)
    end
    after(:all) do
      Game.set_callback(:create, :after, :after_create_add_creators_player)
    end

    shared_examples "add_user? failures" do
      it "returns false" do
        expect(game.add_user?(user)).to be_falsey
      end

      it "does not add players to the game" do
        expect{
          game.add_user?(user)
        }.to_not change(game.players, :count)
      end
    end

    let!(:game) { FactoryGirl.build(:game, num_players: 3) }
    context "when user is not nil" do
      context "when user is confirmed" do
        let(:user) { game.creator }        
        context "when waiting for players" do
          before(:each) { expect(game).to receive(:waiting_for_players?).at_least(:once).and_return(true) }

          context "when the user is not already in the game" do
            it "returns true" do
              expect(game.add_user?(user)).to be true
            end

            it "add a player with the right user to the game" do
              expect{
                game.add_user?(user)
              }.to change(game.players, :count).by(1)

              expect(game.players.last.user).to eq(user)
            end
          end

          context "when the user is already in the game" do
            before(:each) { game.add_user?(game.creator) }
            include_examples "add_user? failures"
          end
        end

        context "when not waiting for players" do
          before(:each) { allow(game).to receive(:waiting_for_players?).and_return(false) }
          include_examples "add_user? failures"
        end
      end

      context "when user is unconfirmed" do
        let(:user) {FactoryGirl.build_stubbed(:user)}
        include_examples "add_user? failures"
      end
    end

    context "when user is nil" do
      let(:user) {nil}
      include_examples "add_user? failures"
    end
  end

  describe "remove_player?" do
    shared_examples "remove_player? returns true" do
      it "returns true" do
        expect(game.remove_player?(player)).to be_truthy
      end
    end

    shared_examples "remove_player? destroys the game" do
      it "destroys the game" do
        expect{
          game.remove_player?(player)
        }.to change(Game, :count).by(-1)
      end
    end

    shared_examples "remove_player? doesn't destroy the game" do
      it "doesn't destroy the game" do
        expect{
          game.remove_player?(player)
        }.to_not change(Game, :count)
      end      
    end

    shared_examples "remove_player? destroys the player" do
      it "destroys the player" do
        expect{
          game.remove_player?(player)
        }.to change(game.players, :count).by(-1)
      end
    
      include_examples "remove_player? doesn't destroy the game"
    end

    shared_examples "remove_player? failures" do
      include_examples "remove_player? doesn't destroy the game"

      it "does not destroy the player" do
        expect{
          game.remove_player?(player)
        }.to_not change(game.players, :count)
      end

      it "returns false" do
        expect(game.remove_player?(player)).to be_falsey
      end      
    end    

    let!(:game) { FactoryGirl.create(:game) }
    context "when the player is not nil" do
      context "when the game is still waiting for players" do
        before(:each) { expect(game).to receive(:waiting_for_players?).and_return(true) }

        context "when the player is in the game" do
          context "when the player is the creator" do
            let!(:player) { game.creator.players.first }
            before(:each) { game.players.push(FactoryGirl.create(:player, game: game)) }
            include_examples "remove_player? destroys the game"
            include_examples "remove_player? returns true"
          end

          #unexpected but this will prevent old empty games
          context "when a non-creator is the only player left" do
            let!(:player) { FactoryGirl.create(:player, game: game) }
            before(:each) { game.players.first.destroy }
            include_examples "remove_player? destroys the game"
            include_examples "remove_player? returns true"
          end          

          context "when there are other players and this isn't the creator" do
            before(:each) { game.players.push(FactoryGirl.create(:player, game: game)) }
            let!(:player) { game.players.last }
            include_examples "remove_player? destroys the player"
            include_examples "remove_player? returns true"
          end
        end

        context "when the player is not in the game" do
          context "when the player's user is not in the game" do
            let!(:player) { FactoryGirl.create(:player) }
            include_examples "remove_player? failures"
          end

          #make sure it's looking by playerid and not user id
          context "when the player's user is in the game" do
            let!(:player) { FactoryGirl.create(:player, user: game.creator) }
            include_examples "remove_player? failures"
          end          
        end
      end

      context "when the game is not waiting for players anymore" do
        let!(:player) { game.creator.players.first }
        before(:each) { allow(game).to receive(:waiting_for_players?).and_return(false) }
        include_examples "remove_player? failures"
      end
    end

    context "when the player is nil" do
      let(:player) {nil}
      include_examples "remove_player? failures"
    end
  end

  describe "saving" do
    context "when the game has just added its last player but is still \"waiting_for_players\"" do
      let(:game) { FactoryGirl.create(:partially_filled_game) }
      before(:each) do
        final_player = game.players.build
        final_player.user = FactoryGirl.build_stubbed(:confirmed_user)
      end

      it "assigns each player a unique turn number from 1 to num_players" do
        game.players.each { |player| player.turn_num = 1 }
        game.save
        game.sorted_players.each_with_index do |player, index|
          expect(player.turn_num).to eq(index + 1)
        end
      end

      it "gives each player each resource with a count of 0" do
        expect{
          game.save
        }.to change(Resource, :count).by(5*game.num_players)
        game.players.each do |player|
          expect(player.resources.collect {|resource| resource.type}.sort).to eq([WOOL, WOOD, WHEAT, ORE, BRICK].sort)
          expect(player.resources.all?{|resource| resource.count == 0}).to be true
        end
      end

      it "creates a correct deck of development cards" do
        expect{
          game.save
        }.to change(DevelopmentCard, :count).by(25)
        expect(game.development_cards.where(:type => KNIGHT).count).to eq(14)
        expect(game.development_cards.where(:type => VICTORY_POINT).count).to eq(5)
        expect(game.development_cards.where(:type => ROAD_BUILDING).count).to eq(2)
        expect(game.development_cards.where(:type => YEAR_OF_PLENTY).count).to eq(2)
        expect(game.development_cards.where(:type => MONOPOLY).count).to eq(2)
      end

      it "sets player 1's status to PLAYING_TURN and everyone else to WAITING_FOR_TURN" do
        game.save
        game.players.each do |player|
          expect(player.turn_status).to eq(player.turn_num == 1 ? PLACING_INITIAL_SETTLEMENT : WAITING_FOR_TURN)
        end
      end

      it "changes the status to placing initial pieces" do
        expect(game.placing_initial_pieces?).to be_falsey
        game.save
        expect(game.placing_initial_pieces?).to be true
      end

      it "sets the current_player to the player who ends up with the first turn" do
        game.save
        expect(game.current_player).to eq(game.players.find{|p| p.turn_num == 1})
      end
    end

    context "when the game isn't full" do
      it "status doesn't change" do
        game = FactoryGirl.build(:game)
        expect {
          game.save
        }.to_not change(game, :status)
      end
    end

    context "when no longer waiting for players" do
      it "doesn't add any new development cards" do #something it would do if starting a game
        game = FactoryGirl.create(:game_turn_1)
        expect {
          game.save
        }.to_not change(DevelopmentCard, :count)
      end
    end
  end

  describe "advance?" do
    context "when the game is waiting for players" do
      let(:game) { FactoryGirl.create(:game) }

      it "returns false" do
        expect(game.advance?).to be_falsey
      end
    end

    shared_examples "returns true" do
      it "returns true" do
        expect(game.advance?).to be true
      end
    end

    shared_examples "first n-1 players on turn 1 or last n-1 players on turn 2" do
      include_examples "returns true"

      it "sets the next player's turn status to PLACING_INITIAL_SETTLEMENT" do
        game.advance?
        expect(next_player.turn_status).to eq(PLACING_INITIAL_SETTLEMENT)
      end

      it "sets the current player's turn status to WAITING_FOR_TURN" do
        game.advance?
        expect(current_player.turn_status).to eq(WAITING_FOR_TURN)
      end

      it "changes game.current_player to the next_player" do
        game.advance?
        expect(game.current_player).to eq(next_player)
      end
    end

    context "when the game is placing initial pieces" do
      context "when the current_player's status is not PLACING_INITIAL_ROAD" do
        let(:game){FactoryGirl.create(:game_turn_1)}

        it "returns false" do
          expect(game.advance?).to be_falsey
        end
      end

      context "when the current_player's status is PLACING_INITIAL_ROAD" do
        context "when on turn 1" do
          let(:game){FactoryGirl.create(:game_turn_1)}

          context "when the current player is not the last player" do
            let!(:current_player) do
              game.current_player.turn_status = PLACING_INITIAL_ROAD
              game.current_player
            end

            let(:next_player) {game.players.find{|player| player.turn_num == current_player.turn_num + 1}}

            include_examples "first n-1 players on turn 1 or last n-1 players on turn 2"
          end

          context "when the current player is the last player" do
            let!(:current_player) do
              game.current_player.turn_status = WAITING_FOR_TURN
              game.current_player = game.players.find{|player| player.turn_num == game.num_players}
              game.current_player.turn_status = PLACING_INITIAL_ROAD
              game.current_player
            end          

            include_examples "returns true"

            it "increments the game turn_num to 2" do
              game.advance?
              expect(game.turn_num).to eq(2)
            end

            it "sets the current player's turn status to PLACING_INITIAL_SETTLEMENT" do
              game.advance?
              expect(current_player.turn_status).to eq(PLACING_INITIAL_SETTLEMENT)
            end

            it "leaves game.current_player the same" do
              expect{
                game.advance?
              }.to_not change(game, :current_player)
            end
          end
        end

        context "when on turn 2" do
          let(:game){FactoryGirl.create(:game_turn_2)}

          context "when the current player is not player 1" do
            let!(:current_player) do
              game.current_player.turn_status = WAITING_FOR_TURN
              game.current_player = game.players.find{|player| player.turn_num == game.num_players}
              game.current_player.turn_status = PLACING_INITIAL_ROAD
              game.current_player
            end    

            let(:next_player) do
              game.players.find{|player| player.turn_num == current_player.turn_num - 1}
            end

            include_examples "first n-1 players on turn 1 or last n-1 players on turn 2"
          end

          context "when the current player is player 1" do
            let!(:current_player) do
              game.current_player.turn_status = WAITING_FOR_TURN
              game.current_player = game.players.find{|player| player.turn_num == 1}
              game.current_player.turn_status = PLACING_INITIAL_ROAD
              game.current_player
            end

            include_examples "returns true"

            it "increments the game turn_num to 3" do
              game.advance?
              expect(game.turn_num).to eq(3)
            end

            it "sets the game status to playing" do
              game.advance?
              expect(game.playing?).to be true
            end

            it "sets the current player's turn status to READY_TO_ROLL" do
              game.advance?
              expect(current_player.turn_status).to eq(READY_TO_ROLL)
            end

            it "leaves game.current_player the same" do
              expect{
                game.advance?
              }.to_not change(game, :current_player)
            end
          end            
        end

        context "when the current turn is not 1 or 2" do
          let(:game) do
            g = FactoryGirl.create(:game_turn_1)
            g.turn_num = 3
            g
          end

          before(:each){game.current_player.turn_status = PLACING_INITIAL_ROAD}

          it "raises an exception" do
            expect{
              game.advance?
            }.to raise_error("There was an error")
          end
        end
      end
    end
  end

  describe "process_dice_roll?" do
    let(:game) {FactoryGirl.create(:game_started)}
    let(:player1) {game.players.find{|p| p.turn_num == 1}}
    let(:player2) {game.players.find{|p| p.turn_num == 2}}
    let(:player3) {game.players.find{|p| p.turn_num == 3}}

    shared_examples "returns true" do
      it "returns true" do
        expect(game.process_dice_roll?(dice_num)).to be true
      end      
    end

    shared_examples "leaves other players' statuses as WAITING_FOR_TURN" do
      it "leaves other players' statuses as WAITING_FOR_TURN" do
        game.process_dice_roll?(dice_num)
        expect(player2.turn_status).to eq(WAITING_FOR_TURN)
        expect(player3.turn_status).to eq(WAITING_FOR_TURN)
      end
    end

    shared_examples "success when not 7" do
      include_examples "returns true"

      it "changes the current_player's turn status to PLAYING_TURN" do
        game.process_dice_roll?(dice_num)
        expect(game.current_player.turn_status).to eq(PLAYING_TURN)
      end
    end

    context "when dice_num is a 7" do
      let(:dice_num) {7}

      context "when no players have more than 7 cards" do
        include_examples "returns true"

        it "changes the current_player's turn_status to MOVING_ROBBER" do
          game.process_dice_roll?(dice_num)
          expect(game.current_player.turn_status).to eq(MOVING_ROBBER)
        end

        include_examples "leaves other players' statuses as WAITING_FOR_TURN"
      end

      context "when the current_player doesn't have 8 or more cards but other players do" do
        before(:each){allow(player2).to receive(:get_resource_count).and_return(8)}

        include_examples "returns true"

        it "changes the current_player's status to WAITING_FOR_TURN" do
          game.process_dice_roll?(dice_num)
          expect(game.current_player.turn_status).to eq(WAITING_FOR_TURN)
        end

        it "changes the status of the player with 8 or more cards to DISCARDING_CARDS_DUE_TO_ROBBER" do
          game.process_dice_roll?(dice_num)
          expect(player2.turn_status).to eq(DISCARDING_CARDS_DUE_TO_ROBBER)
        end

        it "leaves other players without 8 or more cards as WAITING_FOR_TURN" do
          game.process_dice_roll?(dice_num)
          expect(player3.turn_status).to eq(WAITING_FOR_TURN)
        end

        context "when multiple other players have 8 or more cards" do
          before(:each){allow(player3).to receive(:get_resource_count).and_return(9)}

          it "sets all of their statuses to DISCARDING_CARDS_DUE_TO_ROBBER" do
            game.process_dice_roll?(dice_num)
            expect(player2.turn_status).to eq(DISCARDING_CARDS_DUE_TO_ROBBER)
            expect(player3.turn_status).to eq(DISCARDING_CARDS_DUE_TO_ROBBER)
          end
        end
      end

      context "when the current player has 8 or more cards" do
        before(:each) {allow(game.current_player).to receive(:get_resource_count).and_return(8)}

        include_examples "returns true"

        it "changes the current player's status to DISCARDING_CARDS_DUE_TO_ROBBER" do
          game.process_dice_roll?(dice_num)
          expect(game.current_player.turn_status).to eq(DISCARDING_CARDS_DUE_TO_ROBBER)
        end

        context "when other players have 8 or more cards" do
          before(:each){allow(player3).to receive(:get_resource_count).and_return(9)}

          it "changes their status to DISCARDING_CARDS_DUE_TO_ROBBER" do
            game.process_dice_roll?(dice_num)
            expect(player3.turn_status).to eq(DISCARDING_CARDS_DUE_TO_ROBBER)
          end
        end

        context "when other player's don't have 8 or more cards" do
          include_examples "leaves other players' statuses as WAITING_FOR_TURN"
        end
      end
    end

    context "when dice_num is not a 7" do
      context "when there are no resources to give" do
        let(:dice_num) {2}

        include_examples "success when not 7"

        it "does not call player.collect_resources? for any player" do
          expect_any_instance_of(Player).to_not receive(:collect_resources?)
        end
      end

      context "when there are resources to give" do
        let(:dice_num) {6}

        context "when the player.collect_resource? calls returns false" do
          before(:each){game.players.each{|p| allow(p).to receive(:collect_resources?).and_return(false)}}

          it "returns false" do
            expect(game.process_dice_roll?(dice_num)).to be_falsey
          end

          it "does not change the player's turn status" do
              game.process_dice_roll?(dice_num)
              game.current_player.reload
              expect(game.current_player.turn_status).to eq(READY_TO_ROLL)
          end
        end

        context "when all of the player.collect_resource? calls return true" do
          before(:each){game.players.each{|p| allow(p).to receive(:collect_resources?).and_return(true)}}

          include_examples "success when not 7"

          it "hands out correct resources to players who have settlements on the hexes that were rolled" do
            expect(player1).to receive(:collect_resources?).with({WOOD => 1})
            expect(player2).to receive(:collect_resources?).with({ORE => 2})
            expect(player3).to_not receive(:collect_resources?)
            game.process_dice_roll?(dice_num)
          end

          context "when a player gets more than one type of resource" do
            let(:dice_num){3}

            it "hands out correct resources to players who have settlements on the hexes that were rolled" do
              expect(player1).to receive(:collect_resources?).with({WOOD => 1, ORE => 1})
              game.process_dice_roll?(dice_num)
            end
          end

          context "when the robber is on one of the hexes that are rolled" do
            before(:each) do
              game.robber_x = 1
              game.robber_y = 3
            end

            it "hands out correct resources to players who have settlements on the hexes that were rolled except the robber hex" do
              expect(player1).to receive(:collect_resources?).with({WOOD => 1})
              expect(player2).to_not receive(:collect_resources?)
              expect(player3).to_not receive(:collect_resources?)
              game.process_dice_roll?(dice_num)
            end
          end

          context "when a city is on a hex that was rolled" do
            before(:each) {player1.settlements.find{|s| s.vertex_x == 4 && s.vertex_y == 0 && s.side == 0}.is_city = true}

            it "gives that player 2 resources instead of 1" do
              expect(player1).to receive(:collect_resources?).with({WOOD => 2})
              game.process_dice_roll?(dice_num)
            end
          end
        end
      end
    end
  end

  describe "player_finished_discarding?" do
    let(:game) {FactoryGirl.create(:game_started)}

    shared_examples "returns true" do
      it "returns true" do
        expect(game.player_finished_discarding?(calling_player)).to be true
      end
    end

    shared_examples "set's calling player to WAITING_FOR_TURN" do
      it "sets the calling player's status to WAITING_FOR_TURN" do
        game.player_finished_discarding?(calling_player)
        expect(calling_player.turn_status).to eq(WAITING_FOR_TURN)
      end
    end

    shared_examples "set's current_player to MOVING_ROBBER" do
      it "sets the current_player's status to MOVING_ROBBER" do
        game.player_finished_discarding?(calling_player)
        expect(game.current_player.turn_status).to eq(MOVING_ROBBER)
      end
    end

    context "when there are still other players who need to discard" do
      before(:each) do
        game.players.first.turn_status = DISCARDING_CARDS_DUE_TO_ROBBER
        game.players.last.turn_status = DISCARDING_CARDS_DUE_TO_ROBBER
      end
      let(:calling_player) {game.players.first}

      include_examples "returns true"
      include_examples "set's calling player to WAITING_FOR_TURN"
    end

    context "when everyone else is done discarding" do
      context "when the calling player is the current_player" do
        before(:each) do
          game.current_player.turn_status = DISCARDING_CARDS_DUE_TO_ROBBER
        end
        let(:calling_player) {game.current_player}

        include_examples "returns true"
        include_examples "set's current_player to MOVING_ROBBER"
      end

      context "when the calling player is not the current_player" do
        before(:each) do
          game.current_player.turn_status = WAITING_FOR_TURN          
        end
        let(:calling_player) do
          player = game.players.find{|p| p != game.current_player}
          player.turn_status = DISCARDING_CARDS_DUE_TO_ROBBER
          player
        end

        include_examples "returns true"
        include_examples "set's current_player to MOVING_ROBBER"
        include_examples "set's calling player to WAITING_FOR_TURN"
      end
    end
  end
end
