require "test_helper"
require "parallel"

class AccountTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  def in_parallel(*lambdas)
    Parallel.each(lambdas) do |lambda|
      retries = 0

      begin
        lambda.call
      rescue SQLite3::BusyException
        retry if (retries += 1) < 5
      end
    end
  end

  test "create" do
    account = Account.create_with_balance!(0)

    assert account.persisted?
    assert account.current_balance == 0
    assert account.incoming_transactions.count == 0
  end

  test "create with balance" do
    account = Account.create_with_balance!(10)

    assert account.persisted?
    assert account.current_balance == 10
    assert account.incoming_transactions&.count == 1
    assert account.incoming_transactions&.first&.amount == 10
  end

  test "deposit" do
    account = Account.create_with_balance!(0)

    in_parallel(
      -> { Account.find(account.id).deposit!(100) },
      -> { Account.find(account.id).deposit!(200) }
    )
    account.reload

    assert account.current_balance == 300
    assert account.incoming_transactions.count == 2
    assert account.incoming_transactions.map(&:amount).sort == [100, 200]
  end

  test "withdraw" do
    account = Account.create_with_balance!(100)

    account.withdraw!(80)
    account.reload

    assert account.current_balance == 20
    assert account.outcoming_transactions.count == 1
    assert account.outcoming_transactions&.first&.amount == 80

    assert_raises do
      account.withdraw(40)
    end
  end

  test "parallel withdraw" do
    account = Account.create_with_balance!(100)

    assert_raises do
      in_parallel(
        -> { Account.find(account.id).withdraw!(100) },
        -> { Account.find(account.id).withdraw!(100) },
      )
    end
    account.reload

    assert account.current_balance == 0
    assert account.outcoming_transactions.count == 1
    assert account.outcoming_transactions&.first&.amount == 100
  end

  test "transfer" do
    account1 = Account.create_with_balance!(100)
    account2 = Account.create_with_balance!(100)

    account1.transfer!(account2, 80)
    account1.reload
    account2.reload

    assert account1.current_balance == 20
    assert account2.current_balance == 180
    assert account1.outcoming_transactions.last.id == account2.incoming_transactions.last.id
    assert account1.outcoming_transactions.last.amount == 80

    assert_raise do
      account1.transfer(account2, 30)
    end

    assert_raise do
      account1.transfer(nil, 30)
    end
  end

  test "parallel transfer" do
    account1 = Account.create_with_balance!(100)
    account2 = Account.create_with_balance!(100)
    account3 = Account.create_with_balance!(100)

    assert_raises do
      in_parallel(
        -> { Account.find(account1.id).transfer!(Account.find(account2.id), 100) },
        -> { Account.find(account1.id).transfer!(Account.find(account3.id), 100) }
      )
    end
    account1.reload
    account2.reload
    account3.reload

    assert account1.current_balance == 0
    assert (account2.current_balance == 200 && account3.current_balance == 100) ^ 
            (account3.current_balance == 200 && account2.current_balance == 100)
  end
end
