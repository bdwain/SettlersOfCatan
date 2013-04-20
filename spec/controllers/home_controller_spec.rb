require 'spec_helper'

describe HomeController do
  # This should return the minimal set of attributes required to create a valid
  # Foo. As you add validations to Foo, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # FoosController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "should get index" do
      get :index
      response.should be_success
    end
  end
end
