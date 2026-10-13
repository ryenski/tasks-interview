FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence(word_count: 3) }
  end
end
