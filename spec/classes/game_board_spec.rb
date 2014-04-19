require 'spec_helper'

describe GameBoard do
  before(:all) {@map = Map.first}

  describe "vertex_is_free_for_building?" do
    let(:board) {GameBoard::GameBoard.new(@map, players)}

    shared_examples "returns false" do
      it "returns false" do
        board.vertex_is_free_for_building?(point[0], point[1], point[2]).should be_false
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
            board.vertex_is_free_for_building?(point[0], point[1], point[2]).should be_true
          end
        end
      end
    end
  end

  describe "edge_is_free_for_building_by_player?" do
    let(:board) {GameBoard::GameBoard.new(@map, players)}

    shared_examples "returns false" do
      it "returns false" do
        board.edge_is_free_for_building_by_player?(point[0], point[1], point[2], players.first).should be_false
      end
    end

    shared_examples "returns true" do
      it "returns true" do
        board.edge_is_free_for_building_by_player?(point[0], point[1], point[2], players.first).should be_true
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

  end
end
