require 'spec_helper'

describe Road do
  describe "player" do
    it { should belong_to(:player) }
    it { should validate_presence_of(:player) }
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
