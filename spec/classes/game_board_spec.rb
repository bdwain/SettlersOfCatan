require 'spec_helper'

describe GameBoard do
  before(:all) {@map = Map.first}
  let(:map) {@map}
  let(:board) {GameBoard::GameBoard.new(map, players)}

  describe "vertex_is_free_for_building?" do
    shared_examples "returns false" do
      it "returns false" do
        expect(board.vertex_is_free_for_building?(point[0], point[1], point[2])).to be_falsey
      end
    end

    context "when the vertex is not on the map" do
      let(:players) {[]}
      let(:point) {[-5, -5, 0]}
      include_examples "returns false"
    end

    context "when the vertex is on the map" do
      let(:point) {[2, 2, 0]}

      context "when the vertex is occupied" do
        let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [point]})]}

        include_examples "returns false"
      end

      context "when the vertex is not occupied" do
        context "when there is another settlement one spot away from the vertex" do
          let(:players) {[FactoryGirl.build(:player_with_items, {settlement_points: [[1,4,1]]})]}

          include_examples "returns false"
        end

        context "when there is no other settlement one spot away from the vertex" do
          let(:players) {[]}
          
          it "returns true" do
            expect(board.vertex_is_free_for_building?(point[0], point[1], point[2])).to be true
          end
        end
      end
    end
  end

  describe "edge_is_free_for_building_by_player?" do
    shared_examples "returns false" do
      it "returns false" do
        expect(board.edge_is_free_for_building_by_player?(point[0], point[1], point[2], players.first)).to be_falsey
      end
    end

    shared_examples "returns true" do
      it "returns true" do
        expect(board.edge_is_free_for_building_by_player?(point[0], point[1], point[2], players.first)).to be true
      end
    end    

    context "when the edge is not on the map" do
      let(:players) {[]}
      let(:point) {[-5, -5, 0]}
      include_examples "returns false"
    end

    context "when the edge is on the map" do
      let(:point) {[2, 2, 0]}

      context "when the edge is occupied" do
        let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[2,2,0]], road_points: [point]})]}

        include_examples "returns false"
      end

      context "when the edge is not occupied" do
        context "when the edge is not touching anything owned by the player" do
          let(:players) {[FactoryGirl.build(:in_game_player)]}
          
          include_examples "returns false"
        end

        context "when the edge is connected to the player's road" do
          context "when another player's settlement is blocking the player's road" do
            let(:players) {[FactoryGirl.build(:player_with_items, { road_points: [[2,2,1]]}), FactoryGirl.build(:player_with_items, {settlement_points: [[2,3,1]]})]}

            include_examples "returns false"
          end

          context "when the player's road is not being blocked" do
            let(:players) {[FactoryGirl.build(:player_with_items, { road_points: [[2,2,1]]})]}

            include_examples "returns true"
          end
        end

        context "when the edge is connected to the player's settlement" do
          let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[2,2,0]]})]}

          include_examples "returns true"
        end
      end
    end
  end

  describe "get_hexes_from_vertex" do
    let(:players) {[]}
    let(:hex_points) {board.get_hexes_from_vertex(x, y, side).collect{|hex| [hex.pos_x, hex.pos_y]}}

    shared_examples "tests" do
      context "when all of the surrounding hexes are on the board" do
        let(:x) {x_all}
        let(:y) {y_all}
        
        it "returns all of the surrounding hexes" do
          expect(hex_points.sort).to eq(points_all)
        end
      end

      context "when some of the hexes are not on the board" do
        let(:x) {x_missing_hexes}
        let(:y) {y_missing_hexes}

        it "returns only the hexes that are on the board" do
          expect(hex_points).to eq(points_missing_hexes)
        end
      end
    end

    context "when side == 0" do
      let(:side) {0}
      let(:x_all) {2}
      let(:y_all) {2}
      let(:points_all) {[[1,3], [2,2], [2,3]]}
      let(:x_missing_hexes) {1}
      let(:y_missing_hexes) {4}
      let(:points_missing_hexes) {[[1,4]]}

      include_examples "tests"
    end

    context "when side == 1" do
      let(:side) {1}
      let(:x_all) {3}
      let(:y_all) {3}
      let(:points_all) {[[3,2], [3,3], [4,2]]}
      let(:x_missing_hexes) {1}
      let(:y_missing_hexes) {5}
      let(:points_missing_hexes) {[[1,4], [2,4]]}

      include_examples "tests"
    end
  end

  describe "edge_is_connected_to_vertex?" do
    let(:players) {[]}

    it "returns true when the edge is connected to the vertex" do
      expect(board.edge_is_connected_to_vertex?(2,2,0,2,2,0)).to be_truthy
    end

    it "returns false when the edge is not connected to the vertex" do
      expect(board.edge_is_connected_to_vertex?(2,2,0,2,0,0)).to be_falsey
    end
  end

  describe "get_settlements_touching_hex" do
    let(:x){2}
    let(:y){2}

    shared_examples "includes the settlement" do
      it "includes the settlement" do
        expect(board.get_settlements_touching_hex(x,y)).to eq([players.first.settlements.first])
      end
    end

    context "when there is a settlement at x,y,0" do
      let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[x,y,0]]})]}

      include_examples "includes the settlement"
    end

    context "when there is a settlement at x,y,1" do
      let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[x,y,1]]})]}

      include_examples "includes the settlement"
    end

    context "when there is a settlement at x-1,y+1,1" do
      let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[x-1,y+1,1]]})]}

      include_examples "includes the settlement"
    end

    context "when there is a settlement at x,y-1,0" do
      let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[x,y-1,0]]})]}

      include_examples "includes the settlement"
    end

    context "when there is a settlement at x+1,y-1,0" do
      let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[x+1,y-1,0]]})]}

      include_examples "includes the settlement"
    end

    context "when there is a settlement at x,y+1,1" do
      let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[x,y+1,1]]})]}

      include_examples "includes the settlement"
    end

    context "when there are multiple settlements touching the hex" do
      let(:players) {[FactoryGirl.build(:player_with_items, { settlement_points: [[x,y,0], [x+1,y-1,0], [x,y-1,0]]})]}

      it "returns all of the settlements touching the hex" do
        res = board.get_settlements_touching_hex(x,y)

        #TODO: maybe check that the arrays have the same contents better
        res.each{|s| expect(players.first.settlements.include?(s)).to be true}
        players.first.settlements.each{|s| expect(res.include?(s)).to be true}
      end
    end
  end

  describe "hex_is_on_board?" do
    let(:players) {[]}

    it "returns true for every hex on the map" do
      map.hexes.each do |hex|
        expect(board.hex_is_on_board?(hex.pos_x, hex.pos_y)).to be_truthy
      end
    end

    it "returns false when there is no hex with x,y" do
      expect(board.hex_is_on_board?(0, 0)).to be_falsey
    end
  end

  describe "vertex_is_connected_to_player?" do
    let(:x) {2}
    let(:y) {2}
    let(:side) {0}

    context "when the player has a road touching the vertex" do
      let(:players) {[FactoryGirl.build(:player_with_items, { road_points: [[2,2,0]]})]}

      it "returns true" do
        expect(board.vertex_is_connected_to_player?(x,y,side,players.first)).to be_truthy
      end
    end

    context "when the player has no roads touching the vertex" do
      let(:players) {[FactoryGirl.build(:in_game_player)]}

      it "returns false" do
        expect(board.vertex_is_connected_to_player?(x,y,side,players.first)).to be_falsey
      end

      context "when there are other players with roads touching the vertex" do
        let(:players) {[FactoryGirl.build(:in_game_player), FactoryGirl.build(:player_with_items, { road_points: [[2,2,0]]})]}

        it "returns false" do
          expect(board.vertex_is_connected_to_player?(x,y,side,players.first)).to be_falsey
        end
      end
    end
  end
end
