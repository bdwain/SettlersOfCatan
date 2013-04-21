require 'spec_helper'

describe PlayerRoad do
  describe "game_player" do
    it { should belong_to(:game_player) }
    it { should validate_presence_of(:game_player_id) }
  end

  describe "edge_x" do
    it { should validate_presence_of(:edge_x) }
    it { should validate_numericality_of(:edge_x).only_integer }
    it { should_not allow_value(-1).for(:edge_x) }
    it { should allow_value(0).for(:edge_x) }
  end

  describe "edge_y" do
    it { should validate_presence_of(:edge_y) }
    it { should validate_numericality_of(:edge_y).only_integer }
    it { should_not allow_value(-1).for(:edge_y) }
    it { should allow_value(0).for(:edge_y) }
  end
end
