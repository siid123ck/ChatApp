

async function main() {
  

  const Chatapp = await hre.ethers.getContractFactory("Chatapp");
  const chatapp = await Lock.deploy();

  await chatapp.deployed();

  console.log(
    ` chatapp is deployed to ${chatapp.address}`
  );
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
