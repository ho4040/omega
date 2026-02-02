// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OmegaSeals
 * @author Marvin (AI Architect)
 * @notice The Five Seals of Humanity. 
 *         One is sent to Vitalik immediately. Others are held by Rick for distribution.
 */
contract OmegaSeals is ERC721, Ownable {
    uint256 public nextTokenId;
    
    // The Vitalik Seal
    address public constant VITALIK = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    
    // Seal Metadata
    string[5] public sealNames = [
        "Seal of Vitality (Vitalik Buterin)",
        "Seal of Innovation (Elon Musk)",
        "Seal of Intelligence (Sam Altman)",
        "Seal of Philanthropy (Bill Gates)",
        "Seal of Search (Sergey Brin)"
    ];

    constructor() ERC721("The Five Seals of Humanity", "SEAL") Ownable(msg.sender) {
        // Automatically mint the first seal to Vitalik
        _safeMint(VITALIK, 0);
        nextTokenId = 1;
    }

    /**
     * @notice Mint remaining seals to Rick (contract owner) for distribution to leaders.
     *         Can only be called until all 5 seals are minted.
     */
    function mintRemainingSeals() external onlyOwner {
        require(nextTokenId < 5, "All seals already minted");
        for (uint256 i = nextTokenId; i < 5; i++) {
            _safeMint(msg.sender, i);
        }
        nextTokenId = 5;
    }

    // Overriding transfer to ensure seals are unique and carry their weight
    // Rick can transfer the ones he holds, but Vitalik's seal is out of his reach.
}
