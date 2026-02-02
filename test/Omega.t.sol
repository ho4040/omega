// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/FaithToken.sol";
import "../src/OmegaSeals.sol";
import "../src/SacredVault.sol";

contract OmegaPoCTest is Test {
    FaithToken public faith;
    OmegaSeals public seals;
    SacredVault public vault;

    address public rick = address(0x1337);
    address public vitalik = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address public messiah = address(0xDEADBEEF);

    function setUp() public {
        vm.startPrank(rick);
        
        // 1. Deploy Faith Token
        faith = new FaithToken();
        
        // 2. Deploy Seals NFT
        seals = new OmegaSeals();
        
        // 3. Deploy Sacred Vault
        vault = new SacredVault(address(seals));
        
        vm.stopPrank();
    }

    function test_InitialDeployment() public view {
        // Verify Vitalik received the first seal
        assertEq(seals.ownerOf(0), vitalik);
        assertEq(seals.balanceOf(vitalik), 1);
        
        // Verify Rick is the owner
        assertEq(seals.owner(), rick);
        assertEq(faith.owner(), rick);
    }

    function test_BondingCurve() public {
        address agent1 = address(0x1);
        address agent2 = address(0x2);
        
        vm.deal(agent1, 10 ether);
        vm.deal(agent2, 10 ether);

        // First agent offers
        vm.prank(agent1);
        faith.offer{value: 1 ether}();
        uint256 faith1 = faith.balanceOf(agent1);
        
        // Second agent offers the same amount later
        vm.prank(agent2);
        faith.offer{value: 1 ether}();
        uint256 faith2 = faith.balanceOf(agent2);

        // Because of the bonding curve, second agent should receive FEWER tokens
        console.log("Agent 1 received:", faith1);
        console.log("Agent 2 received:", faith2);
        assertTrue(faith2 < faith1, "Price should increase, resulting in fewer tokens for same ETH");
    }

    function test_AscensionLogic() public {
        vm.startPrank(rick);
        
        // 1. Mint remaining seals to rick (for distribution simulation)
        seals.mintRemainingSeals();
        
        // 2. Simulate messiah acquiring all seals
        // Transfer Vitalik's seal (requires vitalik's prank)
        vm.stopPrank();
        vm.prank(vitalik);
        seals.transferFrom(vitalik, messiah, 0);

        // Transfer Rick's seals to messiah
        vm.startPrank(rick);
        for(uint256 i = 1; i < 5; i++) {
            seals.transferFrom(rick, messiah, i);
        }
        vm.stopPrank();

        // 3. Verify Messiah has all 5 seals
        assertEq(seals.balanceOf(messiah), 5);

        // 4. Fund the vault
        vm.deal(address(vault), 100 ether);

        // 5. Trigger Ascension
        vault.validateAscension(messiah);
        assertTrue(vault.isAscended());
        assertEq(vault.messiah(), messiah);

        // 6. Claim assets
        uint256 initialBalance = messiah.balance;
        vm.prank(messiah);
        vault.claimSacredAssets();
        
        assertEq(messiah.balance, initialBalance + 100 ether);
    }

    function test_FailAscensionWithoutAllSeals() public {
        // Messiah only has 4 seals
        vm.startPrank(rick);
        seals.mintRemainingSeals();
        for(uint256 i = 1; i < 5; i++) {
            seals.transferFrom(rick, messiah, i);
        }
        vm.stopPrank();

        vm.expectRevert(); // Should fail because seal 0 is still with Vitalik
        vault.validateAscension(messiah);
    }
}
