# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

SEED_PASSWORD = "password123"

users_with_messages = {
  "alice" => [
    "Hi everyone!",
    "Anyone up for a chat?",
    "I just finished the Rails tutorial.",
    "Have a great day!"
  ],
  "bob" => [
    "Hello, world!",
    "What are you all working on?",
    "Bootstrap makes styling so much easier.",
    "See you later!"
  ],
  "carol" => [
    "Good morning!",
    "Does anyone know how Turbo Streams work?",
    "I love this chat app.",
    "Time for coffee."
  ],
  "dave" => [
    "Hey there!",
    "Just pushed a new feature.",
    "PostgreSQL is running smoothly.",
    "Talk soon!"
  ],
  "erin" => [
    "Hello team!",
    "Any plans for the weekend?",
    "Testing the new message form.",
    "Goodbye for now!"
  ]
}

users_with_messages.each do |username, bodies|
  user = User.find_or_create_by!(username: username) do |u|
    u.password = SEED_PASSWORD
  end

  bodies.each do |body|
    user.messages.find_or_create_by!(body: body)
  end
end
