require 'spec_helper'

describe Settlement do
  describe "player" do
    it { should belong_to(:player) }
    it { should validate_presence_of(:player_id) }
  end

  describe "vertex_x" do
    it { should validate_presence_of(:vertex_x) }
    it { should validate_numericality_of(:vertex_x).only_integer }
    it { should_not allow_value(-1).for(:vertex_x) }
    it { should allow_value(0).for(:vertex_x) }
  end

  describe "vertex_y" do
    it { should validate_presence_of(:vertex_y) }
    it { should validate_numericality_of(:vertex_y).only_integer }
    it { should_not allow_value(-1).for(:vertex_y) }
    it { should allow_value(0).for(:vertex_y) }
  end
end
