// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721Royalty} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Quantum Cats
/// @notice Production-oriented ERC-721 mint contract. Replace the collection
/// parameters below before mainnet deployment and audit before accepting funds.
contract QuantumCats is ERC721, ERC721Pausable, ERC721Royalty, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public immutable mintPrice;
    uint256 public immutable maxPerWallet;
    uint256 private _nextTokenId = 1;
    string private _baseTokenURI;
    string private _unrevealedURI;
    bool public revealed;

    mapping(address => uint256) public mintedByWallet;

    event Minted(address indexed minter, uint256 indexed tokenId);
    event RevealStateChanged(bool revealed);
    event BaseURIUpdated(string newBaseURI);
    event UnrevealedURIUpdated(string newURI);

    constructor(
        address initialOwner,
        uint256 priceWei,
        uint256 walletLimit,
        string memory baseURI,
        string memory unrevealedURI,
        address royaltyReceiver,
        uint96 royaltyBps
    ) ERC721("Quantum Cats", "QCATS") Ownable(initialOwner) {
        require(initialOwner != address(0), "owner=zero");
        require(walletLimit > 0, "walletLimit=zero");
        require(royaltyBps <= 1000, "royalty too high");
        mintPrice = priceWei;
        maxPerWallet = walletLimit;
        _baseTokenURI = baseURI;
        _unrevealedURI = unrevealedURI;
        _setDefaultRoyalty(royaltyReceiver == address(0) ? initialOwner : royaltyReceiver, royaltyBps);
    }

    function mint(uint256 quantity) external payable whenNotPaused returns (uint256 firstTokenId) {
        require(quantity > 0, "quantity=zero");
        require(quantity <= 20, "batch too large");
        require(totalSupply() + quantity <= MAX_SUPPLY, "sold out");
        require(mintedByWallet[msg.sender] + quantity <= maxPerWallet, "wallet limit");
        require(msg.value == mintPrice * quantity, "wrong ETH value");

        firstTokenId = _nextTokenId;
        mintedByWallet[msg.sender] += quantity;
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(msg.sender, tokenId);
            emit Minted(msg.sender, tokenId);
        }
    }

    function ownerMint(address to, uint256 quantity) external onlyOwner returns (uint256 firstTokenId) {
        require(to != address(0), "to=zero");
        require(quantity > 0 && quantity <= 50, "invalid quantity");
        require(totalSupply() + quantity <= MAX_SUPPLY, "sold out");
        firstTokenId = _nextTokenId;
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(to, tokenId);
            emit Minted(to, tokenId);
        }
    }

    function reveal() external onlyOwner {
        revealed = true;
        emit RevealStateChanged(true);
    }

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }

    function setUnrevealedURI(string calldata newURI) external onlyOwner {
        _unrevealedURI = newURI;
        emit UnrevealedURIUpdated(newURI);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId - 1;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "nonexistent token");
        if (!revealed) return _unrevealedURI;
        return string.concat(_baseTokenURI, _toString(tokenId), ".json");
    }

    function withdraw(address payable recipient) external onlyOwner {
        require(recipient != address(0), "recipient=zero");
        uint256 amount = address(this).balance;
        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "withdraw failed");
    }

    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, ERC721Royalty)
        returns (bool)
    { return super.supportsInterface(interfaceId); }

    function _update(address to, uint256 tokenId, address auth)
        internal override(ERC721, ERC721Pausable)
        returns (address)
    { return super._update(to, tokenId, auth); }

    function _baseURI() internal view override returns (string memory) { return _baseTokenURI; }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value; uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) { digits -= 1; buffer[digits] = bytes1(uint8(48 + uint256(value % 10))); value /= 10; }
        return string(buffer);
    }
}
