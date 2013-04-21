require 'spec_helper'

describe Game do
  describe "winner" do
    it { should belong_to(:winner).class_name('User') }
  end

  describe "hexes" do
    it { should have_many(:hexes) }
  end
 
  describe "harbors" do
    it { should have_many(:harbors) }
  end

  describe "players" do
    it { should have_many(:players) }
  end

  describe "development_cards" do
    it { should have_many(:development_cards) }
  end

  describe "status" do
    it { should validate_presence_of(:status) }
    it { should ensure_inclusion_of(:status).in_range(1..5) }
  end

  describe "middle_row_width" do
    it { should validate_presence_of(:middle_row_width) }
    it { should validate_numericality_of(:middle_row_width).only_integer }
    it { should_not allow_value(4).for(:middle_row_width) }
    it { should allow_value(5).for(:middle_row_width) }
  end

  describe "num_middle_rows" do
    it { should validate_presence_of(:num_middle_rows) }
    it { should validate_numericality_of(:num_middle_rows).only_integer }
    it { should_not allow_value(0).for(:num_middle_rows) }
    it { should allow_value(1).for(:num_middle_rows) }
  end

  describe "num_rows" do
    it { should validate_presence_of(:num_rows) }
    it { should validate_numericality_of(:num_rows).only_integer }
    it { should_not allow_value(4).for(:num_rows) }
    it { should allow_value(5).for(:num_rows) }
  end

  describe "num_players" do
    it { should validate_presence_of(:num_players) }
    it { should validate_numericality_of(:num_players).only_integer }
    it { should ensure_inclusion_of(:num_players).in_range(3..4) } 
  end

  describe "robber_x" do
    it { should validate_presence_of(:robber_x) }
    it { should validate_numericality_of(:robber_x).only_integer }
  end

  describe "robber_y" do
    it { should validate_presence_of(:robber_y) }
    it { should validate_numericality_of(:robber_y).only_integer }
  end

  describe "status_checkers" do
    before(:all) do
      @rand = Random.new
    end

    describe "is_waiting_for_players?" do
      it "returns true if status is 1" do
        game = FactoryGirl.build(:game)
        game.status = 1
        game.is_waiting_for_players?.should be_true
      end
      
      it "returns false if status is not 1" do
        game = FactoryGirl.build(:game)
        game.status = @rand.rand(2..100)
        game.is_waiting_for_players?.should be_false
      end
    end

    describe "is_rolling_for_turn_order?" do
      it "returns true if status is 2" do
        game = FactoryGirl.build(:game)
        game.status = 2
        game.is_rolling_for_turn_order?.should be_true
      end
      
      it "returns false if status is not 2" do
        game = FactoryGirl.build(:game)
        game.status = @rand.rand(1..100) until game.status != 2
        game.is_rolling_for_turn_order?.should be_false
      end
    end

    describe "is_placing_initial_pieces?" do
      it "returns true if status is 3" do
        game = FactoryGirl.build(:game)
        game.status = 3
        game.is_placing_initial_pieces?.should be_true
      end
      
      it "returns false if status is not 3" do
        game = FactoryGirl.build(:game)
        game.status = @rand.rand(1..100) until game.status != 3
        game.is_placing_initial_pieces?.should be_false
      end
    end

    describe "is_playing?" do
      it "returns true if status is 4" do
        game = FactoryGirl.build(:game)
        game.status = 4
        game.is_playing?.should be_true
      end
      
      it "returns false if status is not 4" do
        game = FactoryGirl.build(:game)
        game.status = @rand.rand(1..100) until game.status != 4
        game.is_playing?.should be_false
      end
    end

    describe "is_completed?" do
      it "returns true if status is 5" do
        game = FactoryGirl.build(:game)
        game.status = 5
        game.is_completed?.should be_true
      end
      
      it "returns false if status is not 5" do
        game = FactoryGirl.build(:game)
        game.status = @rand.rand(1..100) until game.status != 5
        game.is_completed?.should be_false
      end
    end
  end

  describe "has_user?" do
    it "returns true if a game's players include user" do
      game = FactoryGirl.create(:game_with_players)
      game.has_user?(game.players.first.user).should be_true
    end

    it "returns false if a game's players do not include user" do
      game = FactoryGirl.create(:game_with_players)
      user = FactoryGirl.build(:user)
      game.has_user?(user).should be_false
    end
  end
end
