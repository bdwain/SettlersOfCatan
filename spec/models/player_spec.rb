require 'spec_helper'

describe Player do
  describe "game" do
    it { should belong_to(:game) }
    it { should validate_presence_of(:game) }
  end

  describe "user" do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user) }
    it "validates_uniqueness_of user_id scoped to game_id" do
      #needed because the validation fails without a player precreated. See docs.
      FactoryGirl.create(:player)
      should validate_uniqueness_of(:user_id).scoped_to(:game_id)
     end 
  end

  describe "resources" do
    it { should have_many(:resources).dependent(:destroy) }
  end

  describe "development_cards" do
    it { should have_many(:development_cards).dependent(:destroy) }
  end

  describe "settlements" do
    it { should have_many(:settlements).dependent(:destroy) }
  end

  describe "roads" do
    it { should have_many(:roads).dependent(:destroy) }
  end

  describe "chats" do
    it { should have_many(:chats) }
  end

  describe "game_logs" do
    it { should have_many(:game_logs) }
  end

  describe "dice_rolls" do
    it { should have_many(:dice_rolls) }
  end  

  describe "turn_num" do
    it { should validate_presence_of(:turn_num) }
    it { should validate_numericality_of(:turn_num).only_integer }
    it { should ensure_inclusion_of(:turn_num).in_range(1..4) } 
  end

  describe "turn_status" do
    it { should validate_presence_of(:turn_status) }
    it { should validate_numericality_of(:turn_status).only_integer }
    it { should_not allow_value(-1).for(:turn_status) }
    it { should allow_value(0).for(:turn_status) }        
  end

  describe "add_initial_settlement?" do
    let(:game) { FactoryGirl.create(:game_playing) }

    shared_examples "add_initial_settlement? failures" do
      it "returns false" do
        player.add_initial_settlement?(1, 3).should be_false
      end

      it "does not change the player's turn_status" do
        expect{
          player.add_initial_settlement?(1, 3)
        }.to_not change(player, :turn_status)
      end

      it "does not create a new game log" do
        expect{
          player.add_initial_settlement?(1, 3)
        }.to_not change(player.game_logs, :count)
      end

      it "does not create a new settlement" do
        expect{
          player.add_initial_settlement?(1, 3)
        }.to_not change(player.settlements, :count)
      end
    end

    context "when player is not status PLACING_INITIAL_SETTLEMENT" do
      let(:player) {game.players.detect {|p| p.turn_status != PLACING_INITIAL_SETTLEMENT}}
      include_examples "add_initial_settlement? failures"
    end

    context "when player is PLACING_INITIAL_SETTLEMENT" do
      let(:player) {game.players.detect {|p| p.turn_status == PLACING_INITIAL_SETTLEMENT}}
      let(:board) {double("GameBoard")}
      before(:each) { game.stub(:game_board).and_return(board) }
      context "when x,y is not free for building" do
        before(:each) {board.stub(:vertex_is_free_for_building?).and_return(false)}
        include_examples "add_initial_settlement? failures"
      end

      context "when x,y is free for building" do
        before(:each) {board.stub(:vertex_is_free_for_building?).and_return(true)}
        it "returns true" do
          player.add_initial_settlement?(1, 0).should be_true
        end

        it "sets the player's turn_status to PLACING_INITIAL_ROAD" do
          player.add_initial_settlement?(1, 0)
          player.turn_status.should eq(PLACING_INITIAL_ROAD)
        end

        it "creates a new game_log with the game's turn number" do
          expect{
            player.add_initial_settlement?(1, 0)
          }.to change(player.game_logs, :count).by(1)

          player.game_logs.last.turn_num.should eq(game.turn_num)
        end

        it "creates a new game_log with the text \"user.displayname placed a settlement on x,y\"" do
          player.add_initial_settlement?(1, 0)
          player.game_logs.last.msg.should eq("#{player.user.displayname} placed a settlement on (1,0)")
        end

        it "creates a new settlement with for the user at x,y" do
          expect{
            player.add_initial_settlement?(1, 0)
          }.to change(player.settlements, :count).by(1)

          player.settlements.last.vertex_x.should eq(1)
          player.settlements.last.vertex_y.should eq(0)
        end
      end
    end
  end
end
