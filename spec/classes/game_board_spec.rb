require 'spec_helper'

describe GameBoard do
  describe "vertex_is_free_for_building?" do
    before(:all) {@map = Map.first}
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
        let(:players) {[FactoryGirl.build(:player_with_settlement, {settlement_x: point[0], settlement_y: point[1], settlement_side: point[2]})]}

        include_examples "returns false"
      end

      context "when the vertex is not occupied" do
        context "when there is another settlement one spot away from the vertex" do
          let(:players) {[FactoryGirl.build(:player_with_settlement, {settlement_x: 1, settlement_y: 4, settlement_side: 1})]}

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

  end

  describe "get_hexes_from_vertex" do

  end
end
