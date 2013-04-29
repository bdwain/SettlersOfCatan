module ControllerMacros
  def login
    before(:each) do
      @current_user = FactoryGirl.create(:confirmed_user)
      sign_in @current_user
    end
  end
end