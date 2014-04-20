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

  describe "add_settlement?" do
    let(:game) { FactoryGirl.build_stubbed(:game_turn_1) }
    let(:board) {double("GameBoard")}
    before(:each) { game.stub(:game_board).and_return(board) }
    let(:player) {FactoryGirl.build(:in_game_player)}
    before(:each) {player.game = game}

    shared_examples "add_settlement? failures" do
      it "returns false" do
        player.add_settlement?(1, 1, 0).should be_false
      end

      it "does not change the player's turn_status" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to_not change(player, :turn_status)
      end

      it "does not create a new game log" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to_not change(player.game_logs, :count)
      end

      it "does not create a new settlement" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to_not change(player.settlements, :count)
      end

      include_examples "add_settlement? does not add new resources"
    end

    shared_examples "add_settlement? does not add new resources" do
      it "does not add new resources" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to_not change(player, :resources)
      end
    end

    shared_examples "add_settlement? successes" do
      it "returns true" do
        player.add_settlement?(1, 1, 0).should be_true
      end

      it "sets the player's turn_status to PLACING_INITIAL_ROAD" do
        player.add_settlement?(1, 1, 0)
        player.turn_status.should eq(PLACING_INITIAL_ROAD)
      end

      it "creates a new game_log with the game's turn number and proper text" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to change(player.game_logs, :count).by(1)

        player.game_logs.last.turn_num.should eq(game.turn_num)
        player.game_logs.last.msg.should eq("#{player.user.displayname} placed a settlement on (1,1,0)")
      end

      it "creates a new settlement for the user at x,y,side" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to change(player.settlements, :count).by(1)

        player.settlements.last.vertex_x.should eq(1)
        player.settlements.last.vertex_y.should eq(1)
        player.settlements.last.side.should eq(0)
      end
    end

    context "when x,y is not free for building" do
      before(:each) {board.stub(:vertex_is_free_for_building?).and_return(false)}

      include_examples "add_settlement? failures"
    end

    context "when x,y is free for building" do
      before(:each) {board.stub(:vertex_is_free_for_building?).and_return(true)}

      context "when player is status PLACING_INITIAL_SETTLEMENT" do
        before(:each) do
          player.turn_status = PLACING_INITIAL_SETTLEMENT
          hexes = [Hex.new(resource_type: WOOD), Hex.new(resource_type: WOOL), Hex.new(resource_type: WOOD)]
          board.stub(:get_hexes_from_vertex).and_return(hexes)
        end

        context "when turn number is 1" do
          before(:each) {player.game.turn_num = 1}

          include_examples "add_settlement? successes"
          include_examples "add_settlement? does not add new resources"
        end

        context "when turn number is 2" do
          before(:each) {player.game.turn_num = 2}
          
          include_examples "add_settlement? successes"
          
          it "sets the player's resource counts properly" do
            player.add_settlement?(1, 1, 0)
            player.resources.find{|resource| resource.type == WOOD}.count.should eq(2)
            player.resources.find{|resource| resource.type == WOOL}.count.should eq(1)
            player.resources.find{|resource| resource.type == ORE}.count.should eq(0)
            player.resources.find{|resource| resource.type == BRICK}.count.should eq(0)
            player.resources.find{|resource| resource.type == WHEAT}.count.should eq(0)
          end
        end        
      end

      #TODO: add in when player is playing turn
      
      context "when player is not status PLACING_INITIAL_SETTLEMENT" do
        before(:each) {player.stub(:turn_status).and_return(WAITING_FOR_TURN)}

        include_examples "add_settlement? failures"
      end
    end
  end

  describe "add_road?" do
    let(:game) { FactoryGirl.build_stubbed(:game_turn_1) }
    let(:board) {double("GameBoard")}
    before(:each) { game.stub(:game_board).and_return(board) }
    let(:player) {FactoryGirl.build(:player)}
    before(:each) {player.game = game}

    shared_examples "add_road? failures" do
      it "returns false" do
        player.add_road?(x, y, side).should be_false
      end

      it "does not create a new game log" do
        expect{
          player.add_road?(x, y, side)
        }.to_not change(player.game_logs, :count)
      end

      it "does not create a new road" do
        expect{
          player.add_road?(x, y, side)
        }.to_not change(player.roads, :count)
      end
    end

    shared_examples "does not call game.advance?" do
      it "does not call game.advance?" do
        game.should_not_receive(:advance?)
        player.add_road?(x, y, side)
      end
    end

    context "when x,y is not free for building" do
      let(:x) {-10}
      let(:y) {-10}
      let(:side) {0}
      before(:each) {board.should_receive(:edge_is_free_for_building_by_player?).with(x, y, side, player).and_return(false)}

      include_examples "add_road? failures"
      include_examples "does not call game.advance?"
    end

    context "when x,y is free for building" do
      let(:x) {2}
      let(:y) {2}
      let(:side) {0}
      before(:each) {board.should_receive(:edge_is_free_for_building_by_player?).with(x, y, side, player).and_return(true)}
      
      context "when player is status PLACING_INITIAL_ROAD" do
        before(:each) {player.turn_status = PLACING_INITIAL_ROAD}

        context "when the edge is not touching the last settlement the player built" do
          context "when the player has only 1 settlement" do
            before(:each) do
              player.settlements.build(:vertex_x => 0, :vertex_y => 2, :side => 0)
              board.should_receive(:edge_is_connected_to_vertex?).with(x, y, side, 0, 2, 0).and_return(false)
            end
            include_examples "add_road? failures"
            include_examples "does not call game.advance?"
          end

          context "when the player has 2 settlements" do
            before(:each) do
              player.settlements.build(:vertex_x => 2, :vertex_y => 2, :side => 0)
              player.settlements.build(:vertex_x => 0, :vertex_y => 2, :side => 0)
              board.should_receive(:edge_is_connected_to_vertex?).with(x, y, side, 0, 2, 0).and_return(false)
            end

            include_examples "add_road? failures"
            include_examples "does not call game.advance?"
          end
        end

        context "when the edge is touching the last settlement the player built" do
          before(:each) do
            player.settlements.build(:vertex_x => 2, :vertex_y => 2, :side => 0)
            board.should_receive(:edge_is_connected_to_vertex?).with(x, y, side, 2, 2, 0).and_return(true)
          end

          context "when game.advance? returns true" do
            before(:each) {game.stub(:advance?).and_return(true)}

            it "returns true" do
              player.add_road?(x, y, side).should be_true
            end

            it "creates a new game_log with the game's turn number and proper text" do
              expect{
                player.add_road?(x, y, side)
              }.to change(player.game_logs, :count).by(1)

              player.game_logs.last.turn_num.should eq(game.turn_num)
              player.game_logs.last.msg.should eq("#{player.user.displayname} placed a road on (#{x},#{y},#{side})")
            end

            it "creates a new road with for the user at x,y,side" do
              expect{
                player.add_road?(x, y, side)
              }.to change(player.roads, :count).by(1)

              player.roads.last.edge_x.should eq(x)
              player.roads.last.edge_y.should eq(y)
              player.roads.last.side.should eq(side)
            end

            it "calls game.advance?" do
              game.should_receive(:advance?)
              player.add_road?(x, y, side)
            end
          end

          context "when game.advance? returns false" do
            before(:each) {game.stub(:advance?).and_return(false)}

            include_examples "add_road? failures"
          end
        end
      end

      #TODO: add in when player is playing turn
      
      context "when player is not status PLACING_INITIAL_ROAD" do
        before(:each) {player.stub(:turn_status).and_return(WAITING_FOR_TURN)}

        include_examples "add_road? failures"
        include_examples "does not call game.advance?"
      end
    end
  end  
end
