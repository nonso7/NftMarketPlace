// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketPlace is ERC721URIStorage {
    error NotOwner();
    error MustBeAtLeastOne();
    error ListingMustBeEqualToPrice();
    error OnlyItemOwner();

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _tokenSold;

    uint256 listingPrice = 0.005 ether;

    address payable owner;
    
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    mapping (uint256 => MarketItem) private idMarketItem;

    event idMarketItemCreated(uint256 indexed tokenId, address seller, address owner, uint256 price, bool sold);

    function onlyOwner() private view {
        if(msg.sender != owner) {
            revert NotOwner();
        }
    }

    constructor() ERC721("NFT Jagaban Token", "JAG") {
        owner = payable(msg.sender);
    }

    function updateListingPrice(uint256 _listingPrice) public payable {
        onlyOwner();
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256) {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        // idMarketItem[newTokenId] = MarketItem(
        //     newTokenId,
        //     payable(msg.sender),
        //     payable(address(this)),
        //     price,
        //     false
        // );

        

        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        if(price > 0) {
            revert MustBeAtLeastOne();
        }
         if(msg.value != listingPrice) {
            revert ListingMustBeEqualToPrice()
        }
        
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable (msg.sender),
            payable (address(this)),
            price,
            false
        )

        _transfer(msg.sender, address(this), tokenId);
        emit idMarketItemCreated(newTokenId, msg.sender, address(this), price, false);
    }

    function resellToken(uint256 tokenId, uint256 price) public payable {
          if( idMarketItem[tokenId].owner != msg.sender) {
            revert OnlyItemOwner();
        }

         if(msg.value != listingPrice) {
            revert ListingMustBeEqualToPrice();
        }

        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable (msg.sender);
        idMarketItem[tokenId].owner = payable (address(this));

        _tokenSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    
}
