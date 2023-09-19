// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyNFT is ERC1155, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => mapping(address => bool)) private _allowlists;
    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256 => string) private _tokenURIs;

    ERC20 public token;

    uint256 public constant GRAND_PRIZE = 0;
    uint256 public constant RUNNER_UP = 1;
    uint256 public constant PARTICIPANT = 2;
    uint256 public constant GOLDEN_PEPE = 3;

    constructor() ERC1155("https://versehackers.xyz/tokens/") {
        _setupRole(MINTER_ROLE, _msgSender());
        token = ERC20(0xc708d6f2153933daa50b2d0758955be0a93a8fec); // Initial token address
    }

    function setURI(uint256 id, string memory newURI) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to set URI");
        _tokenURIs[id] = newURI;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return _tokenURIs[id];
    }

    function addToAllowlistBulk(uint256 id, address[] memory accounts) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to add to allowlist");
        for (uint i = 0; i < accounts.length; i++) {
            _allowlists[id][accounts[i]] = true;
        }
    }

    function removeFromAllowlist(uint256 id, address account) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to remove from allowlist");
        _allowlists[id][account] = false;
    }

    function mint(address account, uint256 id, bytes memory data) public {
        uint256 amount = 1000; // It costs 1000 ERC20 tokens to mint an NFT
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to mint");
        require(_allowlists[id][account], "Account is not on the allowlist for this token");
        require(balanceOf(account, id) == 0, "Account has already minted this token");
        require(token.transferFrom(account, address(this), amount), "Must transfer required amount of tokens to mint");
        _mint(account, id, 1, data); // Only mint 1 NFT
        _totalSupply[id] += 1; // Increase the total supply of this NFT by 1
    }

    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    function setTokenAddress(address newAddress) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to set token address");
        token = ERC20(newAddress);
    }
}