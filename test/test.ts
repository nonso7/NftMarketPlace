import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ethers } from "ethers";


describe("NFTMarketPlace", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployMarketContract() {
    const [owner, userAddress1, userAddress2] = await hre.ethers.getSigners();

    const MarketPlace = await hre.ethers.getContractFactory("NFTMarketPlace");
    let market = await MarketPlace.deploy();

   return { owner, userAddress1, userAddress2, market}
    
  }

  describe("Deployment", function () {
    it("Should mint a tokena and check if owner is correct", async function () {
      const { market, owner } = await loadFixture(deployMarketContract);

      //it is a random uri
      const tokenURI = "https://example.com/nft-metadata";
      const mintPrice = ethers.parseUnits("1");
      const listingPrice = await market.getListingPrice();

      await market.connect(owner).createToken(tokenURI, mintPrice, { value: listingPrice });

      // Check owner of the first minted token (tokenId = 1)
      const ownerAddress = await market.ownerOf(1);

      // Compare the owner of the token with the owner address
      expect(await market.owner()).to.equal(owner.address); 

      console.log("Expected owner:", owner.address);
      console.log("Actual owner from contract:", await market.owner());
    });

    it("Should check if userAdress list NFTs correctly", async function () {
      const { userAddress1, userAddress2, market, owner } = await loadFixture(deployMarketContract);

      const tokenURI = "https://example.com/nft-metadata";
      const mintPrice = ethers.parseUnits("1");
      const listingPrice = await market.getListingPrice();

    await market.connect(userAddress1).createToken(tokenURI, mintPrice, { value:  listingPrice});
      // await market.connect(userAddress2).createToken(tokenURI, mintPrice, { value:  listingPrice});

      const tokenId = 1;
      const price = ethers.parseUnits("0.001");
      
      await expect(market.connect(userAddress1).createMarketItem(tokenId, mintPrice, { value: listingPrice }))
      .to.emit(market, "idMarketItemCreated")
      .withArgs(tokenId, userAddress1.address, owner.address, price, false);

    const marketItem = await market.idMarketItem(tokenId); // Fetch the created market item

  
  expect(marketItem.tokenId).to.equal(tokenId);
  expect(marketItem.seller).to.equal(userAddress1.address);
  expect(marketItem.owner).to.equal(owner.address);
  expect(marketItem.price.toString()).to.equal(mintPrice.toString());
  expect(marketItem.sold).to.equal(false);
    
    });

    // it("Should set the right owner", async function () {
    //   const { lock, owner } = await loadFixture(deployOneYearLockFixture);

    //   expect(await lock.owner()).to.equal(owner.address);
    // });

    // it("Should receive and store the funds to lock", async function () {
    //   const { lock, lockedAmount } = await loadFixture(
    //     deployOneYearLockFixture
    //   );

    //   expect(await hre.ethers.provider.getBalance(lock.target)).to.equal(
    //     lockedAmount
    //   );
    // });

    // it("Should fail if the unlockTime is not in the future", async function () {
    //   // We don't use the fixture here because we want a different deployment
    //   const latestTime = await time.latest();
    //   const Lock = await hre.ethers.getContractFactory("Lock");
    //   await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
    //     "Unlock time should be in the future"
    //   );
    // });
  });

  // describe("Withdrawals", function () {
  //   describe("Validations", function () {
  //     it("Should revert with the right error if called too soon", async function () {
  //       const { lock } = await loadFixture(deployOneYearLockFixture);

  //       await expect(lock.withdraw()).to.be.revertedWith(
  //         "You can't withdraw yet"
  //       );
  //     });

  //     it("Should revert with the right error if called from another account", async function () {
  //       const { lock, unlockTime, otherAccount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // We can increase the time in Hardhat Network
  //       await time.increaseTo(unlockTime);

  //       // We use lock.connect() to send a transaction from another account
  //       await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
  //         "You aren't the owner"
  //       );
  //     });

  //     it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
  //       const { lock, unlockTime } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // Transactions are sent using the first signer by default
  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).not.to.be.reverted;
  //     });
  //   });

  //   describe("Events", function () {
  //     it("Should emit an event on withdrawals", async function () {
  //       const { lock, unlockTime, lockedAmount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw())
  //         .to.emit(lock, "Withdrawal")
  //         .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
  //     });
  //   });

  //   describe("Transfers", function () {
  //     it("Should transfer the funds to the owner", async function () {
  //       const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).to.changeEtherBalances(
  //         [owner, lock],
  //         [lockedAmount, -lockedAmount]
  //       );
  //     });
  //   });
  // });
});
