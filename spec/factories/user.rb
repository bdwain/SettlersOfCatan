FactoryGirl.define do
  sequence(:displayname) {|n| "person#{n}@example.com" }
  sequence(:email) {|n| "person#{n}@example.com" }
  
  factory :user do
    displayname
    email
    password "password"
    password_confirmation {"#{password}"}
  end  
end