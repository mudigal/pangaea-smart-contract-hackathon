// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Pangea is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    // Mapping to store a hash of the PDF for each token.
    // The IPFS CID can serve as this hash.
    mapping(uint256 => string) private _metadataCids;

    // Events to track the asset's lifecycle
    event AssetMinted(address indexed owner, uint256 indexed tokenId, string metadataCid);
    event MetadataUpdated(uint256 indexed tokenId, string newMetadataCid, uint256 newVersion);

    constructor()
        ERC721("PangeaAsset", "PANGEA")
        Ownable(msg.sender)
    {}

    /**
     * @dev Mints a new asset and assigns it to the recipient.
     * @param to The recipient of the new asset.
     * @param metadataCid The IPFS CID of the asset's metadata PDF.
     */
    function safeMint(address to, string memory metadataCid) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _metadataCids[tokenId] = metadataCid;
        emit AssetMinted(to, tokenId, metadataCid);
    }

    /**
     * @dev Updates the metadata CID for an existing asset.
     * @param tokenId The ID of the token to update.
     * @param newMetadataCid The new IPFS CID for the asset's metadata.
     */
    function updateMetadata(uint256 tokenId, string memory newMetadataCid) public onlyOwner {
        _metadataCids[tokenId] = newMetadataCid;
        // In a real application, you might want to track versions or events
        emit MetadataUpdated(tokenId, newMetadataCid, 1);
    }

    /**
     * @dev Returns the metadata CID for a given token ID.
     * @param tokenId The ID of the token.
     * @return The IPFS CID of the metadata.
     */
    function getMetadataCid(uint256 tokenId) public view returns (string memory) {
        return _metadataCids[tokenId];
    }

    // The following functions are overrides required by Solidity.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        _requireOwned(tokenId);
        // This could link to an IPFS gateway or a dedicated metadata server
        // For this example, we return the CID directly.
        return _metadataCids[tokenId];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
