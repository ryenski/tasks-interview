require "rails_helper"

RSpec.describe Task, type: :model do
  it "has a valid factory" do
    expect(build(:task)).to be_valid
  end

  it "requires a title" do
    task = build(:task, title: " ")

    expect(task).not_to be_valid
    expect(task.errors[:title]).to include("can't be blank")
  end

  it "starts incomplete" do
    expect(Task.new.complete).to be(false)
  end
end
