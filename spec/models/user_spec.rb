require 'spec_helper'

describe User do
  describe "displayname" do
    it { should validate_presence_of(:displayname) }
    it { should ensure_length_of(:displayname).is_at_least(3).is_at_most(20) }
  end

  describe "players" do
    it { should have_many(:players) }
  end
  
  describe "destruction" do
    let(:game) { FactoryGirl.create(:game) }
    it "calls game.remove_player? on each of a user's players' games" do
      game2 = FactoryGirl.create(:game, creator: game.creator)

      game.creator.stub(:players).and_return([game.players.first, game2.players.first])

      game.should_receive(:remove_player?).with(game.creator.players.first)
      game2.should_receive(:remove_player?).with(game.creator.players.last)
      game.creator.destroy
    end

    it "destroys a game when remove_player? return true" do
      game.creator.stub(:players).and_return([game.players.first])
      game.stub(:remove_player?).and_return(false)
      expect{
        game.creator.destroy
      }.to change(Game, :count).by(-1)
    end

    it "doesn't destroy a game when remove_player returns true" do
      game.creator.stub(:players).and_return([game.players.first])      
      game.stub(:remove_player?).and_return(true)
      expect{
        game.creator.destroy
      }.to_not change(Game, :count)
    end
  end
end

