require 'spec_helper'

describe Settlement do
  describe "player" do
    it { should belong_to(:player) }
    it { should validate_presence_of(:player) }
  end

  describe "vertex_x" do
    it { should validate_presence_of(:vertex_x) }
    it { should validate_numericality_of(:vertex_x).only_integer }
  end

  describe "vertex_y" do
    it { should validate_presence_of(:vertex_y) }
    it { should validate_numericality_of(:vertex_y).only_integer }
  end

  describe "side" do
    it { should validate_presence_of(:side) }
    it { should ensure_inclusion_of(:side).in_range(0..1) } 
  end  
end
