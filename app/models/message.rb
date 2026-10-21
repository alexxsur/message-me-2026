class Message < ApplicationRecord
  belongs_to :user

  validates :body, presence: true

  after_create_commit :broadcast_message

  private

  def broadcast_message
    ActionCable.server.broadcast("chatroom_channel", {
      id: id, body: body, created_at: created_at,
      user: { id: user.id, username: user.username }
    })
  end
end
