# This file seeds the database with a starting set of users and tasks. Load it
# with `bin/rails db:seed` (or alongside db:create via `bin/rails db:setup`).
#
# All accounts share the password "abc123" so any of them can be used to log in.

users = [
  "Ada Lovelace",
  "Grace Hopper",
  "Katherine Johnson",
  "Alan Turing",
  "Edsger Dijkstra"
].each_with_index.map do |name, index|
  User.where(email: "user#{index + 1}@tern.travel").first_or_create!(
    name: name,
    password: "abc123",
    password_confirmation: "abc123"
  )
end

# Titles intentionally vary in casing, length, and shared substrings (several
# "Book ...", two "... client ...") so filtering and sorting have something real
# to chew on. A few descriptions are left blank to exercise the index view's
# nil-safe truncation.
tasks = [
  {title: "Book flights to Lisbon", complete: true, description: "Outbound May 3, return May 17. Aisle seats for both legs."},
  {title: "Book hotel in Kyoto", complete: false, description: "Ryokan near Gion, 4 nights, breakfast included."},
  {title: "Book airport transfer", complete: false, description: nil},
  {title: "Confirm client itinerary", complete: false, description: "Send the day-by-day plan to the Hendricks party for sign-off."},
  {title: "Email client welcome packet", complete: true, description: "Visa reminders, packing list, emergency contacts."},
  {title: "Renew passport", complete: false, description: "Expedited — current one expires in under six months."},
  {title: "Update travel insurance", complete: false, description: nil},
  {title: "Draft Q3 trip budget", complete: false, description: "Roll up supplier quotes and a 12% contingency."},
  {title: "Review supplier contracts", complete: true, description: "Check cancellation windows before the deposit deadline."},
  {title: "Schedule team offsite", complete: false, description: "Two days, somewhere reachable by train for everyone."},
  {title: "Reconcile expense report", complete: false, description: "March card statement against the receipts folder."},
  {title: "Plan Patagonia route", complete: false, description: "El Chaltén to Torres del Paine, padding for weather days."},
  {title: "Order currency for Japan", complete: false, description: nil},
  {title: "Sync with ground operator", complete: true, description: "Confirm the driver and guide for the Marrakech leg."},
  {title: "Archive old itineraries", complete: false, description: "Anything from last season can move to cold storage."},
  {title: "follow up with Lisbon hotel", complete: false, description: "Lowercase on purpose — still waiting on the room upgrade."}
]

# Spread assignees across users, leaving every fourth task unassigned, so the
# index shows both states.
tasks.each_with_index do |attributes, index|
  assignee = users[index % users.size] unless (index % 4).zero?
  Task.where(title: attributes[:title]).first_or_create!(attributes.except(:title).merge(assignee:))
end

legacy_tasks = [
  {title: "Buy tickets: book the 9am AA flight to Cancun", complete: false},
  {title: "Call hotel: confirm the late checkout for the Rivera party", complete: false},
  {title: "Passport: renew before the Japan trip", complete: true},
  {title: "Insurance: add the Patagonia leg to the policy", complete: false}
]

legacy_tasks.each do |attributes|
  Task.where(title: attributes[:title]).first_or_create!(attributes.except(:title))
end
