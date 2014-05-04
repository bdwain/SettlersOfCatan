require "spec_helper"

describe RoadsController do
  describe "routing" do

    it "routes to #create" do
      expect(post("/players/1/roads")).to route_to("roads#create", :player_id => "1")
    end
  end
end
