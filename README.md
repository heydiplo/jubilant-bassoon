# Code Test 

## Task

Develop a service that simulates basic banking operations in a programming language of your choice. This service will manage accounts, process deposits, withdrawals, and transfers between accounts. The system should be designed reflecting real-world constraints of a bank.

## Requirements

1. A class or set of functions that allow:
 - Account creation: Allow users to create an account with an initial deposit.
 - Deposit: Enable users to deposit money into their account.
 - Withdrawal: Allow users to withdraw money from their account, ensuring that overdrafts are not allowed.
 - Transfer: Enable transferring funds between accounts.
 - Account balance: Provide the ability to check the account balance.
2. Database:
 - In-memory data storage will suffice, no need to have a database alongside the project, but you can add one at your discretion

## Solution

`app/models/account.rb` implements all required methods.
`test/models/account_test.rb` contains tests.
`bundle install && ./bin/rake` to run them.

## Notes

1. Go with Rails as I and you (probably) know it well.
2. It's important to avoid duplication, and I rely on database transactions to ensure abort if validation fails.
3. We can get away without storing `current_balance` in `accounts`, it can always be calculated from transactions. But it's likely to be used a lot, so I'm denormalizing it.
