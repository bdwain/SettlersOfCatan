require 'spec_helper'

describe Player do
  describe "game" do
    it { should belong_to(:game) }
    it { should validate_presence_of(:game) }
  end

  describe "user" do
    it { should belong_to(:user) }
    it { should validate_presence_of(:user) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:game_id) }
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

  describe "get_resource_count" do
    let(:player) {FactoryGirl.build_stubbed(:player)}
    before(:each){player.stub(:resources).and_return(resources)}

    context "when the player has no resources" do
      let(:resources) {[FactoryGirl.build(:resource, {type: WOOD, count: 0, player: player}), 
        FactoryGirl.build(:resource, {type: WHEAT, count: 0, player: player}), FactoryGirl.build(:resource, {type: WOOL, count: 0, player: player}), 
        FactoryGirl.build(:resource, {type: BRICK, count: 0, player: player}), FactoryGirl.build(:resource, {type: ORE, count: 0, player: player})]}

      it "returns 0" do
        player.get_resource_count.should eq(0)
      end
    end

    context "when the player has one type of resource" do
      let(:resources) {[FactoryGirl.build(:resource, {type: WOOD, count: 5, player: player}), 
        FactoryGirl.build(:resource, {type: WHEAT, count: 0, player: player}), FactoryGirl.build(:resource, {type: WOOL, count: 0, player: player}), 
        FactoryGirl.build(:resource, {type: BRICK, count: 0, player: player}), FactoryGirl.build(:resource, {type: ORE, count: 0, player: player})]}

      it "returns the resource count" do
        player.get_resource_count.should eq(5)
      end
    end

    context "when the player has multiple resources" do
      let(:resources) {[FactoryGirl.build(:resource, {type: WOOD, count: 1, player: player}), 
        FactoryGirl.build(:resource, {type: WHEAT, count: 2, player: player}), FactoryGirl.build(:resource, {type: WOOL, count: 3, player: player}), 
        FactoryGirl.build(:resource, {type: BRICK, count: 4, player: player}), FactoryGirl.build(:resource, {type: ORE, count: 5, player: player})]}

      it "returns the total number of resources" do
        player.get_resource_count.should eq(15)
      end
    end    
  end

  describe "add_settlement?" do
    let(:game) { FactoryGirl.build_stubbed(:game_turn_1) }
    let(:board) {double("GameBoard")}
    before(:each) { game.stub(:game_board).and_return(board) }
    let(:player) {FactoryGirl.build(:in_game_player, {game: game})}

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

      it "creates a new game_log with the game's turn number and proper text and self as the current_player" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to change(player.game_logs, :count).by(1)

        player.game_logs.last.turn_num.should eq(game.turn_num)
        player.game_logs.last.msg.should eq("#{player.user.displayname} placed a settlement on (1,1,0)")
        player.game_logs.last.current_player.should eq(player)
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
    let(:player) {FactoryGirl.build(:in_game_player, {game: game})}

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

    shared_examples "calls game.advance?" do
      it "calls game.advance?" do
        game.should_receive(:advance?)
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

            it "creates a new game_log with the game's turn number and proper text and self as current_player" do
              expect{
                player.add_road?(x, y, side)
              }.to change(player.game_logs, :count).by(1)

              player.game_logs.last.turn_num.should eq(game.turn_num)
              player.game_logs.last.msg.should eq("#{player.user.displayname} placed a road on (#{x},#{y},#{side})")
              player.game_logs.last.current_player.should eq(player)
            end

            it "creates a new road with for the user at x,y,side" do
              expect{
                player.add_road?(x, y, side)
              }.to change(player.roads, :count).by(1)

              player.roads.last.edge_x.should eq(x)
              player.roads.last.edge_y.should eq(y)
              player.roads.last.side.should eq(side)
            end

            include_examples "calls game.advance?"
          end

          context "when game.advance? returns false" do
            before(:each) {game.stub(:advance?).and_return(false)}

            include_examples "add_road? failures"
            include_examples "calls game.advance?"
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

  describe "roll_dice?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.build(:in_game_player, {game: game})}

    shared_examples "roll_dice? failures" do
      it "returns false" do
        player.roll_dice?.should be_false
      end

      it "does not create a new game log" do
        expect{
          player.roll_dice?
        }.to_not change(player.game_logs, :count)
      end

      it "does not create a dice_roll object" do
        expect{
          player.roll_dice?
        }.to_not change(player.dice_rolls, :count)
      end

      it "does not change the player's turn_status" do
        expect{
          player.roll_dice?
        }.to_not change(player, :turn_status)
      end
    end

    shared_examples "does not call game.process_dice_roll?" do
      it "does not call game.process_dice_roll?" do
        game.should_not_receive(:process_dice_roll?)
        player.roll_dice?
      end
    end

    shared_examples "calls game.process_dice_roll?" do
      it "calls game.process_dice_roll?" do
        game.should_receive(:process_dice_roll?).with(2+rand_1+rand_2)
        player.roll_dice?
      end
    end

    context "when the player's turn_status is not ready to roll" do
      before(:each) {player.turn_status = PLAYING_TURN}

      include_examples "roll_dice? failures"
      include_examples "does not call game.process_dice_roll?"
    end

    context "when the player's turn_status is ready to roll" do
      before(:each) {player.turn_status = READY_TO_ROLL}
      let(:rand_1) {1}
      let(:rand_2) {5}
      before(:each) {player.stub(:rand).and_return(rand_1, rand_2)}

      context "when game.process_dice_roll? returns false" do
        before(:each) {game.stub(:process_dice_roll?).and_return(false)}

        include_examples "roll_dice? failures"
        include_examples "calls game.process_dice_roll?"
      end

      context "when game.process_dice_roll? returns true" do
        before(:each) {game.stub(:process_dice_roll?).and_return(true)}

        it "returns true" do
          player.roll_dice?.should be_true
        end

        it "creates a new game_log with the game's turn number and proper text and self as current_player" do
          expect{
            player.roll_dice?
          }.to change(player.game_logs, :count).by(1)

          player.game_logs.last.turn_num.should eq(game.turn_num)
          player.game_logs.last.msg.should eq("#{player.user.displayname} rolled a (#{2 + rand_1 + rand_2})")
          player.game_logs.last.current_player.should eq(player)
        end

        it "creates a new dice_roll object with the game's turn number and proper numbers" do
          expect{
            player.roll_dice?
          }.to change(player.dice_rolls, :count).by(1)

          player.dice_rolls.last.turn_num.should eq(game.turn_num)
          player.dice_rolls.last.die_1.should eq(rand_1 + 1)
          player.dice_rolls.last.die_2.should eq(rand_2 + 1)
        end
        
        include_examples "calls game.process_dice_roll?"
      end
    end
  end

  describe "collect_resources?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.build(:in_game_player, {game: game})}
    before(:each) {game.stub(:current_player).and_return(player)}

    shared_examples "returns true" do
      it "returns true" do
        player.collect_resources?(resources).should be_true
      end
    end

    context "when resources is empty" do
      let(:resources) {{}}

      include_examples "returns true"

      it "does not create a game log" do
        expect{
          player.collect_resources?(resources)
        }.to_not change(player.game_logs, :count)
      end
    end

    context "when resources is not empty" do
      let(:resources) {{WHEAT => 2}}
      
      include_examples "returns true"

      it "creates a correct game log" do
        expect{
          player.collect_resources?(resources)
        }.to change(player.game_logs, :count).by(1)

        player.game_logs.last.turn_num.should eq(game.turn_num)
        player.game_logs.last.msg.should eq("#{player.user.displayname} got #{resources.first[1]} WHEAT")
        player.game_logs.last.current_player.should eq(player)
      end

      it "adds the proper amounts to the resource totals" do
        original_resource_count = player.resources.find{|r| r.type == resources.first[0]}.count
        player.collect_resources?(resources)
        player.resources.find{|r| r.type == resources.first[0]}.count.should eq(original_resource_count + resources.first[1])
      end

      context "when another player's turn causes the player to get the resources" do
        let(:other_player) {FactoryGirl.build(:in_game_player)}
        before(:each) {game.stub(:current_player).and_return(other_player)}

        it "sets the game_log's current_player to the other player" do
          player.collect_resources?(resources)
          player.game_logs.last.current_player.should eq(other_player)
        end
      end

      context "when there is more than one reosurce type being gained" do
        let(:resources) {{WHEAT => 2, ORE => 3}}

        it "creates a correct game log" do
          expect{
            player.collect_resources?(resources)
          }.to change(player.game_logs, :count).by(1)

          player.game_logs.last.turn_num.should eq(game.turn_num)
          expected_msg = "#{player.user.displayname} got #{resources.first[1]} WHEAT and "
          expected_msg << "#{resources.entries.last[1]} ORE"
          player.game_logs.last.msg.should eq(expected_msg)
          player.game_logs.last.current_player.should eq(player)
        end

        it "adds the proper amounts to the resource totals" do
          original_resource_count1 = player.resources.find{|r| r.type == resources.first[0]}.count
          original_resource_count2 = player.resources.find{|r| r.type == resources.entries.last[0]}.count
          player.collect_resources?(resources)
          player.resources.find{|r| r.type == resources.first[0]}.count.should eq(original_resource_count1 + resources.first[1])
          player.resources.find{|r| r.type == resources.entries.last[0]}.count.should eq(original_resource_count2 + resources.entries.last[1])
        end
      end
    end
  end

  describe "discard_half_resources?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.create(:player_with_items, {game: game, 
      resources: original_resources})}
    before(:each) {game.stub(:current_player).and_return(player)}
    let(:original_resources) {{WHEAT => 6, WOOD => 1, WOOL => 2, ORE => 3, BRICK => 0}}

    shared_examples "discard_half_resources failures" do
      it "returns false" do
        player.discard_half_resources?(resources_to_discard).should be_false
      end

      it "does not add a new game_log" do
        expect{
          player.discard_half_resources?(resources_to_discard)
        }.to_not change(player.game_logs, :count)
      end

      it "does not change the player's status" do
        expect{
          player.discard_half_resources?(resources_to_discard)
        }.to_not change(player, :turn_status)
      end

      it "does not change the count of resources" do
        original_count = player.get_resource_count
        player.discard_half_resources?(resources_to_discard)
        player.reload
        player.get_resource_count.should eq(original_count)
      end
    end

    shared_examples "does not call game.player_finished_discarding?" do
      it "does not call game.player_finished_discarding?" do
        game.should_not_receive(:player_finished_discarding?)
        player.discard_half_resources?(resources_to_discard)
      end
    end

    context "when turn status is not DISCARDING_CARDS_DUE_TO_ROBBER" do
      before(:each) {player.turn_status = PLAYING_TURN}
      let(:resources_to_discard) {{WHEAT => 4, WOOD => 1, WOOL => 1, ORE => 0, BRICK => 0}}

      include_examples "discard_half_resources failures"
      include_examples "does not call game.player_finished_discarding?"
    end

    context "when turn_status is DISCARDING_CARDS_DUE_TO_ROBBER" do
      before(:each) {player.turn_status = DISCARDING_CARDS_DUE_TO_ROBBER}

      context "when the total number of resources to discard is less than half of the current total" do
        let(:resources_to_discard) {{WHEAT => 3, WOOD => 1, WOOL => 1, ORE => 0, BRICK => 0}}

        include_examples "discard_half_resources failures"
        include_examples "does not call game.player_finished_discarding?"
      end

      context "when the total number of resources to discard is greater than half of the current total" do
        let(:resources_to_discard) {{WHEAT => 3, WOOD => 1, WOOL => 2, ORE => 1, BRICK => 0}}

        include_examples "discard_half_resources failures"
        include_examples "does not call game.player_finished_discarding?"

        context "when player has an odd number of resources and we should round down when dividing by 2" do
          let(:original_resources) {{WHEAT => 6, WOOD => 1, WOOL => 2, ORE => 3, BRICK => 1}}

          include_examples "discard_half_resources failures"
          include_examples "does not call game.player_finished_discarding?"
        end
      end

      context "when the total number of resources to discard is equal to half of the current total" do
        let(:resources_to_discard) {{WHEAT => 6, WOOD => 0, WOOL => 0, ORE => 0, BRICK => 0}}

        context "when game.player_finished_discarding? returns false" do
          before(:each) {game.stub(:player_finished_discarding?).and_return(false)}

          include_examples "discard_half_resources failures"
        end

        context "when game.player_finished_discarding? returns true" do
          before(:each) {game.stub(:player_finished_discarding?).and_return(true)}

          it "returns true" do
            player.discard_half_resources?(resources_to_discard).should be_true
          end

          it "discards the proper amounts of resources" do
            player.discard_half_resources?(resources_to_discard)

            original_resources.each do |type, amount|
              player.resources.find{|r| r.type == type}.count.should eq(amount - resources_to_discard[type])
            end
          end

          it "creates a new game_log with the game's turn number and proper text and correct current_player" do
            expect{
              player.discard_half_resources?(resources_to_discard)
            }.to change(player.game_logs, :count).by(1)

            player.game_logs.last.turn_num.should eq(game.turn_num)
            player.game_logs.last.msg.should eq("#{player.user.displayname} discarded 6 WHEAT")
            player.game_logs.last.current_player.should eq(player)
          end

          context "when it's another player's turn" do
            let(:other_player) {FactoryGirl.build(:in_game_player)}
            before(:each) {game.stub(:current_player).and_return(other_player)}

            it "sets the game_log's current_player to the other player" do
              player.discard_half_resources?(resources_to_discard)
              player.game_logs.last.current_player.should eq(other_player)
            end
          end

          context "when there is more than one resource being discarded" do
            let(:resources_to_discard) {{WHEAT => 4, WOOD => 1, WOOL => 1, ORE => 0, BRICK => 0}}

            it "properly formats the game_log msg" do
              player.discard_half_resources?(resources_to_discard)
              player.game_logs.last.msg.should eq("#{player.user.displayname} discarded 4 WHEAT and 1 WOOD and 1 WOOL")
            end

            context "when the first resource in the hash is not discarded" do
              let(:resources_to_discard) {{WHEAT => 0, WOOD => 1, WOOL => 2, ORE => 3, BRICK => 0}}

              it "does not say \"and\" before the first resource in the message" do
                player.discard_half_resources?(resources_to_discard)
                player.game_logs.last.msg.should eq("#{player.user.displayname} discarded 1 WOOD and 2 WOOL and 3 ORE")
              end
            end
          end
        end
      end
    end
  end
end
