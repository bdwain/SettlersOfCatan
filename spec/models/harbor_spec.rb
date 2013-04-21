require 'spec_helper'

describe Harbor do
  describe "game" do
    it { should belong_to(:game) }
    it { should validate_presence_of(:game_id) }
  end

  describe "resource_type" do
    it { should_not validate_presence_of(:resource_type) }
    it { should validate_numericality_of(:resource_type).only_integer }
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
