pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC721IPFSMintable is ERC721Enumerable, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private baseURI;

    constructor (string memory name, string memory symbol) ERC721(name, symbol) {
        baseURI = "ipfs://";
    }
    
    using Strings for uint256;

    mapping (uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function safeMint(address to, string memory metadataURI) external onlyOwner {
        _safeMint(to, _tokenIds.current());
        _setTokenURI(_tokenIds.current(), metadataURI);
        _tokenIds.increment();
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function updateTokenURI(uint256 tokenId, string memory newTokenURI) public onlyOwner {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _setTokenURI(tokenId, newTokenURI);
    }
}
