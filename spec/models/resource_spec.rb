require 'spec_helper'

describe Resource do
  describe "player" do
    it { should belong_to(:player) }
    it { should validate_presence_of(:player) }
  end

  describe "type" do
    it { should validate_presence_of(:type) }
    it { should validate_numericality_of(:type).only_integer }
  end
end
