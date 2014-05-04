require "spec_helper"

describe SettlementsController do
  describe "routing" do

    it "routes to #create" do
      expect(post("/players/1/settlements")).to route_to("settlements#create", :player_id => "1")
    end
  end
end
