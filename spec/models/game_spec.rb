require 'spec_helper'

describe Game do
  describe "creator" do
    it { should belong_to(:creator).class_name('User') }
    it { should validate_presence_of(:creator) }
  end

  describe "winner" do
    it { should belong_to(:winner).class_name('User') }
  end

  describe "hexes" do
    it { should have_many(:hexes).dependent(:destroy) }
  end
 
  describe "harbors" do
    it { should have_many(:harbors).dependent(:destroy) }
  end

  describe "players" do
    it { should have_many(:players).dependent(:destroy) }
  end

  describe "development_cards" do
    it { should have_many(:development_cards).dependent(:destroy) }
  end

  describe "status" do
    it { should validate_presence_of(:status) }
    it { should ensure_inclusion_of(:status).in_range(1..3) }
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

    describe "playing?" do
      it "returns true if status is 2" do
        game.status = 2
        game.playing?.should be_true
      end
      
      it "returns false if status is not 2" do
        game.status = 3
        game.playing?.should be_false
      end
    end

    describe "completed?" do
      it "returns true if status is 3" do
        game.status = 3
        game.completed?.should be_true
      end
      
      it "returns false if status is not 3" do
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

  describe "player_account_deleted" do
    shared_examples "player_account_deleted game not destroyed" do
      it "does not delete the game" do
        expect{
          game.player_account_deleted(player)
        }.to_not change(Game, :count)
      end
    end

    shared_examples "player_account_deleted remove_player? not called" do
      it "does not call remove_player?" do
        game.should_not_receive(:remove_player?)
        game.player_account_deleted(player)
      end
    end    

    let!(:game) { FactoryGirl.create(:game) }
    context "when player is not nil" do
      context "when player is in the game" do
        let(:player) { game.creator.players.first }

        context "remove_player? returns true" do
          before(:each) { game.should_receive(:remove_player?).with(player).and_return(true) }
          include_examples "player_account_deleted game not destroyed"
        end

        context "remove_player? returns false" do
          before(:each) { game.stub(:remove_player?).and_return(false) }
          
          it "destroys the game" do
            expect{
              game.player_account_deleted(player)
            }.to change(Game, :count).by(-1)
          end
        end
      end
      
      context "player is not in the game" do
        let!(:player) { FactoryGirl.create(:player) }
        include_examples "player_account_deleted game not destroyed"
        include_examples "player_account_deleted remove_player? not called"  
      end
    end

    context "player is nil" do
      let(:player) {nil}
      include_examples "player_account_deleted game not destroyed"
      include_examples "player_account_deleted remove_player? not called"      
    end
  end
end
