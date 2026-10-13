require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "lists users alphabetically by name" do
    grace = create(:user, name: "Grace Hopper")
    ada = create(:user, name: "Ada Lovelace")

    expect(User.alphabetical).to eq([ada, grace])
  end
end
