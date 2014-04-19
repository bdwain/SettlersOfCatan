require 'spec_helper'

describe Road do
  describe "player" do
    it { should belong_to(:player) }
    it { should validate_presence_of(:player) }
  end

  describe "edge_x" do
    it { should validate_presence_of(:edge_x) }
    it { should validate_numericality_of(:edge_x).only_integer }
  end

  describe "edge_y" do
    it { should validate_presence_of(:edge_y) }
    it { should validate_numericality_of(:edge_y).only_integer }
  end

  describe "side" do
    it { should validate_presence_of(:side) }
    it { should ensure_inclusion_of(:side).in_range(0..2) } 
  end
end
