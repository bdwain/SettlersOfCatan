require 'spec_helper'

describe Game do
  describe "winner" do
    it { should belong_to(:winner).class_name('User') }
  end

  describe "hexes" do
    it { should have_many(:hexes) }
  end
 
  describe "harbors" do
    it { should have_many(:harbors) }
  end

  describe "players" do
    it { should have_many(:players) }
  end

  describe "development_cards" do
    it { should have_many(:development_cards) }
  end

  describe "status" do
    it { should validate_presence_of(:status) }
    it { should ensure_inclusion_of(:status).in_array([*1..5, 1000]) }
  end

  describe "middle_row_width" do
    it { should validate_presence_of(:middle_row_width) }
    it { should validate_numericality_of(:middle_row_width).only_integer }
    it { should_not allow_value(4).for(:middle_row_width) }
    it { should allow_value(5).for(:middle_row_width) }
  end

  describe "num_middle_rows" do
    it { should validate_presence_of(:num_middle_rows) }
    it { should validate_numericality_of(:num_middle_rows).only_integer }
    it { should_not allow_value(0).for(:num_middle_rows) }
    it { should allow_value(1).for(:num_middle_rows) }
  end

  describe "num_rows" do
    it { should validate_presence_of(:num_rows) }
    it { should validate_numericality_of(:num_rows).only_integer }
    it { should_not allow_value(4).for(:num_rows) }
    it { should allow_value(5).for(:num_rows) }
  end

  describe "num_players" do
    it { should validate_presence_of(:num_players) }
    it { should validate_numericality_of(:num_players).only_integer }
    it { should ensure_inclusion_of(:num_players).in_range(3..4) } 
  end

  describe "robber_x" do
    it { should validate_presence_of(:robber_x) }
    it { should validate_numericality_of(:robber_x).only_integer }
  end

  describe "robber_y" do
    it { should validate_presence_of(:robber_y) }
    it { should validate_numericality_of(:robber_y).only_integer }
  end

  describe "abandoned_by" do   
    context "when player id is in the game" do
      shared_examples "abandoned_by doesn't change status" do
        it "does not set the game status to abandoned" do
          game = FactoryGirl.create(:partially_filled_game)
          game.status = status
          expect {
            game.abandoned_by(game.players.first)
          }.to_not change(game, :status)
        end
      end

      shared_examples "abandoned_by calls remove_player?" do
        it "calles remove_player?" do
          game = FactoryGirl.create(:partially_filled_game)
          game.status = status
          game.should_receive(:remove_player?).with(game.players.first)
          game.abandoned_by(game.players.first)
        end
      end

      context "when waiting for players" do
        let(:status) {1}
        include_examples "abandoned_by doesn't change status"
        include_examples "abandoned_by calls remove_player?"
      end

      context "when completed" do
        let(:status) {5}
        include_examples "abandoned_by doesn't change status"
        include_examples "abandoned_by calls remove_player?"
      end

      context "when abandoned" do
        let(:status) {1}
        include_examples "abandoned_by doesn't change status"
        include_examples "abandoned_by calls remove_player?"
      end

      context "when game is in play" do
        let(:status) {2}
        it "sets the game status to abandoned" do
          game = FactoryGirl.create(:game_started)
          game.abandoned_by(game.players.first)
          game.abandoned?.should be_true
        end

        include_examples "abandoned_by calls remove_player?"
      end
    end

    context "when player id is not in the game" do
      it "doesn't set the game status to abandoned" do
        game = FactoryGirl.create(:partially_filled_game)
        otherPlayer = FactoryGirl.create(:player)
        game.abandoned_by(otherPlayer)
        game.abandoned?.should be_false
      end

      it "doesn't call remove_player?" do
        game = FactoryGirl.create(:partially_filled_game)
        otherPlayer = FactoryGirl.create(:player)
        game.should_not_receive(:remove_player?)
        game.abandoned_by(otherPlayer)
      end
    end
  end

  describe "status_checkers" do
    before(:all) do
      @rand = Random.new
      @game = FactoryGirl.build(:game)
    end

    describe "abandoned?" do
      it "returns true if status is 1000" do
        @game.status = 1000
        @game.abandoned?.should be_true
      end
      
      it "returns false if status is not 1000" do
        @game.status = @rand.rand(1..100)
        @game.abandoned?.should be_false
      end
    end

    describe "waiting_for_players?" do
      it "returns true if status is 1" do
        @game.status = 1
        @game.waiting_for_players?.should be_true
      end
      
      it "returns false if status is not 1" do
        @game.status = @rand.rand(2..100)
        @game.waiting_for_players?.should be_false
      end
    end

    describe "rolling_for_turn_order?" do
      it "returns true if status is 2" do
        @game.status = 2
        @game.rolling_for_turn_order?.should be_true
      end
      
      it "returns false if status is not 2" do
        @game.status = @rand.rand(1..100) until @game.status != 2
        @game.rolling_for_turn_order?.should be_false
      end
    end

    describe "placing_initial_pieces?" do
      it "returns true if status is 3" do
        @game.status = 3
        @game.placing_initial_pieces?.should be_true
      end
      
      it "returns false if status is not 3" do
        @game.status = @rand.rand(1..100) until @game.status != 3
        @game.placing_initial_pieces?.should be_false
      end
    end

    describe "playing?" do
      it "returns true if status is 4" do
        @game.status = 4
        @game.playing?.should be_true
      end
      
      it "returns false if status is not 4" do
        @game.status = @rand.rand(1..100) until @game.status != 4
        @game.playing?.should be_false
      end
    end

    describe "completed?" do
      it "returns true if status is 5" do
        @game.status = 5
        @game.completed?.should be_true
      end
      
      it "returns false if status is not 5" do
        @game.status = @rand.rand(1..100) until @game.status != 5
        @game.completed?.should be_false
      end
    end
  end

  describe "player?" do
    it "returns true if a game's players include user" do
      game = FactoryGirl.create(:full_game)
      game.player?(game.players.first.user).should be_true
    end

    it "returns false if a game's players do not include user" do
      game = FactoryGirl.create(:full_game)
      user = FactoryGirl.build(:confirmed_user)
      game.player?(user).should be_false
    end

    it "returns false if user is nil" do
      game = FactoryGirl.create(:full_game)
      game.player?(nil).should be_false
    end
  end

  describe "player" do
    it "returns the first player when passed the corresponding user" do
      game = FactoryGirl.create(:full_game)
      game.player(game.players.first.user).should equal(game.players.first)
    end

    #Added this test after accidentally looking for a player with user_id == id,
    #which allowed return the wrong player while passing the other tests
    it "returns the last player when passed the corresponding user" do
      game = FactoryGirl.create(:full_game)
      game.player(game.players.last.user).should equal(game.players.last)
    end

    it "returns nil if the user isn't playing" do
      game = FactoryGirl.create(:full_game)
      user = FactoryGirl.build(:confirmed_user)
      game.player(user).should be_false
    end

    it "returs nil if passed nil" do
      game = FactoryGirl.create(:full_game)
      game.player(nil).should be_false
    end
  end

  describe "add_user?" do
    shared_examples "add_player?_failures" do
      it "returns false" do
        @game.add_user?(@user).should be_false
      end

      it "does not add players to the game" do
        expect{
          @game.add_user?(@user)
        }.to_not change(@game.players, :count)
      end
    end

    context "when the input is expected" do
      context "when the game is still waiting for players" do
        before(:each) do
          @game = FactoryGirl.create(:game)
          @user = FactoryGirl.create(:confirmed_user)
        end

        it "returns true" do
          @game.add_user?(@user).should be_true
        end

        it "adds a player to the game" do
          expect{
            @game.add_user?(@user)
          }.to change(@game.players, :count).by(1)
        end

        it "sets the new player's game properly" do
          @game.add_user?(@user)
          @game.players.last.game.should be(@game)
        end

        it "sets the new player's user properly" do
          @game.add_user?(@user)
          @game.players.last.user.should be(@user)
        end

        it "makes the new player valid" do
          @game.add_user?(@user)
          @game.players.last.should be_valid
        end
      end

      context "when the game is full" do
        before(:each) do
          @game = FactoryGirl.create(:full_game)
          @user = FactoryGirl.create(:confirmed_user)
        end

        include_examples "add_player?_failures"
      end

      context "when the game has started" do
        before(:each) do
          @game = FactoryGirl.create(:game_started)
          @user = FactoryGirl.create(:confirmed_user)
        end

        include_examples "add_player?_failures"
      end
    end

    context "when the input is not expected" do
      before(:each) do
        @game = FactoryGirl.create(:game)
      end

      context "when the user is nil" do
        include_examples "add_player?_failures"
      end

      context "when the user is unconfirmed" do
        before(:each) do
          @user = FactoryGirl.create(:user)
        end

          include_examples "add_player?_failures"
      end

      context "when the user already joined the game" do
        before(:each) do
          @user = FactoryGirl.create(:confirmed_user)
          FactoryGirl.create(:player, user: @user, game: @game)
        end

        include_examples "add_player?_failures"
      end
    end
  end

  describe "remove_player?" do
    shared_examples "remove_player?_failures" do
      it "returns false" do
        game.remove_player?(player).should be_false
      end

      it "does not remove players from the game" do
        expect{
          game.remove_player?(player)
        }.to_not change(game.players, :count)
      end
    end

    shared_examples "remove_player?_successes" do
      context "when the game has one player left" do
        before(:each) do
          @game = FactoryGirl.create(:player).game
          @game.status = status
        end

        it "returns true" do
          @game.remove_player?(@game.players.first).should be_true
        end

        it "destroys the game" do
          expect{
            @game.remove_player?(@game.players.first)
          }.to change(Game, :count).by(-1)
        end

        it "destroys the player" do
          expect{
            @game.remove_player?(@game.players.first)
          }.to change(Player, :count).by(-1)
        end
      end

      context "when the game has more than one player left" do
        before(:each) do
          @game = FactoryGirl.create(:full_game, status: status)
        end

        it "returns true" do
          @game.remove_player?(@game.players.first).should be_true
        end

        it "does not destroy the game" do
          expect{
            @game.remove_player?(@game.players.first)
          }.to_not change(Game, :count)
        end

        it "destroys the player" do
          expect{
            @game.remove_player?(@game.players.first)
          }.to change(@game.players, :count).by(-1)
        end
      end
    end

    context "when the input is expected" do
      context "when the game is stil waiting for players" do
        let(:status) { 1 } 

        include_examples "remove_player?_successes"
      end

      context "when the game already started" do
        let(:game) { FactoryGirl.create(:game_started) }
        let(:player) { game.players.first }

        include_examples "remove_player?_failures"
      end

      context "when the game is completed" do
        let(:status) { 5 } 

        include_examples "remove_player?_successes"
      end

      context "when the game is abandoned" do
        let(:status) { 1000 }

        include_examples "remove_player?_successes"
      end
    end
    
    context "when the input is not expected" do
      let(:game) { FactoryGirl.create(:full_game) }

      context "when player is nil" do
        let(:player) { nil }
        include_examples "remove_player?_failures"
      end

      context "when player not in game" do
        let(:game2) { FactoryGirl.create(:partially_filled_game) }
        let(:player) { game2.players.first }

        include_examples "remove_player?_failures"

        #make sure it's looking by playerid and not user id
        context "when player's user is playing in this game as well" do
          let(:player) { FactoryGirl.create(:player, user: game.players.first.user, game: game2) }

          include_examples "remove_player?_failures"
        end
      end
    end
  end
end
