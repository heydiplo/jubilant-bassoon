class Transaction < ApplicationRecord
  validates :amount, numericality: { :greater_than_or_equal_to => 0 }
  belongs_to :from_account, class_name: 'Account', required: false
  belongs_to :to_account, class_name: 'Account', required: false
end
