// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// Complex Score 200
contract EternalStorage {
    mapping(bytes32 => uint256) private uintStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => bool) private boolStorage;

    function getUint(bytes32 key) public view returns (uint256) {
        return uintStorage[key];
    }

    function setUint(bytes32 key, uint256 value) public {
        uintStorage[key] = value;
    }

    function getAddress(bytes32 key) public view returns (address) {
        return addressStorage[key];
    }

    function setAddress(bytes32 key, address value) public {
        addressStorage[key] = value;
    }

    function getBool(bytes32 key) public view returns (bool) {
        return boolStorage[key];
    }

    function setBool(bytes32 key, bool value) public {
        boolStorage[key] = value;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract ERC721 is IERC721 {
    EternalStorage public _storage;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(EternalStorage storageAddress) {
        _storage = storageAddress;
    }

    function supportsInterface(bytes4 interfaceId) override external pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint256 id) override external view returns (address owner) {
        owner = _storage.getAddress(keccak256(abi.encodePacked("ownerOf", id)));
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) override external view returns (uint256) {
        require(owner != address(0), "owner = zero address");
        return _storage.getUint(keccak256(abi.encodePacked("balanceOf", owner)));
    }

    function isApprovedForAll(address owner, address operator) override external view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("isApproved", owner, operator)));
    }

    function setApprovalForAll(address operator, bool approved) override external {
        _storage.setBool(keccak256(abi.encodePacked("isApproved", msg.sender, operator)), approved);
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function approve(address spender, uint256 id) override external {
        address owner = _storage.getAddress(keccak256(abi.encodePacked("ownerOf", id)));
        require(msg.sender == owner || _storage.getBool(keccak256(abi.encodePacked("isApproved", owner, msg.sender))), "not authorized");

        _storage.setAddress(keccak256(abi.encodePacked("approvals", id)), spender);
        emit Approval(owner, spender, id);
    }

    function getApproved(uint256 id) override external view returns (address) {
        require(_storage.getAddress(keccak256(abi.encodePacked("ownerOf", id))) != address(0), "token doesn't exist");
        return _storage.getAddress(keccak256(abi.encodePacked("approvals", id)));
    }

    function _isApprovedOrOwner(address owner, address spender, uint256 id) internal view returns (bool) {
        return (spender == owner || _storage.getBool(keccak256(abi.encodePacked("isApproved", owner, spender))) || spender == _storage.getAddress(keccak256(abi.encodePacked("approvals", id))));
    }

    function transferFrom(address from, address to, uint256 id) override public {
        require(from == _storage.getAddress(keccak256(abi.encodePacked("ownerOf", id))), "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _storage.setUint(keccak256(abi.encodePacked("balanceOf", from)), _storage.getUint(keccak256(abi.encodePacked("balanceOf", from))) - 1);
        _storage.setUint(keccak256(abi.encodePacked("balanceOf", to)), _storage.getUint(keccak256(abi.encodePacked("balanceOf", to))) + 1);
        _storage.setAddress(keccak256(abi.encodePacked("ownerOf", id)), to);

        _storage.setAddress(keccak256(abi.encodePacked("approvals", id)), address(0));

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) override external {
        transferFrom(from, to, id);

        require(to.code.length == 0 || IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") == IERC721Receiver.onERC721Received.selector, "unsafe recipient");
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) override external {
        transferFrom(from, to, id);

        require(to.code.length == 0 || IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) == IERC721Receiver.onERC721Received.selector, "unsafe recipient");
    }

    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address");
        require(_storage.getAddress(keccak256(abi.encodePacked("ownerOf", id))) == address(0), "already minted");

        _storage.setUint(keccak256(abi.encodePacked("balanceOf", to)), _storage.getUint(keccak256(abi.encodePacked("balanceOf", to))) + 1);
        _storage.setAddress(keccak256(abi.encodePacked("ownerOf", id)), to);

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal {
        address owner = _storage.getAddress(keccak256(abi.encodePacked("ownerOf", id)));
        require(owner != address(0), "not minted");

        _storage.setUint(keccak256(abi.encodePacked("balanceOf", owner)), _storage.getUint(keccak256(abi.encodePacked("balanceOf", owner))) - 1);

        _storage.setAddress(keccak256(abi.encodePacked("ownerOf", id)), address(0));
        _storage.setAddress(keccak256(abi.encodePacked("approvals", id)), address(0));

        emit Transfer(owner, address(0), id);
    }
}

contract MyNFT is ERC721 {
    constructor(EternalStorage storageAddress) ERC721(storageAddress) {}

    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function burn(uint256 id) external {
        require(msg.sender == _storage.getAddress(keccak256(abi.encodePacked("ownerOf", id))), "not owner");
        _burn(id);
    }
}
