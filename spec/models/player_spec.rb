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
    before(:each){allow(player).to receive(:resources).and_return(resources)}

    context "when the player has no resources" do
      let(:resources) {[FactoryGirl.build(:resource, {type: WOOD, count: 0, player: player}), 
        FactoryGirl.build(:resource, {type: WHEAT, count: 0, player: player}), FactoryGirl.build(:resource, {type: WOOL, count: 0, player: player}), 
        FactoryGirl.build(:resource, {type: BRICK, count: 0, player: player}), FactoryGirl.build(:resource, {type: ORE, count: 0, player: player})]}

      it "returns 0" do
        expect(player.get_resource_count).to eq(0)
      end
    end

    context "when the player has one type of resource" do
      let(:resources) {[FactoryGirl.build(:resource, {type: WOOD, count: 5, player: player}), 
        FactoryGirl.build(:resource, {type: WHEAT, count: 0, player: player}), FactoryGirl.build(:resource, {type: WOOL, count: 0, player: player}), 
        FactoryGirl.build(:resource, {type: BRICK, count: 0, player: player}), FactoryGirl.build(:resource, {type: ORE, count: 0, player: player})]}

      it "returns the resource count" do
        expect(player.get_resource_count).to eq(5)
      end
    end

    context "when the player has multiple resources" do
      let(:resources) {[FactoryGirl.build(:resource, {type: WOOD, count: 1, player: player}), 
        FactoryGirl.build(:resource, {type: WHEAT, count: 2, player: player}), FactoryGirl.build(:resource, {type: WOOL, count: 3, player: player}), 
        FactoryGirl.build(:resource, {type: BRICK, count: 4, player: player}), FactoryGirl.build(:resource, {type: ORE, count: 5, player: player})]}

      it "returns the total number of resources" do
        expect(player.get_resource_count).to eq(15)
      end
    end    
  end

  describe "add_settlement?" do
    let(:game) { FactoryGirl.build_stubbed(:game_turn_1) }
    let(:board) {double("GameBoard")}
    let(:player) {FactoryGirl.build(:player_with_items, {game: game, turn_status: turn_status, resources: starting_resources})}
    let(:starting_resources) {Hash.new}
    before(:each) do
      allow(game).to receive(:game_board).and_return(board)
      allow(game).to receive(:current_player).and_return(player)
    end

    shared_examples "add_settlement? failures" do
      it "returns false" do
        expect(player.add_settlement?(1, 1, 0)).to be_falsey
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

      include_examples "add_settlement? does not change the player's resources"
      include_examples "does not change the player's status"
    end

    shared_examples "does not change the player's status" do
      it "does not change the player's turn_status" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to_not change(player, :turn_status)
      end
    end

    shared_examples "add_settlement? does not change the player's resources" do
      it "does not change the player's resources" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to_not change(player, :resources)
      end
    end

    shared_examples "add_settlement? successes" do
      it "returns true" do
        expect(player.add_settlement?(1, 1, 0)).to be true
      end

      it "creates a new settlement for the user at x,y,side" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to change(player.settlements, :count).by(1)

        expect(player.settlements.last.vertex_x).to eq(1)
        expect(player.settlements.last.vertex_y).to eq(1)
        expect(player.settlements.last.side).to eq(0)
      end

      it "saves" do
        expect(player).to receive(:save).and_call_original
        player.add_settlement?(1,1,0)
      end
    end

    shared_examples "add_settlement? sets status to PLACING_INITIAL_ROAD" do
      it "sets the player's turn_status to PLACING_INITIAL_ROAD" do
        player.add_settlement?(1, 1, 0)
        expect(player.turn_status).to eq(PLACING_INITIAL_ROAD)
      end
    end

    shared_examples "PLACING_INITIAL_ROAD game_log" do
      it "creates a new game_log with the game's turn number and proper text and self as the current_player" do
        expect{
          player.add_settlement?(1, 1, 0)
        }.to change(player.game_logs, :count).by(1)

        expect(player.game_logs.last.turn_num).to eq(game.turn_num)
        expect(player.game_logs.last.msg).to eq("#{player.user.displayname} placed a settlement on (1,1,0)")
        expect(player.game_logs.last.current_player).to eq(player)
        expect(player.game_logs.last.is_private).to be_falsey
      end
    end

    context "when x,y is not free for building" do
      let(:turn_status) {PLACING_INITIAL_SETTLEMENT}
      before(:each) {allow(board).to receive(:vertex_is_free_for_building?).and_return(false)}

      include_examples "add_settlement? failures"
    end

    context "when x,y is free for building" do
      before(:each) {allow(board).to receive(:vertex_is_free_for_building?).and_return(true)}

      context "when player is status PLACING_INITIAL_SETTLEMENT" do
        let(:turn_status) {PLACING_INITIAL_SETTLEMENT}
        before(:each) do
          hexes = [Hex.new(resource_type: WOOD), Hex.new(resource_type: WOOL), Hex.new(resource_type: WOOD)]
          allow(board).to receive(:get_hexes_from_vertex).and_return(hexes)
        end

        context "when turn number is 1" do
          before(:each) {player.game.turn_num = 1}

          include_examples "add_settlement? successes"
          include_examples "add_settlement? sets status to PLACING_INITIAL_ROAD"
          include_examples "PLACING_INITIAL_ROAD game_log"
          include_examples "add_settlement? does not change the player's resources"
        end

        context "when turn number is 2" do
          before(:each) {player.game.turn_num = 2}
          
          include_examples "add_settlement? successes"
          include_examples "add_settlement? sets status to PLACING_INITIAL_ROAD"
          include_examples "PLACING_INITIAL_ROAD game_log"

          it "sets the player's resource counts properly" do
            player.add_settlement?(1, 1, 0)
            expect(player.resources.find{|resource| resource.type == WOOD}.count).to eq(2)
            expect(player.resources.find{|resource| resource.type == WOOL}.count).to eq(1)
            expect(player.resources.find{|resource| resource.type == ORE}.count).to eq(0)
            expect(player.resources.find{|resource| resource.type == BRICK}.count).to eq(0)
            expect(player.resources.find{|resource| resource.type == WHEAT}.count).to eq(0)
          end
        end        
      end

      context "when player is status PLAYING_TURN" do
        let(:turn_status) {PLAYING_TURN}

        it "calls game_board.vertex_is_connected_to_player? with proper arguments" do
          expect(board).to receive(:vertex_is_connected_to_player?).with(1,1,0,player).and_return(false)
          player.add_settlement?(1,1,0)
        end

        context "when the player isn't connected by road to the vertex" do
          let(:starting_resources) {{WHEAT => 1, WOOD => 2, WOOL => 1, BRICK => 4, ORE => 1}}
          before(:each) {allow(board).to receive(:vertex_is_connected_to_player?).and_return(false)}

          include_examples "add_settlement? failures"
        end

        context "when the player is connected by road to the vertex" do
          before(:each) {allow(board).to receive(:vertex_is_connected_to_player?).and_return(true)}

          context "when the player doesn't have a WHEAT" do
            let(:starting_resources) {{WOOD => 2, WOOL => 1, BRICK => 1}}

            include_examples "add_settlement? failures"
          end

          context "when the player doesn't have a WOOD" do
            let(:starting_resources) {{WHEAT => 2, WOOL => 1, BRICK => 1}}

            include_examples "add_settlement? failures"
          end

          context "when the player doesn't have a WOOL" do
            let(:starting_resources) {{WOOD => 2, WHEAT => 1, BRICK => 1}}

            include_examples "add_settlement? failures"
          end

          context "when the player doesn't have a BRICK" do
            let(:starting_resources) {{WOOD => 2, WOOL => 1, WHEAT => 1}}

            include_examples "add_settlement? failures"
          end

          context "when the player has enough resources" do
            let(:starting_resources) {{WHEAT => 1, WOOD => 2, WOOL => 1, BRICK => 4, ORE => 1}}

            include_examples "add_settlement? successes"
            include_examples "does not change the player's status"

            it "creates a new game_log with the game's turn number and proper text and self as the current_player" do
              expect{
                player.add_settlement?(1, 1, 0)
              }.to change(player.game_logs, :count).by(1)

              expect(player.game_logs.last.turn_num).to eq(game.turn_num)
              expect(player.game_logs.last.msg).to eq("#{player.user.displayname} bought a settlement on (1,1,0)")
              expect(player.game_logs.last.current_player).to eq(player)
              expect(player.game_logs.last.is_private).to be_falsey
            end

            it "sets the player's resource counts properly" do
              player.add_settlement?(1, 1, 0)
              expect(player.resources.find{|resource| resource.type == WOOD}.count).to eq(1)
              expect(player.resources.find{|resource| resource.type == WOOL}.count).to eq(0)
              expect(player.resources.find{|resource| resource.type == ORE}.count).to eq(1)
              expect(player.resources.find{|resource| resource.type == BRICK}.count).to eq(3)
              expect(player.resources.find{|resource| resource.type == WHEAT}.count).to eq(0)
            end
          end
        end
      end
      
      context "when player is not status PLACING_INITIAL_SETTLEMENT or PLAYING_TURN" do
        let(:turn_status) {WAITING_FOR_TURN}
        let(:starting_resources) {{WHEAT => 1, WOOD => 2, WOOL => 1, WHEAT => 4}}

        include_examples "add_settlement? failures"
      end
    end
  end

  describe "add_road?" do
    let(:game) { FactoryGirl.build_stubbed(:game_turn_1) }
    let(:board) {double("GameBoard")}
    let(:player) {FactoryGirl.build(:in_game_player, {game: game, turn_status: turn_status})}
    before(:each) do
      allow(game).to receive(:game_board).and_return(board)
      allow(game).to receive(:current_player).and_return(player)
    end

    shared_examples "add_road? failures" do
      it "returns false" do
        expect(player.add_road?(x, y, side)).to be_falsey
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
        expect(game).to_not receive(:advance?)
        player.add_road?(x, y, side)
      end
    end

    shared_examples "calls game.advance?" do
      it "calls game.advance?" do
        expect(game).to receive(:advance?)
        player.add_road?(x, y, side)
      end
    end    

    context "when x,y is not free for building" do
      let(:x) {-10}
      let(:y) {-10}
      let(:side) {0}
      let(:turn_status) {PLACING_INITIAL_ROAD}
      before(:each) {expect(board).to receive(:edge_is_free_for_building_by_player?).with(x, y, side, player).and_return(false)}

      include_examples "add_road? failures"
      include_examples "does not call game.advance?"
    end

    context "when x,y is free for building" do
      let(:x) {2}
      let(:y) {2}
      let(:side) {0}
      before(:each) {expect(board).to receive(:edge_is_free_for_building_by_player?).with(x, y, side, player).and_return(true)}
      
      context "when player is status PLACING_INITIAL_ROAD" do
        let(:turn_status) {PLACING_INITIAL_ROAD}

        context "when the edge is not touching the last settlement the player built" do
          context "when the player has only 1 settlement" do
            before(:each) do
              player.settlements.build(:vertex_x => 0, :vertex_y => 2, :side => 0)
              expect(board).to receive(:edge_is_connected_to_vertex?).with(x, y, side, 0, 2, 0).and_return(false)
            end
            include_examples "add_road? failures"
            include_examples "does not call game.advance?"
          end

          context "when the player has 2 settlements" do
            before(:each) do
              player.settlements.build(:vertex_x => 2, :vertex_y => 2, :side => 0)
              player.settlements.build(:vertex_x => 0, :vertex_y => 2, :side => 0)
              expect(board).to receive(:edge_is_connected_to_vertex?).with(x, y, side, 0, 2, 0).and_return(false)
            end

            include_examples "add_road? failures"
            include_examples "does not call game.advance?"
          end
        end

        context "when the edge is touching the last settlement the player built" do
          before(:each) do
            player.settlements.build(:vertex_x => 2, :vertex_y => 2, :side => 0)
            expect(board).to receive(:edge_is_connected_to_vertex?).with(x, y, side, 2, 2, 0).and_return(true)
          end

          context "when game.advance? returns true" do
            before(:each) {allow(game).to receive(:advance?).and_return(true)}

            it "returns true" do
              expect(player.add_road?(x, y, side)).to be true
            end

            it "creates a new game_log with the game's turn number and proper text and self as current_player" do
              expect{
                player.add_road?(x, y, side)
              }.to change(player.game_logs, :count).by(1)

              expect(player.game_logs.last.turn_num).to eq(game.turn_num)
              expect(player.game_logs.last.msg).to eq("#{player.user.displayname} placed a road on (#{x},#{y},#{side})")
              expect(player.game_logs.last.current_player).to eq(player)
              expect(player.game_logs.last.is_private).to be_falsey
            end

            it "creates a new road with for the user at x,y,side" do
              expect{
                player.add_road?(x, y, side)
              }.to change(player.roads, :count).by(1)

              expect(player.roads.last.edge_x).to eq(x)
              expect(player.roads.last.edge_y).to eq(y)
              expect(player.roads.last.side).to eq(side)
            end

            it "saves" do
              expect(player).to receive(:save).and_call_original
              player.add_road?(x, y, side)
            end

            include_examples "calls game.advance?"
          end

          context "when game.advance? returns false" do
            before(:each) {allow(game).to receive(:advance?).and_return(false)}

            include_examples "add_road? failures"
            include_examples "calls game.advance?"
          end
        end
      end

      #TODO: add in when player is playing turn
      
      context "when player is not status PLACING_INITIAL_ROAD" do
        let(:turn_status) {WAITING_FOR_TURN}

        include_examples "add_road? failures"
        include_examples "does not call game.advance?"
      end
    end
  end

  describe "roll_dice?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.build(:in_game_player, {game: game, turn_status: turn_status})}
    before(:each) {allow(game).to receive(:current_player).and_return(player)}

    shared_examples "roll_dice? failures" do
      it "returns false" do
        expect(player.roll_dice?).to be_falsey
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
        expect(game).to_not receive(:process_dice_roll?)
        player.roll_dice?
      end
    end

    shared_examples "calls game.process_dice_roll?" do
      it "calls game.process_dice_roll?" do
        expect(game).to receive(:process_dice_roll?).with(2+rand_1+rand_2)
        player.roll_dice?
      end
    end

    context "when the player's turn_status is not ready to roll" do
      let(:turn_status) {PLAYING_TURN}

      include_examples "roll_dice? failures"
      include_examples "does not call game.process_dice_roll?"
    end

    context "when the player's turn_status is ready to roll" do
      let(:turn_status) {READY_TO_ROLL}
      let(:rand_1) {1}
      let(:rand_2) {5}
      before(:each) {allow(player).to receive(:rand).and_return(rand_1, rand_2)}

      context "when game.process_dice_roll? returns false" do
        before(:each) {allow(game).to receive(:process_dice_roll?).and_return(false)}

        include_examples "roll_dice? failures"
        include_examples "calls game.process_dice_roll?"
      end

      context "when game.process_dice_roll? returns true" do
        before(:each) {allow(game).to receive(:process_dice_roll?).and_return(true)}

        it "returns true" do
          expect(player.roll_dice?).to be true
        end

        it "creates a new game_log with the game's turn number and proper text and self as current_player" do
          expect{
            player.roll_dice?
          }.to change(player.game_logs, :count).by(1)

          expect(player.game_logs.last.turn_num).to eq(game.turn_num)
          expect(player.game_logs.last.msg).to eq("#{player.user.displayname} rolled a (#{2 + rand_1 + rand_2})")
          expect(player.game_logs.last.current_player).to eq(player)
          expect(player.game_logs.last.is_private).to be_falsey
        end

        it "creates a new dice_roll object with the game's turn number and proper numbers" do
          expect{
            player.roll_dice?
          }.to change(player.dice_rolls, :count).by(1)

          expect(player.dice_rolls.last.turn_num).to eq(game.turn_num)
          expect(player.dice_rolls.last.die_1).to eq(rand_1 + 1)
          expect(player.dice_rolls.last.die_2).to eq(rand_2 + 1)
        end

        it "saves" do
          expect(player).to receive(:save).and_call_original
          player.roll_dice?
        end

        include_examples "calls game.process_dice_roll?"
      end
    end
  end

  describe "collect_resources?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.build(:in_game_player, {game: game})}
    before(:each) {allow(game).to receive(:current_player).and_return(player)}

    shared_examples "returns true" do
      it "returns true" do
        expect(player.collect_resources?(resources)).to be true
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

        expect(player.game_logs.last.turn_num).to eq(game.turn_num)
        expect(player.game_logs.last.msg).to eq("#{player.user.displayname} got #{resources.first[1]} WHEAT")
        expect(player.game_logs.last.current_player).to eq(player)
        expect(player.game_logs.last.is_private).to be_falsey
      end

      it "adds the proper amounts to the resource totals" do
        original_resource_count = player.resources.find{|r| r.type == resources.first[0]}.count
        player.collect_resources?(resources)
        expect(player.resources.find{|r| r.type == resources.first[0]}.count).to eq(original_resource_count + resources.first[1])
      end

      context "when another player's turn causes the player to get the resources" do
        let(:other_player) {FactoryGirl.build(:in_game_player)}
        before(:each) {allow(game).to receive(:current_player).and_return(other_player)}

        it "sets the game_log's current_player to the other player" do
          player.collect_resources?(resources)
          expect(player.game_logs.last.current_player).to eq(other_player)
        end
      end

      context "when there is more than one reosurce type being gained" do
        let(:resources) {{WHEAT => 2, ORE => 3}}

        it "creates a correct game log" do
          expect{
            player.collect_resources?(resources)
          }.to change(player.game_logs, :count).by(1)

          expect(player.game_logs.last.turn_num).to eq(game.turn_num)
          expected_msg = "#{player.user.displayname} got #{resources.first[1]} WHEAT and "
          expected_msg << "#{resources.entries.last[1]} ORE"
          expect(player.game_logs.last.msg).to eq(expected_msg)
          expect(player.game_logs.last.current_player).to eq(player)
          expect(player.game_logs.last.is_private).to be_falsey
        end

        it "adds the proper amounts to the resource totals" do
          original_resource_count1 = player.resources.find{|r| r.type == resources.first[0]}.count
          original_resource_count2 = player.resources.find{|r| r.type == resources.entries.last[0]}.count
          player.collect_resources?(resources)
          expect(player.resources.find{|r| r.type == resources.first[0]}.count).to eq(original_resource_count1 + resources.first[1])
          expect(player.resources.find{|r| r.type == resources.entries.last[0]}.count).to eq(original_resource_count2 + resources.entries.last[1])
        end

        it "saves" do
          expect(player).to receive(:save).and_call_original
          player.collect_resources?(resources)
        end
      end
    end
  end

  describe "discard_half_resources?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.create(:player_with_items, {game: game, turn_status: turn_status,
      resources: original_resources})}
    before(:each) {allow(game).to receive(:current_player).and_return(player)}
    let(:original_resources) {{WHEAT => 6, WOOD => 1, WOOL => 2, ORE => 3, BRICK => 0}}

    shared_examples "discard_half_resources failures" do
      it "returns false" do
        expect(player.discard_half_resources?(resources_to_discard)).to be_falsey
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
        expect(player.get_resource_count).to eq(original_count)
      end
    end

    shared_examples "does not call game.player_finished_discarding?" do
      it "does not call game.player_finished_discarding?" do
        expect(game).to_not receive(:player_finished_discarding?)
        player.discard_half_resources?(resources_to_discard)
      end
    end

    context "when turn status is not DISCARDING_CARDS_DUE_TO_ROBBER" do
      let(:turn_status) {PLAYING_TURN}
      let(:resources_to_discard) {{WHEAT => 4, WOOD => 1, WOOL => 1, ORE => 0, BRICK => 0}}

      include_examples "discard_half_resources failures"
      include_examples "does not call game.player_finished_discarding?"
    end

    context "when turn_status is DISCARDING_CARDS_DUE_TO_ROBBER" do
      let(:turn_status) {DISCARDING_CARDS_DUE_TO_ROBBER}

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
          before(:each) {allow(game).to receive(:player_finished_discarding?).and_return(false)}

          include_examples "discard_half_resources failures"
        end

        context "when game.player_finished_discarding? returns true" do
          before(:each) {allow(game).to receive(:player_finished_discarding?).and_return(true)}

          it "returns true" do
            expect(player.discard_half_resources?(resources_to_discard)).to be true
          end

          it "discards the proper amounts of resources" do
            player.discard_half_resources?(resources_to_discard)

            original_resources.each do |type, amount|
              expect(player.resources.find{|r| r.type == type}.count).to eq(amount - resources_to_discard[type])
            end
          end

          it "creates a new game_log with the game's turn number and proper text and correct current_player" do
            expect{
              player.discard_half_resources?(resources_to_discard)
            }.to change(player.game_logs, :count).by(1)

            expect(player.game_logs.last.turn_num).to eq(game.turn_num)
            expect(player.game_logs.last.msg).to eq("#{player.user.displayname} discarded 6 WHEAT")
            expect(player.game_logs.last.current_player).to eq(player)
            expect(player.game_logs.last.is_private).to be_falsey
          end

          it "saves" do
            expect(player).to receive(:save).and_call_original
            player.discard_half_resources?(resources_to_discard)
          end

          context "when it's another player's turn" do
            let(:other_player) {FactoryGirl.build(:in_game_player)}
            before(:each) {allow(game).to receive(:current_player).and_return(other_player)}

            it "sets the game_log's current_player to the other player" do
              player.discard_half_resources?(resources_to_discard)
              expect(player.game_logs.last.current_player).to eq(other_player)
            end
          end

          context "when there is more than one resource being discarded" do
            let(:resources_to_discard) {{WHEAT => 4, WOOD => 1, WOOL => 1, ORE => 0, BRICK => 0}}

            it "properly formats the game_log msg" do
              player.discard_half_resources?(resources_to_discard)
              expect(player.game_logs.last.msg).to eq("#{player.user.displayname} discarded 4 WHEAT and 1 WOOD and 1 WOOL")
            end

            context "when the first resource in the hash is not discarded" do
              let(:resources_to_discard) {{WHEAT => 0, WOOD => 1, WOOL => 2, ORE => 3, BRICK => 0}}

              it "does not say \"and\" before the first resource in the message" do
                player.discard_half_resources?(resources_to_discard)
                expect(player.game_logs.last.msg).to eq("#{player.user.displayname} discarded 1 WOOD and 2 WOOL and 3 ORE")
              end
            end
          end
        end
      end
    end
  end

  describe "move_robber?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.create(:in_game_player, {game: game, turn_status: turn_status})}
    let(:board) {double("GameBoard")}
    let(:x) {2}
    let(:y) {2}
    before(:each) do
      allow(game).to receive(:game_board).and_return(board)
      allow(game).to receive(:current_player).and_return(player)
    end

    shared_examples "move_robber? failures" do
      it "returns false" do
        expect(player.move_robber?(x, y)).to be_falsey
      end

      it "does not create a new game log" do
        expect{
          player.move_robber?(x, y)
        }.to_not change(player.game_logs, :count)
      end

      it "leaves the status as whatver it was before" do
        original_status = player.turn_status
        player.move_robber?(x,y)
        player.reload
        expect(player.turn_status).to eq(original_status)
      end
    end

    shared_examples "calls game.move_robber?" do
      it "calls game.move_robber?" do
        player.move_robber?(x, y)
        expect(game).to have_received(:move_robber?).once.with(x,y)
      end
    end

    let(:num_new_game_logs) {1}
    shared_examples "move_robber? successes" do
      it "returns true" do
        expect(player.move_robber?(x, y)).to be_truthy
      end

      it "saves" do
        expect(player).to receive(:save).and_call_original
        player.move_robber?(x, y)
      end

      it "properly updates the player's turn status" do
        expect{
          player.move_robber?(x, y)
        }.to change(player, :turn_status).to(new_status)
      end

      it "creates a game_log with the proper message and format to say the robber was moved" do
        player.move_robber?(x, y)

        expect(player.game_logs[-1*num_new_game_logs].turn_num).to eq(game.turn_num)
        expect(player.game_logs[-1*num_new_game_logs].current_player).to eq(game.current_player)
        expect(player.game_logs[-1*num_new_game_logs].msg).to eq("#{player.user.displayname} moved the robber")
        expect(player.game_logs[-1*num_new_game_logs].is_private).to be_falsey
      end

      it "creates the right number of new game_logs" do
        expect{
          player.move_robber?(x, y)
        }.to change(player.game_logs, :count).by(num_new_game_logs)
      end

      include_examples "calls game.move_robber?"
    end

    shared_examples "creates a game_log to say player stole n resources" do
      it "creates a game_log with the proper message and format to say player stole n resources" do
        player.move_robber?(x, y)
        
        expect(player.game_logs[1-num_new_game_logs].turn_num).to eq(game.turn_num)
        expect(player.game_logs[1-num_new_game_logs].current_player).to eq(game.current_player)
        expect(player.game_logs[1-num_new_game_logs].msg).to eq("#{player.user.displayname} stole #{stolen_resources.count} resources from #{other_player.user.displayname}")
        expect(player.game_logs[1-num_new_game_logs].is_private).to be_falsey
      end
    end

    context "when player's turn status is not MOVING_ROBBER" do
      let(:turn_status) {PLAYING_TURN}

      include_examples "move_robber? failures"
    end

    context "when player's turn status is MOVING_ROBBER" do
      let(:turn_status) {MOVING_ROBBER}

      context "when game.move_robber? returns false" do
        before(:each) do
          allow(board).to receive(:get_settlements_touching_hex).and_return([])
          allow(game).to receive(:move_robber?).and_return(false)
        end

        include_examples "calls game.move_robber?"
        include_examples "move_robber? failures"
      end

      context "when game.move_robber? returns true" do
        before(:each) {allow(game).to receive(:move_robber?).and_return(true)}

        context "when the hex is touching no settlements" do
          let(:new_status) {PLAYING_TURN}
          before(:each) {allow(board).to receive(:get_settlements_touching_hex).and_return([])}

          include_examples "move_robber? successes"
        end

        context "when the hex is only touching the current player's settlements" do
          let(:new_status) {PLAYING_TURN}
          before(:each) {allow(board).to receive(:get_settlements_touching_hex).and_return([FactoryGirl.build(:settlement, {player: player})])}

          include_examples "move_robber? successes"
        end

        context "when the hex is touching only one other player's settlements" do
          let(:new_status) {PLAYING_TURN}
          let(:other_player) {FactoryGirl.build_stubbed(:in_game_player, {game: game})}
          before(:each) {allow(board).to receive(:get_settlements_touching_hex).and_return([FactoryGirl.build(:settlement, {player: other_player})])}

          it "calls other_player.resources_stolen" do
            expect(other_player).to receive(:resources_stolen).once.with(1).and_return({})
            player.move_robber?(x,y)
          end

          context "when other_player.resources_stolen raises an exception that is not a resources_stolen_error RuntimeError" do
            before(:each) {allow(other_player).to receive(:resources_stolen).and_raise("test123")}

            it "allows that exception to be re-raised" do
              expect{
                player.move_robber?(x,y)
              }.to raise_error("test123")
            end
          end

          context "when other_player.resources_stolen raises a resources_stolen_error RuntimeError" do
            before(:each) {allow(other_player).to receive(:resources_stolen).and_raise("resources_stolen_error")}

            include_examples "move_robber? failures"
          end

          context "when other_player.resources_stolen returns an empty list" do
            let(:num_new_game_logs) {2}
            let(:stolen_resources) {{}}
            before(:each) {allow(other_player).to receive(:resources_stolen).and_return(stolen_resources)}

            include_examples "move_robber? successes"
            include_examples "creates a game_log to say player stole n resources"
          end

          context "when other_player.resources_stolen returns a list with a resource" do
            let(:num_new_game_logs) {3}
            let(:stolen_resources) {{WHEAT => 1}}
            before(:each) {allow(other_player).to receive(:resources_stolen).and_return(stolen_resources)}

            include_examples "move_robber? successes"
            include_examples "creates a game_log to say player stole n resources"

            it "creates a private game_log to tell the player what he or she stole" do
              player.move_robber?(x, y)
              
              expect(player.game_logs[-1].turn_num).to eq(game.turn_num)
              expect(player.game_logs[-1].current_player).to eq(game.current_player)
              expect(player.game_logs[-1].msg).to eq("You stole 1 WHEAT from #{other_player.user.displayname}")
              expect(player.game_logs[-1].is_private).to be_truthy
            end
          end
        end

        context "when the hex is touching multiple other players' settlements" do
          let(:new_status) {CHOOSING_ROBBER_VICTIM}
          let(:other_player1) {FactoryGirl.build_stubbed(:in_game_player)}
          let(:other_player2) {FactoryGirl.build_stubbed(:in_game_player)}
          before(:each) {allow(board).to receive(:get_settlements_touching_hex).and_return([FactoryGirl.build(:settlement, {player: other_player1}), 
            FactoryGirl.build(:settlement, {player: other_player2})])}

          include_examples "move_robber? successes"
        end
      end
    end
  end

  describe "resources_stolen" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.build(:player_with_items, {game: game, resources: initial_resources})}
    let(:other_player) {FactoryGirl.build(:in_game_player, {game: game})}
    before(:each) {allow(game).to receive(:current_player).and_return(other_player)}

    shared_examples "loses nothing" do
      it "returns an empty hash" do
        expect(player.resources_stolen(num)).to eq({})
      end

      it "does not change the number of game_logs" do
        expect{
          player.resources_stolen(num)
        }.to_not change(player.game_logs, :count)
      end

      it "does not change the number of resources the player has" do
        original_resource_count = player.get_resource_count
        player.resources_stolen(num)
        expect(player.get_resource_count).to eq(original_resource_count)
      end

      it "doesn't call save" do
        expect(player).to_not receive(:save)
        player.resources_stolen(num)
      end
    end

    shared_examples "lowers the resource count by the proper amount" do
      it "lowers the resource count by the proper amount" do
        player.resources_stolen(num)

        initial_resources.each do |type, amount|
          expect(player.resources.find{|r| r.type == type}.count).to eq(amount - sample_results.select{|x| x == type}.count)
        end
      end
    end

    context "when num == 0" do
      let(:num) {0}
      let(:initial_resources) {{WHEAT => 2}}

      include_examples "loses nothing"
    end

    context "when num is not 0" do
      let(:num) {1}

      context "when the player has no resources" do
        let(:initial_resources) {{}}

        include_examples "loses nothing"
      end

      context "when the player has resources" do
        let(:initial_resources) {{WHEAT => 1, WOOD => 1, WOOL => 2}}
        let(:sample_results) {[WHEAT]}
        before(:each) {allow_any_instance_of(Array).to receive(:sample).and_return(sample_results)}

        it "saves" do
          expect(player).to receive(:save).and_call_original
          player.resources_stolen(num)
        end

        include_examples "lowers the resource count by the proper amount"

        it "creates a properly formatted game_log with the correct message" do
          expect{
            player.resources_stolen(num)
          }.to change(player.game_logs, :count).by(1)

          expect(player.game_logs.last.turn_num).to eq(game.turn_num)
          expect(player.game_logs.last.msg).to eq("1 WHEAT was stolen")
          expect(player.game_logs.last.current_player).to eq(other_player)
          expect(player.game_logs.last.is_private).to be_truthy
        end

        context "when there is more than 1 resource being stolen" do
          let(:num) {2}

          context "when more than 1 of the same resource is stolen" do
            let(:sample_results) {[WOOL, WOOL]}

            include_examples "lowers the resource count by the proper amount"  

            it "formats the game_log msg properly" do
              player.resources_stolen(num)
              expect(player.game_logs.last.msg).to eq("2 WOOL were stolen")
            end
          end

          context "when more than 1 of the same resource is stolen" do
            let(:num) {3}
            let(:sample_results) {[WHEAT, WOOL, WOOD, WOOL]}

            include_examples "lowers the resource count by the proper amount"  

            it "formats the game_log msg properly" do
              player.resources_stolen(num)
              expect(player.game_logs.last.msg).to eq("1 WHEAT and 2 WOOL and 1 WOOD were stolen")
            end
          end
        end
      end
    end
  end

  describe "choose_robber_victim?" do
    let(:game) { FactoryGirl.build_stubbed(:game_started) }
    let(:player) {FactoryGirl.create(:in_game_player, {game: game, turn_status: turn_status})}
    let(:board) {double("GameBoard")}
    before(:each) do
      allow(game).to receive(:game_board).and_return(board)
      allow(game).to receive(:current_player).and_return(player)
    end

    shared_examples "choose_robber_victim? failures" do
      it "returns false" do
        expect(player.choose_robber_victim?(victim)).to be_falsey
      end

      it "does not create a new game log" do
        expect{
          player.choose_robber_victim?(victim)
        }.to_not change(player.game_logs, :count)
      end

      it "leaves the status as whatver it was before" do
        original_status = player.turn_status
        player.choose_robber_victim?(victim)
        player.reload
        expect(player.turn_status).to eq(original_status)
      end
    end

    let(:num_new_game_logs) {1}
    shared_examples "choose_robber_victim? successes" do
      it "returns true" do
        expect(player.choose_robber_victim?(victim)).to be_truthy
      end

      it "saves" do
        expect(player).to receive(:save).and_call_original
        player.choose_robber_victim?(victim)
      end

      it "updates the player's turn status to PLAYING_TURN" do
        expect{
          player.choose_robber_victim?(victim)
        }.to change(player, :turn_status).to(PLAYING_TURN)
      end

      it "creates a game_log with the proper message and format to say player stole n resources" do
        player.choose_robber_victim?(victim)
        
        expect(player.game_logs[-1*num_new_game_logs].turn_num).to eq(game.turn_num)
        expect(player.game_logs[-1*num_new_game_logs].current_player).to eq(game.current_player)
        expect(player.game_logs[-1*num_new_game_logs].msg).to eq("#{player.user.displayname} stole #{stolen_resources.count} resources from #{victim.user.displayname}")
        expect(player.game_logs[-1*num_new_game_logs].is_private).to be_falsey
      end

      it "creates the right number of new game_logs" do
        expect{
          player.choose_robber_victim?(victim)
        }.to change(player.game_logs, :count).by(num_new_game_logs)
      end
    end

    context "when player's turn status is not CHOOSING_ROBBER_VICTIM" do
      let(:turn_status) {PLAYING_TURN}
      let(:victim) {FactoryGirl.build(:in_game_player, {game: game, turn_status: WAITING_FOR_TURN})}

      include_examples "choose_robber_victim? failures"
    end

    context "when player's turn status is CHOOSING_ROBBER_VICTIM" do
      let(:turn_status) {CHOOSING_ROBBER_VICTIM}

      context "when the victim is not part of the game" do
        let(:other_game) {FactoryGirl.build_stubbed(:game_started)}
        let(:victim) {FactoryGirl.build(:in_game_player, {game: other_game, turn_status: WAITING_FOR_TURN})}
        before(:each) { allow(board).to receive(:get_settlements_touching_hex).and_return([FactoryGirl.build(:settlement, {player: victim})]) }

        include_examples "choose_robber_victim? failures"
      end

      context "when the victim is part of the game" do
        context "when the victim is the player" do
          let(:victim) {player}
          before(:each) { allow(board).to receive(:get_settlements_touching_hex).and_return([FactoryGirl.build(:settlement, {player: victim})]) }

          include_examples "choose_robber_victim? failures"
        end

        context "when the victim is not the player" do
          let(:victim) {FactoryGirl.build(:in_game_player, {game: game, turn_status: WAITING_FOR_TURN})}

          it "calls game_board.get_settlements_touching_hex with the robber coordinates" do
            expect(board).to receive(:get_settlements_touching_hex).with(game.robber_x, game.robber_y).and_return([])
            player.choose_robber_victim?(victim)
          end

          context "when there are no settlement's touching the robber hex" do
            before(:each) { allow(board).to receive(:get_settlements_touching_hex).and_return([]) }

            include_examples "choose_robber_victim? failures"
          end

          context "when the victim does not have a settlement on the robber's hex" do
            before(:each) { allow(board).to receive(:get_settlements_touching_hex).and_return([FactoryGirl.build(:settlement, {player: player})]) }

            include_examples "choose_robber_victim? failures"
          end

          context "when the victim has settlements on the robber hex" do
            before(:each) { allow(board).to receive(:get_settlements_touching_hex).and_return([FactoryGirl.build(:settlement, {player: victim})]) }

            it "calls victim.resources_stolen" do
              expect(victim).to receive(:resources_stolen).once.with(1).and_return({})
              player.choose_robber_victim?(victim)
            end

            context "when victim.resources_stolen raises an exception that is not a resources_stolen_error RuntimeError" do
              before(:each) {allow(victim).to receive(:resources_stolen).and_raise("test123")}

              it "allows that exception to be re-raised" do
                expect{
                  player.choose_robber_victim?(victim)
                }.to raise_error("test123")
              end
            end

            context "when victim.resources_stolen raises a resources_stolen_error RuntimeError" do
              before(:each) {allow(victim).to receive(:resources_stolen).and_raise("resources_stolen_error")}

              include_examples "choose_robber_victim? failures"
            end

            context "when victim.resources_stolen returns an empty list" do
              let(:num_new_game_logs) {1}
              let(:stolen_resources) {{}}
              before(:each) {allow(victim).to receive(:resources_stolen).and_return(stolen_resources)}

              include_examples "choose_robber_victim? successes"
            end

            context "when victim.resources_stolen returns a list with a resource" do
              let(:num_new_game_logs) {2}
              let(:stolen_resources) {{WHEAT => 1}}
              before(:each) {allow(victim).to receive(:resources_stolen).and_return(stolen_resources)}

              include_examples "choose_robber_victim? successes"

              it "creates a private game_log to tell the player what he or she stole" do
                player.choose_robber_victim?(victim)
                
                expect(player.game_logs[-1].turn_num).to eq(game.turn_num)
                expect(player.game_logs[-1].current_player).to eq(game.current_player)
                expect(player.game_logs[-1].msg).to eq("You stole 1 WHEAT from #{victim.user.displayname}")
                expect(player.game_logs[-1].is_private).to be_truthy
              end
            end
          end
        end
      end
    end
  end
end
