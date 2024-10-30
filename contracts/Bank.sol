// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

contract Bank {
    using Address for address payable;
  
    mapping (address => uint256) balances; // Mapping to track each user's balance

   
  
    // Function to deposit Ether into the bank
    function deposit() external payable {
        balances[msg.sender] += msg.value; // Update the user's balance with the deposited amount
    }

    // Function to withdraw Ether from the bank
    function withdraw() external {
        require(balances[msg.sender] > 0, "Insufficient balance"); // Ensure the user has a positive balance

        // Logging the current bank and attacker balances 
        console.log("");
        console.log("Bank balance", address(this).balance);
        console.log("attacker balance", balances[msg.sender]);

        // IMPORTANT: Send Ether to the user AFTER updating the state to prevent reentrancy attacks
        payable(msg.sender).sendValue(balances[msg.sender]);
        balances[msg.sender] = 0; // Set the user's balance to 0 to reflect withdrawal
    }  

    // Function to get the current balance of the bank
    function getBalance() external view returns (uint256) {
        return address(this).balance; // Return the total balance of the bank contract
    }
}
