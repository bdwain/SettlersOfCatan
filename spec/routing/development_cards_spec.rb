require "spec_helper"

describe DevelopmentCardsController do
  describe "routing" do
    it "routes to #create" do
      expect(post("/players/1/development_cards")).to route_to("development_cards#create", :player_id => "1")
    end
  end
end
