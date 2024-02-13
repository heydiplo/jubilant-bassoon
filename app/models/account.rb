class Account < ApplicationRecord

  has_many :incoming_transactions, class_name: 'Transaction', foreign_key: 'to_account_id'
  has_many :outcoming_transactions, class_name: 'Transaction', foreign_key: 'from_account_id'

  validates :current_balance, numericality: { :greater_than_or_equal_to => 0 }

  class << self
    def create_with_balance!(balance)
      transaction do
        account = create!(current_balance: balance)
        account.incoming_transactions.create!(amount: balance) unless balance.zero?

        account
      end
    end
  end

  def recalculate_balance!
    update!(
      current_balance: incoming_transactions.sum(:amount) - outcoming_transactions.sum(:amount)
    )
  end

  def deposit!(amount)
    transaction do
      incoming_transactions.create!(amount: amount)
      recalculate_balance!
    end
  end

  def withdraw!(amount)
    transaction do
      outcoming_transactions.create!(amount: amount)
      recalculate_balance!
    end
  end

  def transfer!(other_account, amount)
    transaction do
      raise ActiveModel::ValidationError unless other_account

      outcoming_transactions.create!(amount: amount, to_account: other_account)
      recalculate_balance!
      other_account.recalculate_balance!
    end
  end
end
