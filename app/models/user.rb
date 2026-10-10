class User < ApplicationRecord
  has_many :messages

  has_secure_password

  # validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 15 }
  # { minimum: 3, maximum: 15 } and { in: 3..15 } are equivalent:
  # both require username to be between 3 and 15 characters (inclusive).
  # `in:` takes a range and is shorter; `minimum`/`maximum` allow
  # customizing each error message separately.
  validates :username, presence: true, uniqueness: true, length: { in: 3..15 }
end
