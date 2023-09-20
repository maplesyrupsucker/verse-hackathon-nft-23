// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyNFT is ERC1155, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => mapping(address => bool)) private _allowlists;
    mapping(uint256 => mapping(address => bool)) private _minted; // New mapping to keep track of who has minted
    mapping(uint256 => uint256) private _totalSupply;
    mapping(uint256 => string) private _tokenURIs;

    ERC20 public token;

    uint256 public constant GRAND_PRIZE = 0;
    uint256 public constant RUNNER_UP = 1;
    uint256 public constant PARTICIPANT = 2;
    uint256 public constant GOLDEN_PEPE = 3;

    constructor() ERC1155("https://versehackers.xyz/tokens/") {
        _setupRole(MINTER_ROLE, _msgSender());
        token = ERC20(0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc); // Initial token address
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
        for (uint i = 0; i < accounts.length;) {
            _allowlists[id][accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }

    function removeFromAllowlist(uint256 id, address account) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to remove from allowlist");
        _allowlists[id][account] = false;
    }

    function mint(address account, uint256 id, bytes memory data) public {
        uint256 amount = 1000;
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to mint");
        require(_allowlists[id][account], "Account is not on the allowlist for this token");
        require(_minted[id][account] == false, "Account has already minted this token"); // Check if the account has already minted the token
        require(token.transferFrom(account, address(this), amount), "Must transfer required amount of tokens to mint");
        _mint(account, id, 1, data);
        _totalSupply[id] += 1;
        _minted[id][account] = true; // Record that this account has minted the token
    }

    function totalSupply(uint256 id) public view returns (uint256) {
        return _totalSupply[id];
    }

    function setTokenAddress(address newAddress) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to set token address");
        token = ERC20(newAddress);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    function isAllowedToMint(uint256 id, address account) public view returns (bool) {
        return _allowlists[id][account];
    }
}