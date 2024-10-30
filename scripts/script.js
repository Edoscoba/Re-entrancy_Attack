const { ethers } = require("hardhat");

async function getBalance(address) {
  const balanceBigInt = await ethers.provider.getBalance(address);
  return ethers.formatEther(balanceBigInt);
}

async function main() {
  // Get example accounts
  const [deployer, customer1, customer2] = await ethers.getSigners();

  // Deploy the Bank contract
  const Bank = await ethers.getContractFactory("Bank");
  const bank = await Bank.deploy();
  await bank.waitForDeployment();  

  // Deploy Attaker contract with the Bank contract address
  const Attaker = await ethers.getContractFactory("Attaker");
  const attacker = await Attaker.deploy(bank.target); 
  await attacker.waitForDeployment(); 

  console.log("Bank deployed to:", bank.target);  
  console.log("Attaker deployed to:", attacker.target); 

  // Load up the bank with customers
  await bank.connect(customer1).deposit({ value: ethers.parseEther("20") });
  await bank.connect(customer2).deposit({ value: ethers.parseEther("10") });

  const bankBal = await getBalance(bank.target);  
  const attackerBal = await getBalance(attacker.target); 

  console.log("== Start ==");
  console.log("Bank Balance:", bankBal, "ether");
  console.log("Attacker Balance:", attackerBal, "ether");
  console.log("");

  // Launch the attack
  console.log("== Launch Attack ==");
  await attacker.connect(deployer).attack({ value: ethers.parseEther("5") });

  // Final balances
  const finalBankBal = await getBalance(bank.target);  
  const finalAttackerBal = await getBalance(attacker.target); 

  console.log("== End ==");
  console.log("Bank Balance:", finalBankBal, "ether");
  console.log("Attacker Balance:", finalAttackerBal, "ether");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
