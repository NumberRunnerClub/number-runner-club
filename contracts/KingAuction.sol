// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
import "abdk-libraries-solidity/ABDKMath64x64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KingAuction is VRFV2WrapperConsumerBase, Ownable {
	// King auction constants
	uint256 constant AUCTION_DURATION = 21 days;
	uint256 public constant END_PRICE = 2 ether;
	uint256 public auctionEndTime;

	address constant link = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
	address constant wrapper = 0x708701a1DfF4f478de54383E49a627eD4852C816;
	bool[2] public kingsInSale = [true, true];

	bool isKingsHandSet = false;

	uint256 kingHandsPrize = 0;
	uint256[10] internal kingHands;
	uint256 public recentRequestId;

	constructor() VRFV2WrapperConsumerBase(link, wrapper) Ownable(msg.sender) {
		auctionEndTime = block.timestamp + AUCTION_DURATION;
	}

	function generateKingHands() public {
		require(!isKingsHandSet, "KA01");
		recentRequestId = requestRandomness(1000000, 3, 10);
		isKingsHandSet = true;
	}

	function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
		require(requestId == recentRequestId, "KA02");
		for (uint i = 0; i < 10; i++) {
			uint256 randomValue = uint256(keccak256(abi.encode(randomWords[i], i)));
			// Ensure the random number is in the range [362, 9999]
			randomValue = (randomValue % 9637) + 362;
			kingHands[i] = randomValue;
		}
	}

	function buyKing(uint256 _color, uint256 value) external onlyOwner returns (bool) {
		require(block.timestamp <= auctionEndTime);
		require(kingsInSale[_color - 1]);
		uint256 currentPrice = getCurrentPrice();
		require(value >= currentPrice);
		kingHandsPrize += value;
		kingsInSale[_color - 1] = false;
		return true;
	}

	function getCurrentPrice() public view returns (uint256) {
		uint256 ts = block.timestamp;
		if (ts >= auctionEndTime) {
			return END_PRICE; // scale to match the precision
		} else {
			uint256 timeElapsed = ts - (auctionEndTime - AUCTION_DURATION);
			int128 _secondsElapsed = ABDKMath64x64.fromUInt(timeElapsed);
			int128 _secondsInDay = ABDKMath64x64.fromUInt(60 * 60 * 24);
			int128 _days = ABDKMath64x64.div(_secondsElapsed, _secondsInDay);
			int128 x64x64 = _days;

			int128 negOneThird = ABDKMath64x64.divi(-100, 158);
			int128 one = ABDKMath64x64.fromUInt(1);

			int128 innerCalculation = ABDKMath64x64.add(ABDKMath64x64.mul(negOneThird, x64x64), one);

			int128 result = ABDKMath64x64.exp_2(innerCalculation);

			uint256 resultUint = ABDKMath64x64.toUInt(ABDKMath64x64.mul(result, ABDKMath64x64.fromUInt(1e18))) * 10000;

			if (resultUint < END_PRICE) {
				resultUint = END_PRICE;
			}

			return resultUint;
		}
	}

	function revealKingHand(uint256 tokenId) external view onlyOwner returns (bool) {
		bool isKingsHand = false;
		for (uint i = 0; i < 10; i++) {
			if (tokenId == kingHands[i]) {
				isKingsHand = true;
				break;
			}
		}
		return isKingsHand;
	}

	function claimKingHand() external view returns (uint256) {
		uint256 pieceShare = kingHandsPrize / 10;
		return pieceShare;
	}
}