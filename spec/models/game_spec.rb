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

  describe "status_checkers" do
    let(:game) { FactoryGirl.build_stubbed(:game) }

    describe "waiting_for_players?" do
      it "returns true if status is 1" do
        game.status = 1
        game.waiting_for_players?.should be_true
      end
      
      it "returns false if status is not 1" do
        game.status = 2
        game.waiting_for_players?.should be_false
      end
    end

    describe "placing_initial_pieces?" do
      it "returns true if status is 2" do
        game.status = 2
        game.placing_initial_pieces?.should be_true
      end
      
      it "returns false if status is not 2" do
        game.status = 3
        game.placing_initial_pieces?.should be_false
      end
    end    

    describe "playing?" do
      it "returns true if status is 3" do
        game.status = 3
        game.playing?.should be_true
      end
      
      it "returns false if status is not 2" do
        game.status = 4
        game.playing?.should be_false
      end
    end

    describe "completed?" do
      it "returns true if status is 4" do
        game.status = 4
        game.completed?.should be_true
      end
      
      it "returns false if status is not 4" do
        game.status = 1
        game.completed?.should be_false
      end
    end
  end

  describe "player" do
    let(:game) { FactoryGirl.create(:partially_filled_game) }

    it "returns the first player when passed the corresponding user" do
      game.player(game.players.first.user).should equal(game.players.first)
    end

    #Added this test after accidentally looking for a player with user_id == id,
    #which caused it to return the wrong player while passing the other tests
    it "returns the last player when passed the corresponding user" do
      game.player(game.players.last.user).should equal(game.players.last)
    end

    it "returns nil if the user isn't playing" do
      user = FactoryGirl.build_stubbed(:confirmed_user)
      game.player(user).should be_nil
    end

    it "returs nil if passed nil" do
      game.player(nil).should be_nil
    end
  end

  describe "player?" do
    let(:game) { FactoryGirl.create(:partially_filled_game) }

    it "returns true if a game's players include user" do
      game.player?(game.players.first.user).should be_true
    end

    it "returns false if a game's players do not include user" do
      user = FactoryGirl.build_stubbed(:confirmed_user)
      game.player?(user).should be_false
    end

    it "returns false if user is nil" do
      game.player?(nil).should be_false
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
      game.players.first.user.should be game.creator
    end

    it "doesn't save the game when creating the player fails" do
      game.should_receive(:add_user?).and_return(false)
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
        game.add_user?(user).should be_false
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
          before(:each) { game.should_receive(:waiting_for_players?).at_least(:once).and_return(true) }

          context "when the user is not already in the game" do
            it "returns true" do
              game.add_user?(user).should be_true
            end

            it "add a player with the right user to the game" do
              expect{
                game.add_user?(user)
              }.to change(game.players, :count).by(1)

              game.players.last.user.should eq(user)
            end
          end

          context "when the user is already in the game" do
            before(:each) { game.add_user?(game.creator) }
            include_examples "add_user? failures"
          end
        end

        context "when not waiting for players" do
          before(:each) { game.stub(:waiting_for_players?).and_return(false) }
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
        game.remove_player?(player).should be_true
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
        game.remove_player?(player).should be_false
      end      
    end    

    let!(:game) { FactoryGirl.create(:game) }
    context "when the player is not nil" do
      context "when the game is still waiting for players" do
        before(:each) { game.should_receive(:waiting_for_players?).and_return(true) }

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
        before(:each) { game.stub(:waiting_for_players?).and_return(false) }
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
        game.players.sort_by! {|p| p.turn_num }.each_with_index do |player, index|
          player.turn_num.should eq(index + 1)
        end
      end

      it "gives each player each resource with a count of 0" do
        expect{
          game.save
        }.to change(Resource, :count).by(5*game.num_players)
        game.players.each do |player|
          player.resources.collect {|resource| resource.type}.sort.should eq([WOOL, WOOD, WHEAT, ORE, BRICK].sort)
          player.resources.all?{|resource| resource.count == 0}.should be_true
        end
      end

      it "creates a correct deck of development cards" do
        expect{
          game.save
        }.to change(DevelopmentCard, :count).by(25)
        game.development_cards.where(:type => KNIGHT).count.should eq(14)
        game.development_cards.where(:type => VICTORY_POINT).count.should eq(5)
        game.development_cards.where(:type => ROAD_BUILDING).count.should eq(2)
        game.development_cards.where(:type => YEAR_OF_PLENTY).count.should eq(2)
        game.development_cards.where(:type => MONOPOLY).count.should eq(2)
      end

      it "sets player 1's status to PLAYING_TURN and everyone else to WAITING_FOR_TURN" do
        game.save
        game.players.each do |player|
          player.turn_status.should eq(player.turn_num == 1 ? PLACING_INITIAL_SETTLEMENT : WAITING_FOR_TURN)
        end
      end

      it "changes the status to placing initial pieces" do
        game.placing_initial_pieces?.should be_false
        game.save
        game.placing_initial_pieces?.should be_true
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
        game.advance?.should be_false
      end
    end

    shared_examples "returns true" do
      it "returns true" do
        game.advance?.should be_true
      end
    end

    shared_examples "first n-1 players on turn 1 or last n-1 players on turn 2" do
      include_examples "returns true"

      it "sets the next player's turn status to PLACING_INITIAL_SETTLEMENT" do
        game.advance?
        next_player.turn_status.should eq(PLACING_INITIAL_SETTLEMENT)
      end

      it "sets the current player's turn status to WAITING_FOR_TURN" do
        game.advance?
        current_player.turn_status.should eq(WAITING_FOR_TURN)
      end
    end

    context "when the game is placing initial pieces" do
      context "when on turn 1" do
        let(:game){FactoryGirl.create(:game_turn_1)}

        context "when the current player is not the last player" do
          let!(:current_player) do
            player = game.players.find{|player| player.turn_status == PLACING_INITIAL_SETTLEMENT}
            player.turn_status = PLACING_INITIAL_ROAD
            player
          end

          let(:next_player) {game.players.find{|player| player.turn_num == current_player.turn_num + 1}}

          include_examples "first n-1 players on turn 1 or last n-1 players on turn 2"
        end

        context "when the current player is the last player" do
          let!(:current_player) do
            player = game.players.find{|player| player.turn_status == PLACING_INITIAL_SETTLEMENT}
            player.turn_status = WAITING_FOR_TURN
            player = game.players.find{|player| player.turn_num == game.num_players}
            player.turn_status = PLACING_INITIAL_ROAD
            player
          end          

          include_examples "returns true"

          it "increments the game turn_num to 2" do
            game.advance?
            game.turn_num.should eq(2)
          end

          it "sets the current player's turn status to PLACING_INITIAL_SETTLEMENT" do
            game.advance?
            current_player.turn_status.should eq(PLACING_INITIAL_SETTLEMENT)
          end
        end
      end

      context "when on turn 2" do
        let(:game) do
          g = FactoryGirl.create(:game_turn_1)
          g.turn_num = 2
          g
        end

        context "when the current player is not player 1" do
          let!(:current_player) do
            player = game.players.find{|player| player.turn_status == PLACING_INITIAL_SETTLEMENT}
            player.turn_status = WAITING_FOR_TURN
            player = game.players.find{|player| player.turn_num == game.num_players}
            player.turn_status = PLACING_INITIAL_ROAD
            player
          end    

          let(:next_player) do
            game.players.find{|player| player.turn_num == current_player.turn_num - 1}
          end

          include_examples "first n-1 players on turn 1 or last n-1 players on turn 2"
        end

        context "when the current player is player 1" do
          let!(:current_player) do
            player = game.players.find{|player| player.turn_status == PLACING_INITIAL_SETTLEMENT}
            player.turn_status = PLACING_INITIAL_ROAD
            player
          end

          include_examples "returns true"

          it "increments the game turn_num to 3" do
            game.advance?
            game.turn_num.should eq(3)
          end

          it "sets the game status to playing" do
            game.advance?
            game.playing?.should be_true
          end

          it "sets the current player's turn status to READY_TO_ROLL" do
            game.advance?
            current_player.turn_status.should eq(READY_TO_ROLL)
          end
        end            
      end

      context "when the current turn is not 1 or 2" do
        let(:game) do
          g = FactoryGirl.create(:game_turn_1)
          g.turn_num = 3
          g
        end

        before(:each) do
          game.players.find{|player| player.turn_status == PLACING_INITIAL_SETTLEMENT}.turn_status = PLACING_INITIAL_ROAD
        end

        it "raises an exception" do
          expect{
            game.advance?
          }.to raise_error("There was an error")
        end
      end
    end
  end
end
