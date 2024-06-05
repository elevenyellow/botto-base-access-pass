// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccessPass is ERC1155URIStorage, AccessControl, ReentrancyGuard {
    
		uint256 private publicPrice = 0.03 ether;
		uint256 private publicMintId = 1;
		bool public publicPaused = false;

		bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

		constructor(address adminAddress) ERC1155("Botto Access Passess"){
				_grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
    }	

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE){
        _mint(to, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyRole(MINTER_ROLE){
        _mintBatch(to, ids, amounts, data);
    }

		function mintPublic(address to, uint256 amount) external payable nonReentrant{
      require(!publicPaused, "Minting is paused");
    	require(msg.value >= publicPrice * amount, "Sorry, not enough amount sent!"); 
    	_mint(to, publicMintId, amount, "");
    }

		// ADMIN FUNCTIONS

		function setBaseURI(string memory baseURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setBaseURI(baseURI);
    }

    function setURI(uint256 tokenId, string memory tokenURI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(tokenId, tokenURI);
    }		

		function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(payable(msg.sender).send(balance));
    }

    function flipPaused() public onlyRole(DEFAULT_ADMIN_ROLE) {
        publicPaused = !publicPaused;
    }

    function setPricePublic(uint256 _newPrice) public onlyRole(DEFAULT_ADMIN_ROLE) {
        publicPrice = _newPrice;
    }

    function setPublicMintId(uint256 _id) public onlyRole(DEFAULT_ADMIN_ROLE) {
        publicMintId = _id;
    }

		function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    receive() external payable {}
}
