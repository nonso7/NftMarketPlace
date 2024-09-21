// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

    uint256 public listingPrice = 0.005 ether;

    address payable public owner;
    // address public nftAddress;
    
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    mapping (uint256 => MarketItem) public idMarketItem;

    event idMarketItemCreated(uint256 indexed tokenId, address seller, address owner, uint256 price, bool sold);
    event HighListingPrice(uint256 indexed tokenId, address seller);

    function onlyOwner() private view {
        if(msg.sender != owner) {
            revert NotOwner();
        }
    }

    constructor() ERC721("NFT Jagaban Token", "JAG") {
        owner = payable(msg.sender);
    }

    // function updateListingPrice(uint256 _listingPrice) public payable {
    //     onlyOwner();
    //     listingPrice = _listingPrice;
    // }

    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256) {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        

        createMarketItem(newTokenId, price);

      

        return newTokenId;
    }
    //listing the nft on marketplace for sale
    function createMarketItem(uint256 tokenId, uint256 price) public payable {
        if(price < 0) {
            revert MustBeAtLeastOne();
        }
         if(msg.value != listingPrice) {
            revert ListingMustBeEqualToPrice();
        }
        //creating market item
        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable (msg.sender),
            payable (address(this)),
            price,
            false
        );
        //transfer nft to marketPlace
        _transfer(msg.sender, address(this), tokenId);
        emit idMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }
    //remove listedItem due to high listing price
    function removeListedItem(uint256 tokenId) private {
        delete idMarketItem[tokenId];
        emit HighListingPrice(tokenId, address(this));
    }

    //selling nft a given price(listingfee functionalities)
    function sellingNfts(uint256 tokenId) public payable{
        uint256 price = idMarketItem[tokenId].price;
        
          if( idMarketItem[tokenId].owner != msg.sender) {
            revert OnlyItemOwner();
        }
         if(msg.value != price) {
            revert ListingMustBeEqualToPrice();
        }

        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable (msg.sender);
        //After a sale, ownership should transfer to the buyer.
        idMarketItem[tokenId].owner = payable (msg.sender);

        _tokenSold.increment();

       _transfer(address(this), msg.sender, tokenId);
        //A listing fee (listingPrice) is transferred 
        //to the contract owner (the marketplace owner) 
        //for facilitating the sale.
       payable(owner).transfer(listingPrice);
       // Pay the seller their sale proceeds
       payable(idMarketItem[tokenId].seller).transfer(msg.value);

    }

    //reselling nfts at a new price
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
        //the nft is listed back onto the market place
        _transfer(msg.sender, address(this), tokenId);
    }
    // handle the sale of an NFT from the marketplace to a buyer.
    function ItemSales(uint256 tokenId, uint256 price) public payable {
        if(price < 0) {
            revert MustBeAtLeastOne();
        }
        idMarketItem[tokenId].sold = true;
        // idMarketItem[tokenId].seller = payable(address(this));
        //transfers the ownership to the buyer
        idMarketItem[tokenId].owner = payable (msg.sender);
        idMarketItem[tokenId].price = price;

        _tokenSold.increment();
        //transfer from nft from the marketplace to the buyer
        _transfer(address(this), msg.sender, tokenId);
        // payable(owner).transfer(listingPrice);
        //Pay the original seller the sale price
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }
   

    function checkOwner(uint256 tokenId) external view returns(address) {
        onlyOwner();
       return  _ownerOf(tokenId);
    }

    // function transferOwnership(uint256 tokenId, address _to) external {
    //     onlyOwner();
    // }

    //getting list of unsold nft 
    function fetchMarketItem() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _tokenSold.current();

        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for(uint i = 0; i < itemCount; i++) {
            if(idMarketItem[i + 1].owner == address(0)){
                uint currentId = idMarketItem[i+1].tokenId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex +=1;
            }
            
        }
         
         return items;

    }

    // getting purchased item
    
}
