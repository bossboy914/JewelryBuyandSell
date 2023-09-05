const { expect } = require("chai");

describe("SothebysAuction contract", function () {
  let SothebysAuction, sothebysAuction, owner, addr1, addr2;

  beforeEach(async function () {
    SothebysAuction = await ethers.getContractFactory("SothebysAuction");
    [owner, addr1, addr2] = await ethers.getSigners();

    sothebysAuction = await SothebysAuction.deploy();
    await sothebysAuction.deployed();
  });

  describe("Auction finalization", function () {
    it("Should increase the seller's balance by the correct amount", async function () {
      // Grant AUCTIONEER_ROLE to owner
      await sothebysAuction.grantRole(ethers.utils.id("AUCTIONEER_ROLE"), owner.address);

      // List an item with a starting price of 1 ether
      await sothebysAuction.listItem("Painting", ethers.utils.parseEther("1"), false, 0);

      // Grant BIDDER_ROLE to addr1
      await sothebysAuction.grantRole(ethers.utils.id("BIDDER_ROLE"), addr1.address);

      // Place a bid of 2 ethers from addr1
      await sothebysAuction.connect(addr1).placeBid(0, { value: ethers.utils.parseEther("2") });

      // Record the seller's balance before finalizing the auction
      const initialBalance = await ethers.provider.getBalance(owner.address);

      // Finalize the auction
      await sothebysAuction.finalizeAuction(0);

      // Record the seller's balance after finalizing the auction
      const finalBalance = await ethers.provider.getBalance(owner.address);

      // Check that the seller's balance increased by 2 ethers
      expect(finalBalance).to.be.above(initialBalance);
      expect(finalBalance.sub(initialBalance)).to.equal(ethers.utils.parseEther("2"));
    });
  });
});
