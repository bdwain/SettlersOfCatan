require 'spec_helper'

describe Chat do
  describe "msg" do
    it { should validate_presence_of(:msg) }
    it { should ensure_length_of(:msg).is_at_least(1).is_at_most(300) }
  end

  describe "sender" do
    it { should belong_to(:sender) }
    it { should validate_presence_of(:sender) }
  end
end
