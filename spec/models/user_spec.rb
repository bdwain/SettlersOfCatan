require 'spec_helper'

describe User do
  it { should validate_presence_of(:displayname) }
  it { should ensure_length_of(:displayname).is_at_least(3).is_at_most(20) }
  it { should have_many(:players) }

  it "calls player_account_deleted on all of its games when deleted" do
    game = FactoryGirl.create(:game)
    game2 = FactoryGirl.create(:game, creator: game.creator)

    game.creator.stub(:players).and_return([game.players.first, game2.players.first])

    game.should_receive(:player_account_deleted).with(game.creator.players.first)
    game2.should_receive(:player_account_deleted).with(game.creator.players.last)
    game.creator.destroy
  end

  it "destroys all of its player objects on destruction" do
    game = FactoryGirl.create(:game)
    game2 = FactoryGirl.create(:game, creator: game.creator)

    expect{
      game.creator.destroy
    }.to change(Player, :count).by(-2)
  end
end

