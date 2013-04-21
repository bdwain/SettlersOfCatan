require 'spec_helper'

describe GamePlayerResource do
  describe "game_player" do
    it { should belong_to(:game_player) }
    it { should validate_presence_of(:game_player_id) }
  end

  describe "resource_type" do
    it { should validate_presence_of(:resource_type) }
    it { should validate_numericality_of(:resource_type).only_integer }
  end
end
