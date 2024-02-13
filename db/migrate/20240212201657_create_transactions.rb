class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.belongs_to :from_account, null: true
      t.belongs_to :to_account, null: true
      t.decimal :amount, null: false

      t.timestamps
    end
  end
end
