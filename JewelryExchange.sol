// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FlexibleJewelryMarket is AccessControl, ReentrancyGuard {
    using SafeMath for uint256;

    bytes32 public constant JEWELER_ROLE = keccak256("JEWELER_ROLE");
    bytes32 public constant CONSUMER_ROLE = keccak256("CONSUMER_ROLE");

    // Basic contract details
    address public jeweler;
    address public consumer;
    uint256 public price;
    bool public isQualityCertified = true;
    bool public isSold = false;

    // Item details
    string public itemType;
    string public description;

    // Events
    event ItemListed(string itemType, string description, uint256 price);
    event ItemPurchased(address consumer, uint256 price);
    event QualityCertification(bool isCertified);
    event PriceUpdated(uint256 newPrice);
    event DescriptionUpdated(string newDescription);

    // Initialization
    constructor(address _jeweler, uint256 _price, string memory _itemType, string memory _description) {
        require(_jeweler != address(0), "Jeweler address cannot be zero");
        
        _setupRole(JEWELER_ROLE, _jeweler);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // admin can grant and revoke roles

        jeweler = _jeweler;
        price = _price;
        itemType = _itemType;
        description = _description;

        emit ItemListed(_itemType, _description, _price);
    }

    // Update description
    function updateDescription(string memory _newDescription) public {
        require(hasRole(JEWELER_ROLE, msg.sender), "Caller is not a jeweler");
        description = _newDescription;
        emit DescriptionUpdated(_newDescription);
    }

    // Quality certification
    function certifyQuality(bool _isQualityCertified) public {
        require(hasRole(JEWELER_ROLE, msg.sender), "Caller is not a jeweler");
        require(!isSold, "Item has already been sold");

        isQualityCertified = _isQualityCertified;
        emit QualityCertification(_isQualityCertified);
    }

    // Purchase item
    function purchaseItem() public payable nonReentrant {
        require(!isSold, "Item has already been sold");
        require(isQualityCertified, "Item is not quality certified");
        require(msg.value == price, "Incorrect payment amount");

        // Transfer funds to jeweler
        payable(jeweler).transfer(price);

        // Update contract state
        consumer = msg.sender;
        isSold = true;

        emit ItemPurchased(msg.sender, price);
    }

    // Update price
    function updatePrice(uint256 _newPrice) public {
        require(hasRole(JEWELER_ROLE, msg.sender), "Caller is not a jeweler");
        require(!isSold, "Item has already been sold");

        price = _newPrice;
        emit PriceUpdated(_newPrice);
    }

    // Withdraw funds (only by admin for extra security)
    function withdrawFunds(address payable _to, uint256 _amount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        require(address(this).balance >= _amount, "Insufficient balance");

        _to.transfer(_amount);
    }

    // View available balance
    function viewAvailableBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Fallback function to handle unexpected Ether transfers
    receive() external payable {
        revert("Do not send Ether directly");
    }
}
