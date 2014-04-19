require 'spec_helper'

describe Harbor do
  describe "map" do
    it { should belong_to(:map) }
    it { should validate_presence_of(:map) }
  end

  describe "resource_type" do
    it { should_not validate_presence_of(:resource_type) }
    it { should validate_numericality_of(:resource_type).only_integer }
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
