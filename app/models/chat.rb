class Chat < ApplicationRecord
  has_one :connection, dependent: :destroy
end
