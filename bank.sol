// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

contract Bank {
    address public owner; // Address of the bank owner
    uint public interestRate = 5; // 5% interest rate
    mapping(address => uint) public balances; // Mapping to track balances of accounts
    mapping(address => uint) public loans; // Mapping to track loan amounts for accounts
    mapping(address => uint) public deposits; // Mapping to track deposited amounts for accounts
    mapping(address => uint) public lastTransaction; // Mapping to store the timestamp of the last transaction for accounts

    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner
    }

    // Function for clients to deposit money
    function deposit() external payable {
        balances[msg.sender] += msg.value; // Increase the balance with the deposited amount
        deposits[msg.sender] += msg.value; // Update the deposited amount for the account
        lastTransaction[msg.sender] = block.timestamp; // Update the last transaction timestamp for the account
    }

    // Function for clients to withdraw money
    function withdraw(uint amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance"); // Ensure sufficient balance
        balances[msg.sender] -= amount * 1e18; // Decrease the balance
        payable(msg.sender).transfer(amount * 1e18); // Send Ether to the account
        lastTransaction[msg.sender] = block.timestamp; // Update the last transaction timestamp for the account
    }

    // Function for clients to make a payment
    function makePayment(address to, uint amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance"); // Ensure sufficient balance
        balances[msg.sender] -= amount * 1e18; // Decrease the sender's balance 
        //(* 1e18 - because otherwise it took the amount in wei and messed up the calculations)
        balances[to] += amount * 1e18; // Increase the receiver's balance
        lastTransaction[msg.sender] = block.timestamp; // Update the last transaction timestamp for the sender
        lastTransaction[to] = block.timestamp; // Update the last transaction timestamp for the receiver
    }

    // Function for the owner to pay interest on deposits
    function payInterest(address account) external {
        require(msg.sender == owner, "Only owner can pay interest"); // Only the owner can pay interest
        require(balances[account] > 0, "No balance to pay interest"); // Ensure there's a balance to pay interest

        // Calculate interest based on the elapsed time since the last transaction
        uint elapsedTime = block.timestamp - lastTransaction[account];
        uint interest = (balances[account] * interestRate * elapsedTime) / (365 days * 100); // Simple interest formula

        balances[account] += interest; // Increase the balance with the interest
        lastTransaction[account] = block.timestamp; // Update the last transaction timestamp for the account
    }

    // Function for the owner to give a loan to the customer
    function giveLoan(address to, uint amount) external {
        require(msg.sender == owner, "Only owner can give a loan"); // Only the owner can give a loan
        loans[to] += amount * 1e18; // Increase the loan amount for the recipient
        balances[to] += amount * 1e18; // Increase the recipient's balance
        lastTransaction[to] = block.timestamp; // Update the last transaction timestamp for the recipient
    }

    // Function for clients to repay the loan received
    function repayLoan(uint amount) external {
        require(loans[msg.sender] >= amount, "Insufficient loan amount"); // Ensure sufficient loan amount to repay
        loans[msg.sender] -= amount * 1e18; // Decrease the loan amount
        balances[msg.sender] -= amount * 1e18; // Decrease the sender's balance
        lastTransaction[msg.sender] = block.timestamp; // Update the last transaction timestamp for the sender
    }
}
