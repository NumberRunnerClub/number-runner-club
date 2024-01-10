# Number Runner Club

The project is an innovative exploration of strategies inherent to short digital
Ethereum domains. It aims to recognize and value the diversity and significance of
these addresses. This NFT collection is for those who appreciate the strategic
nuances the game symbolizes and the underlying value of the ENS domains.

**Project Description:** Drawing inspiration from the strategies of the game of chess,
the project offers a unique NFT collection that values ENS addresses in figures in
various ways. Just as every chess piece has its own value and importance in the
game, each ENS address has a unique intrinsic value in the blockchain. This initiative
is shaped for a community that not only recognizes but deeply values ENS domains.
By emphasizing strategy and intrinsic value, the project seeks the participation of all
those who foresee the immense potential of these addresses, all in a collaborative
spirit.

🌟 **Features :**

**Users :**

- Check the current price of a chess piece.
- Verify the expiration date of a specific domain.
- Claim specific rewards associated with a particular chess piece.
- Purchase NFTs that are put up for sale by other users.
- Verify specific details such as shares, color associated with a user, the token
  ID of a node, etc.

**Owner/Creator:**

- Mint chess kings, both in black and white.
- Update shares based on fees.
- Update unclaimed rewards associated with a specific piece type.
- Adjust the price of the NFTs.
- Manage the sale of NFTs, including determining their availability for sale.

The contract also manages a prize pool that is distributed among the holders of
certain chess pieces based on various criteria.
Users can claim their share of this prize pool based on their rights and the rules
established in the contract. Mechanisms such as fees and other rewards are also managed through the contract.

## Libraries & Dependencies

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "abdk-libraries-solidity/ABDKMath64x64.sol";
import "@ensdomains/ens-contracts/contracts/ethregistrar/BaseRegistrarImplementation.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
```

**Description :**

- **ABDKMath64x64.sol:** This library provides mathematical operations for
  fixed-point numbers, allowing for precise calculations.
- **BaseRegistrarImplementation.sol:** This library is tied
  to the Ethereum Name Service (ENS) system, which is a naming service for
  translating complex Ethereum addresses into human-readable names.
- **ERC721URIStorage.sol:** This is an extension of the ERC721 standard that
  allows for storing URIs, links to resources, for each NFT.
- **VRFV2WrapperConsumerBase.sol:** Provides access to random numbers for
  the contract, essential for certain game mechanics.
- **Ownable.sol:** This module defines basic functions for owner management,
  which is useful for administrative operations.
- **Strings.sol** and ReentrancyGuard.sol: These libraries provide utilities for
  manipulating strings and mechanisms to prevent reentrancy attacks,
  respectively.

## Declarations & Initializations

### Inheritance and Use of Libraries

```
contract KingAuction is VRFV2WrapperConsumerBase, Ownable {
```

**Description :**

- **KingAuction is VRFV2WrapperConsumerBase, Ownable:**The KingAuction
  contract inherits from VRFV2WrapperConsumerBase and Ownable. This
  means that KingAuction inherits the properties and functions of these
  contracts.
- **VRFV2WrapperConsumerBase:** This contract is used to obtain random
  numbers in a secure manner.
- **Ownable:** Provides basic mechanisms to manage a contract with an owner.

### State Variables

```
uint256 constant AUCTION_DURATION = 21 days;
uint256 public constant END_PRICE = 2 ether;
uint256 auctionEndTime;

address constant link = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
address constant wrapper = 0x708701a1DfF4f478de54383E49a627eD4852C816;
bool[2] public kingsInSale = [true, true];

bool isKingsHandSet = false;

uint256 kingHandsPrize = 0;
uint256[10] internal kingHands;
uint256 public recentRequestId;
```

**Description :**

- **auctionEndTime:** The timestamp for the auction's end.
- **AUCTION_DURATION:** Total duration of the auction in seconds.
- **END_PRICE:** The minimum price required to participate in the auction.
- **kingsInSale:** A boolean array indicating the availability of "kings" for
  purchase. Each element of the array represents a "king" color and its
  availability.
- **isKingsHandSet:** An indicator to check if the "King's Hands" have been
  generated.
- **kingHandsPrize:** Total amount of funds intended to be distributed among the
  "King's Hands".
- **kingHands:** An internal array containing the identifiers of the "King's Hands".
- **recentRequestId:** Stores the ID of the last request for random numbers.

## “Constructor” function

```
constructor() VRFV2WrapperConsumerBase(_link,
_vrfCoordinator) Ownable(msg.sender) {
auctionEndTime = block.timestamp + AUCTION_DURATION;
}
```

**Description :** Upon creation (deployment) of the KingAuction contract, the
constructor is called.

## “generateKingHands” function

```
function generateKingHands() public {
require(!isKingsHandSet, "KA01");
		recentRequestId = requestRandomness(1000000, 3, 10);
		isKingsHandSet = true;
}
```

**Description :** The requestRandomness function is used in conjunction with
Chainlink's VRF (Verifiable Random Function) to obtain random numbers on the
blockchain in a manner that can be verified for its authenticity. The random numbers obtained in this way are deemed secure against tampering.

- **10000000:** This pertains to a request for a random number.
- **3:** Block validation
- **10:** This indicates the number of random words we wish to obtain.
  Once the random value is obtained, it is assigned to the state variable
  recentRequestId. This variable is then used to ensure that the random response
  received matches the request when executing the fulfillRandomWords function.

**Preliminary Checks:**

- **require(!isKingsHandSet, "King's Hands already generated");** ensures
  that the King's Hands haven't already been generated.

## “fulfillRandomWords” function

```
function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
internal override {
require(requestId == recentRequestId, "KA02");
		for (uint i = 0; i < 10; i++) {
			uint256 randomValue = uint256(keccak256(abi.encode(randomWords[i], i)));
			// Ensure the random number is in the range [362, 9999]
			randomValue = (randomValue % 9637) + 362;
			kingHands[i] = randomValue;
		}
}
```

**Description :** This function is a callback function meant to be called by the
Chainlink VRF (Verifiable Random Function) service to provide the random numbers
requested by the generateKingHands function.

**Preliminary Checks:**

- **require(requestId == recentRequestId, "Wrong request ID");** ensures that
  the request ID matches the recent request ID stored during the call to
  generateKingHands.

**Random Words Processing Logic:**

- The function processes the random words received and generates 10 unique
  numbers to represent the "King's Hands". Here are the steps:
- For each random word, it's first hashed with keccak256 with its index to obtain
  a deterministic random value.
- This random value is then constrained to a specific range ([362, 9999]) to
  ensure it falls within a desired range.
- Next, there's a check to ensure this value hasn't already been picked. If it's
  unique, it's added to the kingHands array.
- If 10 unique numbers have been found, the loop is exited.


In summary, this function is called by the Chainlink VRF service to provide random numbers. These numbers are then processed to generate 10 unique identifiers for the "King's Hands".

## “buyKing” function

```
function buyKing(uint256 _color, uint256 value) external payable returns (bool) {
require(block.timestamp <= auctionEndTime);
require(kingsInSale[_color - 1]);
uint256 currentPrice = getCurrentPrice();
require(value >= currentPrice);
kingHandsPrize += value;
kingsInSale[_color - 1] = false;
return true;
}
```

**Description :** The buyKing function enables a user to purchase a king based on
its color by placing a bid for its purchase.

**Parameters:**
- **\_color:** This is a numeric identifier representing the color of the king the user
  wishes to purchase.
- **value:** This is the amount the user is willing to pay for the king.

**Functionality:**

- The function first checks that the current time (or current block) is before the
  end of the auction using the condition require(block.timestamp <=
  auctionEndTime, "Auction already ended."). If this is not the case, the function
  fails, returning a message indicating the auction has ended.
- It then checks if the king of the specified color is still for sale using
  kingsInSale[_color - 1]. If the king isn't for sale, the function fails with the
  message "This king's color is already sold".
- The function fetches the current required price for purchasing the king using
  the getCurrentPrice() function.
- It then checks if the value provided by the user is at least equal to the
  currentPrice. If not, it fails with the message "The bid is too low.".
- If all the conditions are met, a KingBought event is emitted, indicating the user
  (represented by msg.sender) has bought the king for the value value and the
  color \_color.
- The value paid by the user is added to the kingHandsPrize variable.
- The king of the specified color is marked as sold by setting kingsInSale[\_color - 1] to false.

- The function returns true, indicating the purchase was successfully executed.

## “getCurrentPrice” function

```
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
```

**Description :** This function computes and returns the current price of a king in the
auction based on the time elapsed since the start of the auction.

**Price Determination Logic:**

- **uint256 ts = block.timestamp;**: Retrieves the current timestamp of the block.
- **if (ts >= auctionEndTime) { return minPrice \* 1e18; }:** If the auction has
  ended, the price is set to the minimum price (scaled to match precision).
- **uint256 timeElapsed = ts - (auctionEndTime - auctionDuration);:**
  Calculates the time elapsed since the start of the auction.
- The following lines convert this elapsed time into days, using the
  ABDKMath64x64 library to conduct high-precision mathematical operations.
  The formula used is a decreasing exponential based on the elapsed time in
  days.

**Outcome:** The function returns the calculated current price.

In summary, this function employs an exponential formula based on the time elapsed
since the start of the auction to determine the current price of a king. The price
decreases over time, potentially encouraging higher bids at the start of the auction.
Once the auction concludes, the price is set to a predetermined minimum value.

## “revealKingHand” function

```
function revealKingHand(uint256 tokenId) external view returns (bool) {
bool isKingsHand = false;
for (uint i = 0; i < 10; i++) {
if (tokenId == kingHands[i]) {
isKingsHand = true;
break;
}
}
return isKingsHand;
}
```

**Description :** This function checks if a given tokenId is one of the specially
generated "King's Hands."
**Main Logic:**

- **bool isKingsHand = false;:** Initializes a variable to check whether the
  tokenId is a "King's Hand" or not.
- The for loop iterates over the kingHands array, which contains the special
  tokenIds generated earlier.
- **if (tokenId == kingHands[i]):** If the provided tokenId matches any of the
  tokenIds in the kingHands array, the isKingsHand variable is set to true, and
  the loop breaks.

**Outcome:** The function returns true if the provided tokenId is a "King's Hand",
otherwise false.

This function is useful for users who want to verify whether a tokenId they own or
see is one of the special "King's Hands" tokenIds. These tokenIds likely have some
unique value or significance within the context of the contract.

## “claimKingHand” function & close “KingAuction” contract

```
function claimKingHand(uint256 tokenId) public returns (uint256) {
require(tokenId > 0, "Token id must be strictly positive");
uint256 i = 0;
bool isKingHand = false;
for (i; i < 10; i++) {
if (tokenId == kingHands[i]) {
isKingHand = true;
break;
}
}
require(isKingHand, "Token must be a King's Hand");
uint256 pieceShare = kingHandsPrize / 10;
require(pieceShare > 0, "Incorrect Piece Share");
kingHands[i] = 0;
return pieceShare;
}
}
```

**Description :** This function allows a user to claim a share of the treasure (or
prize) associated with a "King's Hand" if they hold a tokenId identified as one of the
"King's Hands."

**Main Logic:**

- require(tokenId > 0, "Token id must be strictly positive");: Ensures the
  provided tokenId is strictly positive. This is probably a check to avoid invalid or
  non-existent tokenIds.
- A for loop then iterates over the list of kingHands to see if the provided
  tokenId matches any in the list.
- If the tokenId is found within the kingHands list, isKingHand is set to true, and
  the loop is exited.
- require(isKingHand, "Token must be a King's Hand");: This line ensures that
  the provided tokenId is indeed a "King's Hand". If it isn't, the transaction is
  reverted.
- uint256 pieceShare = kingHandsPrize / 10;: Calculates the user's share of the
  treasure by dividing the total treasure (kingHandsPrize) by 10, given there are
  10 distinct "King's Hands."
- require(pieceShare > 0, "Incorrect Piece Share");: An additional check to
  make sure the calculated share is a valid amount.
- kingHands[i] = 0;: Nullifies the tokenId of the "King's Hand" that has just been
  claimed, ensuring it cannot be claimed again.

**Outcome:** The function returns the pieceShare, which is the portion of the treasure
the user receives for successfully claiming the "King's Hand."

In summary, this function is crucial for allowing holders of "King's Hands" to claim
their associated reward. By doing so, they receive a portion of the total treasure
accrued within the contract.

## “NumberRunnerClub” contract

```
contract NumberRunnerClub is ERC721URIStorage, Ownable, ReentrancyGuard {
event NFTPurchased(address buyer, address seller, uint256 tokenId, uint256
price);
event KingBought(address buyer, uint256 price, uint256 tokenId, string ensName);
event ColorChoosed(uint8 color, address user);
event NFTListed(address seller, uint256 tokenId, uint256 price);
event NFTUnlisted(address seller, uint256 tokenId, uint256 price);
event KingHandBurned(uint256 tokenId);
event NFTBurned(address owner, uint256 tokenId);
event NFTMinted(address owner, uint256 tokenId);
event globalSharesUpdated(uint256[6] shares);
event nftSharesUpdated(uint256 tokenId, uint256 shares);
event NFTStacked(uint256 tokenId, bytes32 ensName);
event NFTUnstacked(uint256 tokenId, bytes32 ensName);
event UpdateUnclaimedRewards(uint256 tokenId, uint256 rewards);
event KingHandRevealed(bool success);
event NFTKilled(uint256 tokenId);
uint256 constant ONE_WEEK = 1 weeks;
```

The NumberRunnerClub contract is a subtype of the ERC721URIStorage, Ownable,
and ReentrancyGuard contracts. These parent contracts provide the
NumberRunnerClub with a set of functionalities:

- **ERC721URIStorage:** Allows the contract to implement the ERC721 standard
  for non-fungible tokens (NFTs) and manage the storage of token URIs. A URI
  points to a JSON file that describes the attributes of the NFT.
- **Ownable:** It's a smart contract design pattern that restricts certain
  functionalities to be executed only by the owner of the contract.
- **ReentrancyGuard:** Provides a modifier to guard methods against the
  reentrancy attack. This attack occurs when a contract function is recursively
  called before the function completes its execution.

**Events:**

- **NFTPurchased:** Emitted when an NFT is purchased.
- **KingBought:** Emitted when a King is bought from King Auction
- **ColorChoosed:** Emitted when a user selects a color (perhaps for
  customization).
- **NFTListed:** Emitted when an NFT is listed for sale.
- **NFTUnlisted:** Emitted when an NFT is delisted from sale.
- **KingHandBurned:** Emitted when a "King's Hand" NFT is burned.
- **NFTBurned:** Emitted when an NFT is burned.
- **NFTMinted:** Emitted when a new NFT is minted.
- **globalSharesUpdated:** Emitted when the shares associated with all NFTs
  are updated.
- **nftSharesUpdated:** Emitted when the shares of a specific NFT are updated.
- **NFTStacked:** Emitted when an NFT is linked to an ENS (Ethereum Name
  Service) name.
- **NFTUnstacked:** Emitted when an NFT is unlinked.
- UpdateUnclaimedRewards: Emitted when the unclaimed rewards of a
  specific NFT are updated.
- **KingHandRevealed:** Emitted when a "King's Hand" NFT is revealed.
- **NFTKilled:** Emitted when an NFT is "killed" (perhaps another form of
  destruction besides burning).

**Constants:**

- **ONE_WEEK:** A constant value representing the duration of one week, used
  for timing or scheduling purposes.

This contract is related to the management of NFTs, including their creation, listing
for sale, purchasing, and various other interactions.

## “PieceDetails” structure

```
struct PieceDetails {
uint256 maxSupply;
uint256 totalMinted;
uint256 blackMinted;
uint256 whiteMinted;
uint256 percentage;
uint256 burnTax;
uint256 startingId;
uint256 clubRequirement;
uint256 burnRequirement;
uint256 opponentColorBurnRequirement;
bool palindromeClubRequirement;
}
```

**Description :**
The "PieceDetails" structure represents the details of a "piece". Each field has a
specific meaning:

- **maxSupply:** This refers to the maximum quantity of this piece that can exist.
  It's the upper limit of the number of these pieces that can be minted.
- **totalMinted:** The total number of these pieces that have already been minted.
- **blackMinted:** The number of these pieces in black color that have been
  minted.
- **whiteMinted:** The number of these pieces in white color that have been
  minted.
- **percentage:** This field represents a percentage associated with the piece,
  related to a commission rate.
- **burnTax:** Fee or percentage that is taken when a piece is burned.
- **startingId:** The initial identifier (ID) from which pieces of this type start to be
  numbered.
- **clubRequirement:** A field indicating a certain criterion or minimum number
  required for a piece to belong to or be associated with a "club".
- **burnRequirement:** A field indicating the number or percentage of pieces that
  need to be burned to perform a certain action or gain a certain advantage.
- **opponentColorBurnRequirement:** This field indicates the number or
  percentage of pieces of the opposite color that need to be burned to perform a
  certain action or gain a certain advantage.
- **palindromeClubRequirement:** Indicates if a specific condition related to a
  "Palindrome Club" is required. To stack a tower, one must either have a 3-digit
  address or a 4-digit palindrome.

This structure is used to define the properties and rules associated with a particular
piece within the contract. It might be used to manage different types or editions of
NFTs in the contract, each with its own rules and characteristics.

## Key Aspects of the Contract

```
KingAuction public kingAuction;
uint256 public constant MAX_NFT_SUPPLY = 10000;
uint256 public totalMinted = 0;
uint256 public currentSupply = 0;
uint256 public userStacked = 0;
uint256 public currentEpoch = 0;
// King auction constants
uint256 public constant auctionDuration = 21 days;
uint256 public constant minPrice = 2 ether;
uint256 public constant maxPrice = 20000 ether;
uint256 public auctionEndTime;
uint256 public epoch = 0;
uint256 prizePool;
```

**Description :**

- **kingAuction:** This is a public variable of type KingAuction, a reference or an
  instance of the auction contract for Kings (KingAuction).
- **MAX_NFT_SUPPLY:** A constant that indicates the maximum number of NFTs
  (non-fungible tokens) that can be created for this contract. Here, the limit is
  set to 10,000 NFTs.
- **totalMinted:** This variable keeps track of the total number of NFTs that have
  been created (or minted) so far.
- **currentSupply:** This variable represents the current number of NFTs in
  circulation. This could be different from totalMinted if some NFTs have been
  destroyed (or burned).
- **userStacked:** This is the number of NFTs currently "stacked" (pledged or
  locked) by users.
- **currentEpoch:** The current epoch (or era). An epoch is a specific period of
  time or phase in a given context.
- **auctionDuration:** A constant that defines the total duration of the auction.
  Here, it is set to 21 days.
- **minPrice:** The minimum price for an auction, set at 2 ethers.
- **maxPrice:** The maximum price for an auction, set at 20,000 ethers.
- **auctionEndTime:** The date/time at which the auction ends.
- **prizePool:** This field represents a prize pool or a set of rewards that will be
  distributed to certain participants or winners.

These variables provide essential information and manage key aspects of the
contract, such as auction duration, prices, and the quantity of NFTs.

## Variables & Mappings

```
BaseRegistrarImplementation public baseRegistrar;
mapping(uint256 => bytes32) public nodeOfTokenId; // Mapping of tokenId to
the corresponding ENS hash
mapping(bytes32 => uint256) public tokenIdOfNode; // Mapping of ENS hash
to the corresponding tokenId
mapping(uint256 => bytes32) public nameOfTokenId; // Mapping of tokenId to
the corresponding ENS name
mapping(uint256 => uint256) private _unstakeTimestamps;
mapping(uint256 => uint256) public expiration;
mapping(address => uint256) private _killFeeDebt;
PieceDetails[6] pieceDetails;
uint256[6] private typeStacked;
// The total sum of all the sharePerTokenAtEpoch for each type of coin.
uint256[][6] shareTypeAccumulator;
// Le sharePerToken de l'utilisateur à l'epoch où il a stacké son dernier token
mapping(uint256 => uint256) nftShares;
mapping(uint256 => uint256) public unclaimedRewards; // Mapping des
récompenses non claim associées au nft
mapping(address => uint8) public userColor; // Mapping of user address to
chosen color
mapping(address => uint256) private burnedCount; // Mapping of user
address to counter of nft burned
mapping(address => uint256) private burnedCounterCount; // Mapping of user
address to counter of nft from the opponent color burned
mapping(uint256 => bool) public hasClaimedGeneral;
mapping(uint256 => uint256) public nftPriceForSale;
```

**Description :**

- baseRegistrar: This is a reference to the base registrar implementation of the
  ENS. The registrar is the contract that handles the allocation, transfer, and
  claiming of names.
- nodeOfTokenId: A mapping that links a tokenId (token identifier) to a
  corresponding ENS hash.
- tokenIdOfNode: The inverse of the previous mapping. It links an ENS hash to
  a corresponding tokenId.
- nameOfTokenId: A mapping linking a tokenId to a corresponding ENS name.
- \_unstakeTimestamps: This mapping associates a tokenId with a timestamp
  which, I presume, indicates when this token was "unstacked" or withdrawn.
- expiration: A mapping associating a tokenId with its expiration date.
- \_killFeeDebt: This mapping tracks a certain debt or obligation associated with
  the "kill" action for a given address.
- pieceDetails: A fixed array that stores details of 6 different types of coins.
- typeStacked: A private fixed array that tracks the number of each type of coin
  that is currently "stacked" or locked.
- shareTypeAccumulator: A two-dimensional array that tracks a cumulative sum
  for each type of coin.
- nftShares: A mapping that associates a tokenId with the number of shares it
  represents at a given epoch.
- unclaimedRewards: Links a tokenId to the amount of unclaimed rewards
  associated with that NFT.
- userColor: Associates a user address with a chosen color.
- burnedCount & burnedCounterCount: These two mappings track the number
  of NFTs burned by an address. The latter tracks the number of NFTs of the
  opposing color that have been burned by an address.
- hasClaimedGeneral: A mapping to check whether a specific tokenId has
  already claimed a general reward or not.
- nftPriceForSale: This mapping associates a tokenId with its selling price if it is
  listed for sale.

These variables and mappings enable the management of key aspects of the
contract related to ENS, NFTs, their properties, their statuses, their rewards, etc.

## Initializations & Instances

```
constructor(address _ens, address _baseRegistrar, address _vrfCoordinator,
address _link) ERC721("NumberRunnerClub", "NRC") {
pieceDetails[0] = PieceDetails(2, 0, 0, 0, 2, 0, 0, 3, 0, 0, false);
pieceDetails[1] = PieceDetails(10, 0, 0, 0, 1, 15, 2, 3, 15, 15, false);
pieceDetails[2] = PieceDetails(50, 0, 0, 0, 1, 15, 12, 4, 15, 15, true);
pieceDetails[3] = PieceDetails(100, 0, 0, 0, 1, 15, 62, 4, 10, 10, false);
pieceDetails[4] = PieceDetails(200, 0, 0, 0, 1, 15, 162, 4, 10, 0, false);
pieceDetails[5] = PieceDetails(9638, 0, 0, 0, 8, 20, 362, 5, 0, 0, false);
baseRegistrar = BaseRegistrarImplementation(_baseRegistrar);
prizePool = 0;
for (uint8 i = 0; i < 6; i++) {
shareTypeAccumulator[i].push(1);
}
epoch += 1;
for (uint8 i = 0; i < 6; i++) {
shareTypeAccumulator[i].push(shareTypeAccumulator[i][epoch - 1]);
}
// Emit shares event
uint256[6] memory currentShares;
for (uint8 i = 0; i < 6; i++) {
currentShares[i] = shareTypeAccumulator[i][epoch];
}
emit globalSharesUpdated(currentShares);
spawnKings();
auctionEndTime = block.timestamp + auctionDuration;
kingAuction = new KingAuction(auctionEndTime, auctionDuration, minPrice,
_vrfCoordinator, _link);
}
```

**Description :**
The constructor of this contract is used to initialize important values and
configurations upon creation (deployment) of the contract on the Ethereum
blockchain.

**Constructor parameters:**

- **ERC721("NumberRunnerClub", "NRC"):** The contract inherits from
  ERC721, which is a standard for non-fungible tokens (NFTs) on Ethereum.
  The ERC721 constructor takes the name ("NumberRunnerClub") and the
  symbol ("NRC") of the token as arguments.
- **Initialization of coin details (pieceDetails):** These are initial configurations
  for different coins. Each coin has different details such as the total number of
  copies, percentage, burn requirements, etc.
- **Initialization of ENS and base registrar:** This configures the ENS services
  for the contract with the provided addresses.
- **Initialization of prizePool:** It is initially set to zero.
- **Initialization of shareTypeAccumulator:** This loop initializes an array that
  tracks a cumulative sum of shares for each type of coin.
- **Update of the epoch:** The epoch is increased by 1, and the
  shareTypeAccumulator is updated accordingly. Then, an event is emitted to
  signal that shares have been updated.
- **Calling the function spawnKings():** This is a function that initializes or
  spawns a certain number of kings within the contract.
- **Setting the auction's end:** The auction's end is defined as the current
  moment (block.timestamp) plus the auction duration.
- **Creation of a new auction for the king:** A new instance of the KingAuction
  contract is created with various parameters such as the auction's end time, its
  duration, the minimum price, and the addresses associated with Chainlink
  VRF.

This constructor readies the contract to operate properly by initializing all essential
values and creating instances of other necessary contracts.

## Preconditions

```
modifier saleIsActive() {
require(currentSupply + MAX_NFT_SUPPLY - totalMinted > 999, "Collection
ended");
_;
}
modifier saleIsNotActive() {
require(!(currentSupply + MAX_NFT_SUPPLY - totalMinted > 999),
"Collection not ended");
_;
}
```

**Description :**
These two pieces of code are "modifiers" in Solidity, which are used to add
preconditions to functions that use them. In other words, before the function's code is
executed, the modifier's code is run first, and if it passes (meaning all the requires
are met), then the function's code is executed.

- modifier saleIsActive(): This modifier ensures that the NFT sale is still
  ongoing. The logic here is to make sure that the difference between
  MAX_NFT_SUPPLY and totalMinted added to currentSupply is greater than 999. If not, the transaction will fail with the error message "Collection ended".

- modifier saleIsNotActive(): Contrary to the first, this modifier ensures that the
  NFT sale is NOT ongoing. If the active sale condition is true (meaning the sale
  is still happening), then it will return an error "Collection not ended".

When a function employs one of these modifiers, it ensures that the sale is either
active or not active, before allowing the function to execute.

## “Multimint” function

```
function multiMint(uint256 _n) external payable {
		require(_n > 0);
		require(userColor[msg.sender] == 1 || userColor[msg.sender] == 2, "NRC03");
		if (userColor[msg.sender] == 1) {
			require(pieceDetails[5].blackMinted + _n <= pieceDetails[5].maxSupply / 2, "NRC04");
		} else {
			require(pieceDetails[5].whiteMinted + _n <= pieceDetails[5].maxSupply / 2, "NRC04");
		}
		uint256 startId = userColor[msg.sender] == 1 ? 2 + 2 * pieceDetails[5].blackMinted : 3 + 2 * pieceDetails[5].whiteMinted;
		uint256 mintCount = _n;

		if (!hasClaimedFreeMint[msg.sender] && freeMintCounter < 100) {
			hasClaimedFreeMint[msg.sender] = true;
			freeMintCounter++;
			mintCount = _n - 1;
		}

		if (mintCount > 0) {
			require(msg.value >= 50000000000000000 * mintCount, "NRC05");
		}

		for (uint8 i = 0; i < _n; i++) {
			uint256 newItemId = startId + 2 * i;
			_mint(msg.sender, newItemId);
			_setTokenURI(newItemId, string(abi.encodePacked("ipfs://QmceFYj1a3xvhuwqb5dNstbzZ5FWNfkWfiDvPkVwvgfQpm/NumberRunner", newItemId.toString(), ".json")));
			pieceDetails[5].totalMinted++;
			unclaimedRewards[newItemId] = 0;
			nftShares[newItemId] = 0;
			_unstakeTimestamps[newItemId] = block.timestamp;
			expiration[newItemId] = 0;
			userColor[msg.sender] == 1 ? pieceDetails[5].blackMinted++ : pieceDetails[5].whiteMinted++;
			totalMinted++;
			currentSupply++;
			if (i < mintCount) {
				prizePool += 12500000000000000;
				// Add the transaction fee to the piece's balance
				updateShareType(12500000000000000);
			}

			emit NFTMinted(msg.sender, newItemId);
		}

		if (mintCount > 0) {
			payable(NRC).transfer(25000000000000000 * mintCount);
		}
	}
```

**Description :** The multiMint function allows a user to create ("mint") multiple NFT
tokens at once.

**Pre-checks:**

- ETH value check: The user must send at least \_n \* 0.05 ETH to create \_n
  tokens.
- Chosen color check: The user must have chosen a color (1 for black or 2 for
  white) before being able to create a token.
- Total pawn quantity check: Ensures the total number of pawns being created
  does not exceed the allowed maximum for this type.
- Quantity by color check: Ensures the number of created black or white pawns
  doesn't exceed half of the allowed maximum.

**Determination of starting ID:**

- Based on the color chosen by the user, a starting ID is calculated for the token
  creation.
- Token creation:
- A loop runs through the \_n number of tokens to be created. For each iteration:

**A new ID is determined.**

- The token is created and assigned to the user.
- An URI (address) for the token is set, pointing to an IPFS resource.
- Various counters and states are updated, such as the total number of pawns
  created, the number of black/white pawns, and reward tracking.
- If no pawn is currently "stacked", a portion of the fees is added to the
  prizePool.
- Transaction fees are added to the pawn balance.
- An NFTMinted event is emitted to notify of the token's creation.

In summary, this function allows a user to create multiple NFT pawns in a single
transaction, ensuring rules regarding payment, chosen color, and quantity limits are
adhered to.\

## “Mint” function

```
function mint(uint8 _pieceType, uint256 _stackedPiece) external payable {
		require(msg.value >= 50000000000000000, "NRC05");
		require(userColor[msg.sender] == 1 || userColor[msg.sender] == 2, "NRC03");
		if (userColor[msg.sender] == 1) {
			require(pieceDetails[_pieceType].blackMinted <= pieceDetails[_pieceType].maxSupply / 2, "NRC04");
		} else {
			require(pieceDetails[_pieceType].whiteMinted <= pieceDetails[_pieceType].maxSupply / 2, "NRC04");
		}

		// Set the id of the minting token from the type and color of the piece chosen
		// Black token have even id
		// White token have odd id
		uint256 newItemId = userColor[msg.sender] == 1 ? pieceDetails[_pieceType].startingId + 2 * pieceDetails[_pieceType].blackMinted : pieceDetails[_pieceType].startingId + 1 + 2 * pieceDetails[_pieceType].whiteMinted;
		// No restriction for minting Pawn
		if (_pieceType != 5) {
			bool hasRequiredClubStacked = false;
			for (uint i = 3; i <= pieceDetails[_pieceType].clubRequirement; i++) {
				string memory name = nameOfTokenId[_stackedPiece];
				uint256 labelId = uint256(keccak256(abi.encodePacked(name)));
				require(baseRegistrar.ownerOf(labelId) == msg.sender, "NRC06");
				if (isClub(name, i)) {
					hasRequiredClubStacked = true;
					break;
				}
			}
			require(hasRequiredClubStacked, "NRC08");
			require(burnedCount[msg.sender] >= pieceDetails[_pieceType].burnRequirement);
			burnedCount[msg.sender] -= pieceDetails[_pieceType].burnRequirement;
			if (pieceDetails[_pieceType].opponentColorBurnRequirement > 0) {
				require(burnedCounterCount[msg.sender] >= pieceDetails[_pieceType].opponentColorBurnRequirement);
				burnedCounterCount[msg.sender] -= pieceDetails[_pieceType].opponentColorBurnRequirement;
			}
		}

		_mint(msg.sender, newItemId);
		_setTokenURI(newItemId, string(abi.encodePacked("ipfs://QmceFYj1a3xvhuwqb5dNstbzZ5FWNfkWfiDvPkVwvgfQpm/NumberRunner", newItemId.toString(), ".json")));
		unclaimedRewards[newItemId] = 0;
		nftShares[newItemId] = 0;
		_unstakeTimestamps[newItemId] = block.timestamp;
		expiration[newItemId] = 0;
		pieceDetails[_pieceType].totalMinted++;
		userColor[msg.sender] == 1 ? pieceDetails[_pieceType].blackMinted++ : pieceDetails[_pieceType].whiteMinted++;
		totalMinted++;
		currentSupply++;
		prizePool += 12500000000000000;

		// Add the transaction fee to the piece's balance
		updateShareType(12500000000000000);

		emit NFTMinted(msg.sender, newItemId);

		payable(NRC).transfer(25000000000000000);
	}
```

**Description :** The mint function allows a user to create a new Non-Fungible
Token (NFT) of a specific piece type. Here's a detailed breakdown:

**Preconditions:**

- Ether Sent: The user must send at least 0.05 ETH with the transaction.
- User's Color Choice: Before minting, a user must have chosen a color
  (either 1 for black or 2 for white).
- Total Pieces Minted: The function checks that the total pieces minted of the
  \_pieceType haven't reached their maximum supply.
- Color Restrictions: The function checks if the number of pieces minted of
  the specific color (black or white) hasn't reached its half limit.

**Calculating the New Item ID:**

- The new NFT's ID is calculated based on the user's chosen color and the type
  of piece they want to mint. Black tokens have even IDs, and white tokens
  have odd IDs.

**Special Checks for Non-Pawn Pieces:**

- If \_pieceType is not a pawn (i.e., \_pieceType != 5):
- The function checks if the user has a required club stacked (a tied condition
  for minting).
- It also verifies if the user has burned enough pieces (and, if necessary,
  enough opposing pieces). The user's burned piece count is then decremented
  accordingly.

**Minting Process:**

- The NFT is created (\_mint) and assigned to the sender (msg.sender).
- The token's URI (where its metadata resides) is set. This URI points to an
  IPFS address, which is a decentralized way of storing data.
- Various state variables and counters are updated, like the NFT's unclaimed
  rewards, its shares, its timestamp, etc.
- The piece's details (like the total minted and the specific color minted) are
  updated.
- The overall total minted and the current supply are also incremented.

**Prize Pool Update:** If there are currently no pawns stacked, a portion of the fees is
added to the prizePool.

**Share Type Update:** The function updates the share type with fees.
Event Emission: Finally, the function emits an NFTMinted event to notify that a new
NFT has been minted.

In essence, the mint function allows users to create a new NFT, but with certain
conditions in place (like having chosen a color, not exceeding the maximum minting
limits, and meeting certain requirements for non-pawn pieces).

## “Burn” function

```
function burn(uint256 tokenId) public saleIsActive {
require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: burn caller
is not owner nor approved");
require(!isForSale(tokenId), "This NFT is already on sale");
require(nodeOfTokenId[tokenId] == 0x0, "Cannot burn a stacked token");
uint8 _pieceType = getPieceType(tokenId);
require(_pieceType != 0, "Cannot burn the King");
updateUnclaimedRewards(_pieceType, tokenId);
uint256 totalReward = unclaimedRewards[tokenId];
// Reset reward to 0
unclaimedRewards[tokenId] = 0;
emit UpdateUnclaimedRewards(tokenId, 0);
uint256 taxAmount = (totalReward * pieceDetails[_pieceType].burnTax) / 100;
uint256 holdersTax = taxAmount / 2;
prizePool += taxAmount / 2;
// If there are no pawn stacked, send the fees to prizepool
if (typeStacked[5] == 0) {
uint256 pawnShare = (holdersTax * pieceDetails[5].percentage) / 1000;
prizePool += pawnShare;
}
updateShareType(holdersTax);
nodeOfTokenId[tokenId] = 0x0;
nameOfTokenId[tokenId] = 0x0;
_burn(tokenId);
burnedCount[msg.sender]++;
if (!isColorValid(tokenId)) {
burnedCounterCount[msg.sender]++;
}
currentSupply--;
nftShares[tokenId] = 0;
emit nftSharesUpdated(tokenId, 0);
if (totalReward > 0) {
require(address(this).balance >= totalReward - taxAmount, "Not
enough balance in contract to send rewards");
payable(msg.sender).transfer(totalReward - taxAmount);
}
emit NFTBurned(msg.sender, tokenId);
}
```

**Description :** The burn function allows a user to destroy a Non-Fungible Token
(NFT) they own. Here's a detailed description:
**Prerequisites:**

- Active Sale: This function can only be called if the sale is still active (as
  defined by the saleIsActive modifier).
- Ownership: The caller (the sender) must be the owner of the token or have an
  allowance for this token.
- Sale Status: The token should not already be on sale.
- Stacked Token: The token (piece) should not be stacked (indicated by the
  nodeOfTokenId).
- Piece Type: It is impossible to destroy the king (because \_pieceType should
  not be equal to 0).

**Update of Unclaimed Rewards:** The function first updates the unclaimed rewards
for the piece type and the token ID.

**Tax Calculation:** The tax on unclaimed rewards is calculated. Half of this tax goes to
the prize pool (prizePool), and the other half is distributed among the holders.\

**Prize Pool Update:** If no pawn is stacked, a portion of the fees is added to the
prizePool.

**Type Share Update:** The type shares are updated with the holders' share.

**Burning:**

- Information associated with the token, such as the nodeOfTokenId and the
  nameOfTokenId, are reset.
- The token is then destroyed using the \_burn function.
- The counters associated with the user for the total number of burnt pieces are
  incremented. If the token does not have the valid color, the counter for burnt
  opposing pieces is also incremented.
- The current supply (currentSupply) is decremented.
- Shares associated with the NFT are reset.
  Reward Transfer: If the total rewards are greater than 0, the function checks if the
  contract has enough ETH to send the rewards to the user. If so, the user receives
  their rewards minus the tax.
  Event Emission: Finally, the function emits an NFTBurned event to notify that the
  NFT has been destroyed.

In essence, the burn function allows users to destroy an NFT they own and receive
rewards for it, less a certain tax.

## “multiKill” function

```
function multiKill(uint256[] calldata tokensId) public payable saleIsActive {
require(tokensId.length > 0, "TokensId array is empty");
require(msg.sender != address(0), "Buyer is zero address");
require(totalMinted == MAX_NFT_SUPPLY, "All NFT must be minted for
access this feature");
uint256 totalPrice = 0;
uint256 killFee = 0;
uint256 rewards = 0;
for (uint i = 0; i < tokensId.length; i++) {
require(!isColorValid(tokensId[i]), "User cannot kill same team color
NFT");
rewards = unclaimedRewards[tokensId[i]] + nftShares[tokensId[i]];
if (nodeOfTokenId[tokensId[i]] != 0x0) {
if (expiration[tokensId[i]] == 0) {
killFee = 150000000000000000 + (rewards _ 10) / 100;
} else {
require(block.timestamp > expiration[tokensId[i]]);
killFee = 0;
}
} else {
require(block.timestamp >= \_unstakeTimestamps[tokensId[i]] +
ONE_WEEK, "Cannot burn: One week waiting period is not over");
if (isForSale(tokensId[i])) {
killFee = 100000000000000000 + (rewards _ 10) / 100;
} else {
killFee = 50000000000000000 + (rewards \* 10) / 100;
}
}
\_setNftPrice(tokensId[i], 0);
unclaimedRewards[tokensId[i]] = 0;
nftShares[tokensId[i]] = 0;
totalPrice += killFee;
}
require(msg.value >= totalPrice, "Insufficient amount sent");
for (uint i = 0; i < tokensId.length; i++) {
killNFT(tokensId[i]);
}
}
```

**Description :** The multiKill function allows a user to "kill" several Non-Fungible
Tokens (NFTs) in a single transaction. Here's a detailed description of this function:
Prerequisites: Active Sale: The function can only be called if the sale is still active
(as indicated by the saleIsActive modifier).

**Initial Checks:**

- The set of NFT identifiers (tokensId) must not be empty.
- The sender must not be the zero address.
- All NFTs must have been created to access this function (verification with
  totalMinted).

**For each token in the list of tokensId:**

- Verify that the color of the NFT is not valid for the user (the user cannot "kill"
  tokens of their own color).
- Calculate the rewards for the given NFT.
- If the NFT is stacked (nodeOfTokenId different from 0x0): If the token has no
  expiry date, the cost to "kill" it is 0.015 ETH plus 10% of the rewards. If the
  token has an expiry date, ensure that the current date is after this expiry date.
  In this case, the cost to "kill" it is 0.
- If the NFT is not stacked:
- Ensure that the token has passed a waiting period of one week after being
  unstacked.
- If the NFT is on sale, the cost to "kill" it is 0.010 ETH plus 10% of the rewards.
- Otherwise, the cost to "kill" it is 0.005 ETH plus 10% of the rewards.
- Reset the token's price to 0 and also reset the NFT's rewards and shares.
- Accumulate the total cost to "kill" all tokens in totalPrice.

**Payment Verification:** Ensure that the amount sent by the user (msg.value) is at
least equal to the total calculated cost to "kill" the tokens.

**Execution of the "kill" function:** For each token in the list of tokensId, call the
killNFT function to "kill" it (this function handles the logic of "killing" an individual
token).

In summary, this multiKill function allows a user to "kill" multiple NFTs in a single
transaction, provided they adhere to certain rules and pay the appropriate amount.

## “killNFT” function

```
function killNFT(uint256 tokenId) private {
		uint8 _pieceType = getPieceType(tokenId);
		require(_pieceType != 0, "NRC11");
		uint256 killFee = 0;
		uint256 rewards = unclaimedRewards[tokenId] + nftShares[tokenId];

		if (bytes(nameOfTokenId[tokenId]).length != 0) {
			if (isClub(nameOfTokenId[tokenId], 5)) {
				killFee = 150000000000000000 + (rewards * 10) / 100;
			} else {
				require(block.timestamp > expiration[tokenId]);
				killFee = 0;
			}
		} else {
			if (isForSale(tokenId)) {
				killFee = 100000000000000000 + (rewards * 10) / 100;
			} else {
				killFee = 50000000000000000 + (rewards * 10) / 100;
			}
		}
		prizePool += (rewards * 10) / 100;

		_burn(tokenId);

		currentSupply--;

		if (rewards > 0) {
			require(address(this).balance >= rewards - (rewards * 15) / 100);
			string memory name = nameOfTokenId[tokenId];
			if (bytes(name).length != 0) {
				uint256 labelId = uint256(keccak256(abi.encodePacked(name)));
				payable(baseRegistrar.ownerOf(labelId)).transfer(rewards - (rewards * 15) / 100);
				tokenIdOfName[nameOfTokenId[tokenId]] = 0;
				nameOfTokenId[tokenId] = "";
			} else {
				payable(ownerOf(tokenId)).transfer(rewards - (rewards * 15) / 100);
			}
		}

		emit NFTKilled(tokenId);
		emit NFTBurned(msg.sender, tokenId);
	}
```

**Description :** The killNFT function allows a user to "kill" or destroy a specific
Non-Fungible Token (NFT). It is a private function, meaning it can only be called from
within the contract. Here's a detailed description of this function:

**Prerequisites:**

- Active Sale: The function can only be called if the sale is active, as indicated
  by the saleIsActive modifier.
- Piece Type: The function retrieves the piece type associated with the token ID
  using the getPieceType function.
- Killing the king (piece type 0) is prohibited.

**Murder Fee Calculation:**

- If the token is stacked (meaning the nodeOfTokenId for this token is not 0x0):
- If the token has no expiry date, the fee to kill it is 0.015 ETH plus 10% of the
  rewards associated with this token.
- If the token has an expiry date, ensure the current date is past this expiry
  date. In this case, the fee is 0.
- If the token isn't stacked:
- If the token is on sale, the fee to kill it is 0.010 ETH plus 10% of the rewards.
- Otherwise, the fee to kill it is 0.005 ETH plus 10% of the rewards.

**Prize Pool Update:** The prize pool is increased by the murder fee and an additional
destruction fee. If the piece type is a pawn (type 5), the destruction fee is 5% of the
rewards. Otherwise, it is 10%.

**NFT Destruction:** The NFT is destroyed by calling the internal \_burn function.
Reward Distribution: If the rewards associated with the NFT are greater than 0:
Ensure the contract has enough ether to pay out the rewards. If the token was
stacked, send the rewards to the owner of the associated ENS node. Then, reset the
associations between the token and the node.
Otherwise, send the rewards to the NFT owner.

**Event Emissions:**

- Emit an NFTKilled event to signal that the NFT has been killed.
- Also, emit an NFTBurned event to indicate that the NFT has been destroyed.
  In short, this function allows a user to "kill" an NFT, apply associated fees, and
  distribute the appropriate rewards.

## “updateExpiration” function

```
function updateExpiration(uint256 tokenId) public {
// Ensure the function caller owns the ENS node
require(nodeOfTokenId[tokenId] != 0x0, "Token is not stacked yet");
// Ensure the NFT is managed by this contract, doublon?
require(ownerOf(tokenId) == address(this), "NFT not staked");
bytes32 node = nodeOfTokenId[tokenId];
require(tokenIdOfNode[node] != 0, "ENS not used yet");
// Ensure the function caller owns the ENS node
require(ens.owner(node) == msg.sender, "Not owner of ENS node");
expiration[tokenId] = getDomainExpirationDate(node);
}
```

**Description :** The updateExpiration function allows for updating the expiry date of
an ENS domain associated with a specific Non-Fungible Token (NFT). Here's a
detailed explanation of this function:

**Preliminary Checks:**

- Ensure that the NFT is linked to an ENS node (nodeOfTokenId[tokenId]
  should not be 0x0), which means that the token is stacked.
- Ensure that the NFT is held (or managed) by this contract. This is a security
  measure to ensure that only a staked NFT can have its expiry date updated.
- The ENS node linked to the NFT must be in use (i.e., tokenIdOfNode[node] is
  not 0).
- The function caller (the message sender) must be the owner of the associated
  ENS node.

**Updating the Expiry Date:**

- Retrieve the expiry date of the linked ENS domain using the
  getDomainExpirationDate(node) function.
- Update the expiry date for the specified NFT with the retrieved value.

  In summary, this function allows the owner of an ENS domain linked to an NFT to
  update the domain's expiry date within the contract.

## “stack” function

```
function stack(string memory label, uint256 tokenId) external {
		uint256 labelId = uint256(keccak256(abi.encodePacked(label)));
		require(!isForSale(tokenId));
		require(bytes(nameOfTokenId[tokenId]).length == 0);
		require(tokenIdOfName[label] == 0);
		require(baseRegistrar.ownerOf(labelId) == msg.sender, "NRC06");

		// Ensure the function caller owns the NFT
		require(ownerOf(tokenId) == msg.sender, "NRC07");

		require(isColorValid(tokenId));
		uint8 _pieceType = getPieceType(tokenId);
		bool hasValidClub = false;
		for (uint i = 3; i <= pieceDetails[_pieceType].clubRequirement; i++) {
			if (pieceDetails[_pieceType].palindromeClubRequirement) {
				if (i == pieceDetails[_pieceType].clubRequirement) {
					if (isClub(label, i) && isPalindrome(label)) {
						hasValidClub = true;
						break;
					}
				} else {
					if (isClub(label, i)) {
						hasValidClub = true;
						break;
					}
				}
			} else {
				if (isClub(label, i)) {
					hasValidClub = true;
					break;
				}
			}
		}
		require(hasValidClub, "NRC08");
		typeStacked[_pieceType] += 1;
		nftShares[tokenId] = shareTypeAccumulator[_pieceType][epoch];
		expiration[tokenId] = getDomainExpirationDate(labelId);
		emit nftSharesUpdated(tokenId, shareTypeAccumulator[_pieceType][epoch]);

		if (typeStacked[_pieceType] == 1) {
			// If it's the first piece of this type
			if (_pieceType != 5) {
				pieceDetails[5].percentage -= pieceDetails[_pieceType].percentage;
			}
		}

		// Transfer the NFT to this contract
		transferFrom(msg.sender, address(this), tokenId);
		// Set the token ID for the ENS node
		nameOfTokenId[tokenId] = label;
		tokenIdOfName[label] = tokenId;
		emit NFTStacked(tokenId, label, expiration[tokenId]);
	}
```

**Description :** The stack function is used to link a Non-Fungible Token (NFT) with
an Ethereum Name Service (ENS) domain name. This means a user binds their NFT
to a specific ENS name. Here's a detailed explanation of this function:

**Preliminary Checks:**

- Ensure that the function caller (the message sender) is the owner of the
  specified ENS node.
- Ensure that the NFT is not for sale.
- The NFT must not already be stacked (linked to an ENS node).
- The specified ENS name should not already be used by another NFT.
- The function caller must be the owner of the NFT.

**Color Verification:** The user can only stack if they own an NFT of the right color.

**Piece Type and Club Verification:** Determine the piece type of the NFT.
There are specific conditions regarding the name club associated with the NFT. For
instance, a name might need to be a palindrome or belong to a specific club to be
valid. The loop is used to verify these conditions.

**Updating Stacking Details:**

- Update the counter for the stacked piece type.
- Update the NFT's shares with the current value for this piece type and epoch.
- Update the NFT's expiry date with the ENS domain's expiry date.

**Percentage Updates:** If it's the first time an NFT of this type is stacked, adjustments
are made to the percentages associated with other pieces.

**Transfer of the NFT:** The NFT is transferred from the function caller to this contract
for stacking.

**Updating Mappings:** The mappings linking the NFT to the ENS node and vice versa
are updated.

**Event:** An event is triggered to notify that the NFT has been stacked.

The safeTransferFrom function is a safer version that ensures the recipient can
handle ERC-721 tokens. If the recipient is not a smart contract capable of managing
ERC-721 tokens, the transaction will be reverted.

## “unstack” function

```
function unstack(uint256 tokenId) public {
// Ensure the function caller owns the ENS node
require(nodeOfTokenId[tokenId] != 0x0, "Token is not stacked yet");
// Ensure the NFT is managed by this contract, doublon?
require(ownerOf(tokenId) == address(this), "NFT not staked");
bytes32 node = nodeOfTokenId[tokenId];
uint8 \_pieceType = getPieceType(tokenId);
require(tokenIdOfNode[node] != 0, "ENS not used yet");
require(ens.owner(node) == msg.sender, "Not owner of ENS node");
typeStacked[_pieceType] -= 1;
// Transfer the NFT back to the function caller
ERC721(address(this)).safeTransferFrom(address(this), msg.sender,
tokenId);
nodeOfTokenId[tokenId] = 0x0;
tokenIdOfNode[node] = 0;
expiration[tokenId] = 0;
emit NFTUnstacked(tokenId, nameOfTokenId[tokenId]);
nameOfTokenId[tokenId] = 0x0;
\_unstakeTimestamps[tokenId] = block.timestamp;
updateUnclaimedRewards(\_pieceType, tokenId);
emit UpdateUnclaimedRewards(tokenId, unclaimedRewards[tokenId]);
// update user and total stake count
nftShares[tokenId] = 0;
emit nftSharesUpdated(tokenId, 0);
}
```

**Description :** The unstack function is used to unstack a Non-Fungible Token
(NFT) from an Ethereum Name Service (ENS) domain name. This is essentially the
opposite of the stack function. Here's a step-by-step explanation:

**Preliminary Checks:**

- Ensure the NFT is currently stacked (linked to an ENS node).
- Ensure the NFT is currently managed by this contract (i.e., it has been
  transferred to and is held by this contract).
- Retrieve the ENS node associated with the NFT.
- Determine the piece type of the NFT.
- Ensure the ENS name is currently in use.
- Ensure the function caller is the owner of the ENS node.

**Updating Stacking Details:** Decrease the counter of the specified piece type.
Transfer of the NFT: Return the NFT to the function caller. This is done using
safeTransferFrom, a secure way to transfer an NFT to a user or a contract.

**Updating Mappings:**

- Reset the mappings linking the NFT to the ENS node and vice versa.
- Reset the expiry date of the NFT.
- Emit an event to notify that the NFT has been unstacked.
- Reset the ENS name associated with the NFT.
- Record the current timestamp for the NFT as the time of unstacking.

**Updating Unclaimed Rewards:**

- Update the unclaimed rewards for the specified piece type and NFT.
- Emit an event to notify of the update of unclaimed rewards.

**Updating NFT Details:**

- Reset the shares associated with the NFT.
- Emit an event to notify of the update of the NFT's shares.

  The unstack function allows users to undo the process of linking their NFT with an
  ENS domain, which may be necessary if they want to sell or transfer the NFT or the
  ENS domain separately. It also ensures that any rewards or updates associated with
  the NFT are handled correctly.

## “listNFT” function

```
function listNFT(uint256 tokenId, uint256 price) public saleIsActive {
require(!isForSale(tokenId));
require(\_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller
is not owner nor approved");
require(price > 0);
\_setNftPrice(tokenId, price);
emit NFTListed(msg.sender, tokenId, price);
}
```

**Description :** The listNFT function allows a user to list their non-fungible token
(NFT) for sale at a specified price.

**Inputs:**

- tokenId: Unique identifier of the NFT.
- price: Desired sale price.

**Checks:**

- saleIsActive: Ensures the sale is active.
- !isForSale(tokenId): Checks that the NFT is not already for sale.
- \_isApprovedOrOwner(...): Ensures the caller is the owner of the NFT or is
  approved to manage it.
- price > 0: Ensures the price is greater than 0.

**Execution:** The function lists the NFT for sale at the specified price.

**Notification:** An NFTListed event is emitted to signal the listing for sale.

In summary, this function allows listing an NFT for sale and notifies external
observers of this listing via an event.

## “unlistNFT” function

```
function unlistNFT(uint256 tokenId) public saleIsActive {
require(msg.sender == ownerOf(tokenId), "Not owner of the NFT");
require(isForSale(tokenId), "NFT is not for sale");
uint256 price = getNftPrice(tokenId);
require(price > 0);
\_setNftPrice(tokenId, 0);
emit NFTUnlisted(msg.sender, tokenId, price);
}
```

**Description :** This function allows a user to withdraw their non-fungible token
(NFT) from sale.

**Inputs:**

- tokenId: The unique identifier of the NFT.
  Checks:
- saleIsActive: Ensures the sale is active.
- msg.sender == ownerOf(tokenId): Checks that the caller is indeed the owner
  of the NFT.
- isForSale(tokenId): Ensures the NFT is currently listed for sale.
- price > 0: Checks that the price of the NFT is greater than 0.

**Execution:** The NFT is removed from sale by setting its price to 0.

**Notification:** An NFTUnlisted event is emitted to inform of the withdrawal from sale.

In summary, this function allows the owner of an NFT to remove it from sale and
notifies observers of this withdrawal via an event.

## “multiBuy” function

```
function multiBuy(uint256[] calldata tokensId) public payable saleIsActive {
require(tokensId.length > 0, "TokensId array is empty");
require(msg.sender != address(0), "Buyer is zero address");
uint256 totalPrice = 0;
for (uint i = 0; i < tokensId.length; i++) {
require(isForSale(tokensId[i]), "NFT is not for sale");
uint256 price = getNftPrice(tokensId[i]);
require(price > 0);
totalPrice += price;
}
require(msg.value >= totalPrice, "Insufficient amount sent");
for (uint i = 0; i < tokensId.length; i++) {
buyNFT(tokensId[i], getNftPrice(tokensId[i]));
\_setNftPrice(tokensId[i], 0);
}
}
```

**Description :** This function allows a user to purchase multiple non-fungible tokens
(NFTs) in a single transaction.

**Inputs:**

- tokensId: An array of the unique identifiers of the NFTs that the user wishes to
  purchase.

**Checks:**

- saleIsActive: Ensures the sale is active.
- tokensId.length > 0: Checks that the array of identifiers is not empty.
- msg.sender != address(0): Ensures the buyer is not the zero address.
- For each NFT in the array:
- isForSale(tokensId[i]): Ensures the NFT is listed for sale.
- price > 0: Checks that the price of the NFT is greater than 0.
- msg.value >= totalPrice: Ensures the buyer has sent enough Ether to cover
  the total cost of the NFTs.

**Execution:**
For each NFT in the array:

- The NFT is purchased using the buyNFT function.
- The NFT is removed from sale by setting its price to 0.

  In short, this function allows a user to purchase multiple NFTs in a single transaction,
  ensuring each NFT is listed for sale and that the buyer has sent enough Ether to
  cover the total cost.

## “buyNFT” function

```
function buyNFT(uint256 tokenId, uint256 price) private saleIsActive {
address seller = ownerOf(tokenId);
require(msg.sender != seller, "Cannot buy your own nft");
uint8 \_pieceType = getPieceType(tokenId);
updateUnclaimedRewards(\_pieceType, tokenId);
uint256 totalReward = unclaimedRewards[tokenId];
// Reset reward to 0
unclaimedRewards[tokenId] = 0;
emit UpdateUnclaimedRewards(tokenId, 0);
uint256 taxAmount = (totalReward \* 16) / 100;
prizePool += taxAmount / 2;
uint256 holdersTax = taxAmount / 2;
updateShareType(holdersTax);
nftShares[tokenId] = 0;
emit nftSharesUpdated(tokenId, 0);
bool success;
if (totalReward > 0) {
// Ensure the contract has enough balance to pay the seller
require(address(this).balance >= totalReward - taxAmount + price, "Not
enough balance in contract to pay seller");
(success, ) = payable(seller).call{ value: totalReward - taxAmount +
price }("");
} else {
require(address(this).balance >= price, "Not enough balance in
contract to pay price seller");
(success, ) = payable(seller).call{ value: price }("");
}
require(success, "Failed to transfer ether to seller");
// Transfer nft
ERC721(address(this)).safeTransferFrom(seller, msg.sender, tokenId);
emit NFTPurchased(msg.sender, seller, tokenId, price);
}
```

**Description :** The buyNFT function allows a user to purchase a specific
non-fungible token (NFT).

**Inputs:**

- tokenId: The unique identifier of the NFT the user wishes to purchase.
- price: The price of the NFT.

**Checks:**

- saleIsActive: Ensures the sale is active.
- msg.sender != seller: The buyer cannot be the seller.
- For the specified NFT, unredeemed rewards are updated.
- Ensures the contract has enough Ether to pay the seller.

**Execution:**

- Calculates the fee amount based on the total reward.
- Updates the reward shares for all NFT holders.
- Resets the reward shares for this NFT to zero.
- Transfers Ether to the seller, after deducting the fee.
- Transfers the NFT from the seller's address to the buyer's address.

**Output:** Emits an event to signal that the NFT has been purchased.

In summary, this function allows a user to purchase a specific NFT. The buyer sends
Ether, which is then used to pay the seller after deducting a fee. Ownership of the
NFT is then transferred from the seller's address to the buyer's address.

## “isColorValid” function

```
function isColorValid(uint256 tokenId) private view returns (bool) {
return (tokenId % 2 == 0 && userColor[msg.sender] == 1) || (tokenId % 2 != 0
&& userColor[msg.sender] == 2);
}
```

**Description :** The isColorValid function determines if the color of a non-fungible
token (NFT) is valid for a specific user.

**Inputs:**

- tokenId: The unique identifier of the NFT for which the color is to be verified.
  Checks:
- If tokenId is even (tokenId % 2 == 0) and the user's color is 1
  (userColor[msg.sender] == 1), then the color is valid.
- If tokenId is odd (tokenId % 2 != 0) and the user's color is 2
  (userColor[msg.sender] == 2), then the color is also valid.

**Output:** Returns true if the color of the NFT is valid for the user, and false otherwise.

In summary, this function checks the validity of an NFT's color against a user's
preferred color. If the two match, the color is deemed valid.

## “isPalindrome” function

```
function isPalindrome(string memory name) private pure returns (bool) {
		bytes memory nameBytes = bytes(name);
		uint start = 0;
		uint end = nameBytes.length - 1;

		while (start < end) {
			if (nameBytes[start] != nameBytes[end]) {
				return false;
			}
			start++;
			end--;
		}
		return true;
	}
```

**Description :** The isPalindrome function checks if a name (represented as
string) is a palindrome, focusing on numeric characters and excluding the ".eth"
suffix.

**Inputs:**

- name: The name you want to check.
- length: The length of the name.

**Checks:**

- The start and end indices are initialized to traverse the name from both ends.
- end is reduced by 5 to exclude ".eth" from the check.
- A while loop is used to traverse the name from the outside towards the center.
- It checks if the current characters are valid ASCII digits (between '0' and '9').
- If the two current characters don't match, the function returns false (since it's
  not a palindrome).
- The loop continues until start is equal to or greater than end.

**Output:** If the name passes all checks, it is considered a palindrome and the
function returns true. Otherwise, it returns false.

Essentially, this function checks if a name is a numeric palindrome, without
considering the ".eth" suffix.

## “getPieceType” function

```
function getPieceType(uint256 nftId) public pure returns (uint8) {
// require(nftId < MAX_NFT_SUPPLY, "NFT ID out of range");
if (nftId >= 0 && nftId < 2) {
return 0;
} else if (nftId >= 2 && nftId < 12) {
return 1;
} else if (nftId >= 12 && nftId < 62) {
return 2;
} else if (nftId >= 62 && nftId < 162) {
return 3;
} else if (nftId >= 162 && nftId < 362) {
return 4;
} else {
return 5;
}
}
```

**Description :** The getPieceType function determines the type of piece based on
the ID of an NFT (represented by nftId).

The function associates each ID range with a specific piece type:

NFT ID from 0 to 1: Type 0
NFT ID from 2 to 11: Type 1
NFT ID from 12 to 61: Type 2
NFT ID from 62 to 161: Type 3
NFT ID from 162 to 361: Type 4
All other NFT IDs: Type 5
Consequently, based on the provided NFT ID, the function returns the corresponding
type.

## “chooseColor” function

```
// Let user choose the white or black color
function chooseColor(uint8 \_color) public {
require(\_color == 1 || \_color == 2, "Invalid color");
require(userColor[msg.sender] == 0, "Color already chosen");
userColor[msg.sender] = \_color;
emit ColorChoosed(\_color, msg.sender);
}
```

**Description :** The chooseColor function allows a user to select a color: white or
black for their profile.

**Inputs:**

- \_color: The color the user wishes to choose. It can be either 1 (representing
  white) or 2 (representing black).

**Checks:**

- The function first checks that \_color is either 1 or 2. If not, it returns an error
  stating "Invalid color".
- Next, it checks if the user has previously chosen a color by consulting the
  userColor mapping with the user's address (msg.sender). If a color has been
  chosen already, the function returns an error "Color already chosen".

**Actions:** If both previous checks are passed, the function records the user's color
choice in the userColor mapping.

**Output:** The function emits a ColorChoosed event with the chosen color and the
user's address as parameters.

In summary, the chooseColor function allows a user to choose a color for their
profile. Once the color is chosen, it cannot be changed later on.

## “isClub” function

```
function isClub(string memory name, uint length) private pure returns (bool) {
		bytes memory nameBytes = bytes(name);
		if (nameBytes.length != length) {
			return false;
		}
		for (uint i = 0; i < nameBytes.length; i++) {
			if (nameBytes[i] < 0x30 || nameBytes[i] > 0x39) {
				return false;
			}
		}
		return true;
	}
```

**Description :** The isClub function determines if a given name is valid as a club name based on specific criteria.

**Inputs:**

- name: The name to check. It is a sequence of characters encoded in bytes32.
- length: The effective length of the name.

**Checks:**

- If the length of the name is greater than 32 or less than 5, the function returns
  false, indicating the name is not valid.
- The function then checks if the last four characters of the name match the
  ".eth" extension. If they don't, it returns false.
- Lastly, the function checks that all other characters in the name (besides the
  ".eth" extension) are digits. If any character is not a digit, it returns false.

**Output:** Returns true if the name is deemed to be a valid club name according to the
criteria listed above. Returns false otherwise.

In summary, the isClub function checks if a given name is a valid club name. A valid
club name is a name that ends with the ".eth" extension and has all other characters
as digits.

## “revealKingHand” function

```
function revealKingHand(uint256 tokenId) public payable {
require(msg.value >= 10000000000000); // reveal price fixed at 0.01 eth
require(ownerOf(tokenId) == msg.sender, "Not owner of NFT");
require(getPieceType(tokenId) == 5, "Token must be a Pawn");
prizePool += msg.value;
bool isKingHand = kingAuction.revealKingHand(tokenId);
emit KingHandRevealed(isKingHand);
}
```

**Description :** The revealKingHand function allows a user to reveal whether a
specific non-fungible token (NFT) represents the "king’s hand" for a fee.

**Inputs:**

- tokenId: The unique identifier of the NFT for which the user wants to reveal
  the "King’s Hand".

**Checks:**

- The user must send at least 0.01 ether to call this function. If the user sends
  less than that, the transaction fails.
- The user must be the owner of the NFT they wish to reveal.
- The NFT the user is trying to reveal must be of type "Pawn" (Pawn). This is
  determined by the getPieceType function which must return 5 for a pawn.

**Functionality:**

- If all checks are satisfied, the fee paid by the user is added to the prizePool.
- The function then calls another function (revealKingHand) from what seems to
  be an external contract named kingAuction. This external function determines
  if the given NFT is the "King’s Hand".
- A KingHandRevealed event is emitted, indicating the outcome of the reveal.

  In summary, the revealKingHand function is used to determine if a specific NFT is
  the "King’s Hand". To do this, the user must pay a fee and must be the owner of the
  NFT they wish to check. The answer is then obtained from another contract, and the
  result is communicated via an event.

## “buyKing” function

```
function buyKing(string memory label) external payable {
		uint256 labelId = uint256(keccak256(abi.encodePacked(label)));
		require(baseRegistrar.ownerOf(labelId) == msg.sender, "NRC06");
		require(isClub(label, 3), "NRC08");
		require(tokenIdOfName[label] == 0);
		require(userColor[msg.sender] == 1 || userColor[msg.sender] == 2);

		bool success = kingAuction.buyKing(userColor[msg.sender], msg.value);
		if (success) {
			// Stack the nft
			nameOfTokenId[userColor[msg.sender] - 1] = label;
			tokenIdOfName[label] = userColor[msg.sender] - 1;

			emit KingBought(msg.sender, msg.value, userColor[msg.sender] - 1, label);
			emit NFTStacked(userColor[msg.sender] - 1, label, getDomainExpirationDate(labelId));
		}
	}
```

**Description :** The buyKing function allows an Ethereum Name Service (ENS)
domain owner to purchase a king, but with some specific conditions, namely that
they should be the owner of a specific type of ENS domain.

**Parameters:**

- name: This represents the ENS node (or domain name) that the user owns
  and is using to qualify for the purchase.

  **Functionality:**

- The function checks if the caller (msg.sender) is indeed the owner of the
  provided ENS node (name) by using the ens.owner(name) == msg.sender
  condition. If not, it fails with the message "Not owner of ENS node".
- It then validates whether the given ENS domain qualifies for the "999 Club"
  criteria using the isClub(name, 7) function. If the domain does not meet this
  criteria, the function fails with the message "Only 999 Club can buy King".
- The typeStacked[0] is decremented by 1. This presumably keeps a count of a
  certain type of kings or slots available for purchase.
- The function then attempts to buy the king by invoking the buyKing function
  from the kingAuction contract, passing in the color associated with the user
  (userColor[msg.sender]) and the amount they sent with the transaction
  (msg.value).
- If the purchase from kingAuction is successful (i.e., success is true), the NFT
  representing the king is transferred to the user. This is done using the
  safeTransferFrom method of the ERC721 standard, transferring the NFT from
  the contract's address to the user's address. The specific token ID is
  calculated using userColor[msg.sender] - 1.

  In essence, this function is designed to allow ENS domain owners, specifically those
  meeting the "999 Club" criteria, to purchase a king NFT, ensuring they own the
  qualifying ENS domain and making sure the king they're buying corresponds to their
  assigned color.

## “getCurrentPrice” function

```
function getCurrentPrice() public view returns (uint256) {
return kingAuction.getCurrentPrice();
}
```

**Description :** The "getCurrentPrice" function returns the current price of a "King"
from an external contract named "kingAuction".

**Functionality:**

- This function calls the "getCurrentPrice" method from the external contract
  "kingAuction". It returns the result obtained, which represents the current price
  of a "King".

**Note:** The function is marked as view, meaning it doesn't alter the contract's state
and doesn't cost gas (except for the query cost) when called. The "kingAuction"
contract clearly plays a central role in determining the current price of a "King". This
function simply queries that contract to get the current price.

In summary, the "getCurrentPrice" function queries an external contract to fetch and
return the current price of a "King".

## “getDomainExpirationDate” function

```
function getDomainExpirationDate(bytes32 label) public view returns (uint256) {
uint256 tokenId = uint256(label);
return baseRegistrar.nameExpires(tokenId) + 90 days;
}
```

**Description :** The "getDomainExpirationDate" function determines the expiration
date of an ENS domain based on its label.

**Inputs:**

- label: The label of the ENS domain in bytes32 format. The label represents
  the hashed version of the ENS domain name.
  Functionality:
- Converts the label into a unique identifier (tokenId) using a simple bytes32 to
  uint256 conversion.
- Calls the nameExpires method of the external contract baseRegistrar with this
  identifier (tokenId). This method returns the actual expiration date of the
  domain.
- Adds 90 days to the obtained expiration date to get the new expiration date.

**Output:** Returns the expiration date of the ENS domain, extended by 90 days.

In summary, the "getDomainExpirationDate" function returns the date on which an
ENS domain will expire, by adding a 90-day grace period to the actual expiration
date.

## “claimKingHand” function

```
function claimKingHand(uint256 tokenId) public {
require(ownerOf(tokenId) == msg.sender, "Not owner of NFT");
uint256 pieceShare = kingAuction.claimKingHand(tokenId);
payable(msg.sender).transfer(pieceShare);
}
```

**Description :** The "claimKingHand" function allows the owner of a non-fungible
token (NFT) to claim their share of the "king hand" pot.

**Inputs:**

- tokenId: The unique identifier of the NFT for which the owner wishes to claim
  their share.

**Functionality:**

- Checks that the caller of the function (msg.sender) is the current owner of the
  NFT using the provided identifier (tokenId). If not, it will trigger an error with
  the message "Not owner of NFT".
- Calls the claimKingHand method of the external contract kingAuction with this
  identifier (tokenId). This method calculates the caller's share in the "king
  hand" pot and returns the amount due to them.
- Transfers the calculated share to the caller (msg.sender).

  In summary, the "claimKingHand" function allows the owner of an NFT to claim their
  share of the "king hand" pot. To ensure that this share can only be claimed once, it is
  recommended to add additional verification logic.

## “claimPrizePool” function

```
function claimPrizePool(uint256 tokenId) public saleIsNotActive {
require(isClub(nodeOfTokenId[tokenId], 7) || (isClub(nodeOfTokenId[tokenId],
8)), "Only 999Club and 10kClub can claim Prize");
require(ownerOf(tokenId) == msg.sender, "Not owner of NFT");
require(hasClaimedGeneral[tokenId] == false, "Prize already claimed on this
nft");
prizePool -= (prizePool / 999);
payable(msg.sender).transfer(prizePool / 999);
hasClaimedGeneral[tokenId] = true;
uint8 \_pieceType = getPieceType(tokenId);
updateUnclaimedRewards(\_pieceType, tokenId);
uint256 totalReward = unclaimedRewards[tokenId];
// Reset reward to 0
unclaimedRewards[tokenId] = 0;
emit UpdateUnclaimedRewards(tokenId, 0);
nftShares[tokenId] = 0;
emit nftSharesUpdated(tokenId, 0);
if (totalReward > 0) {
require(address(this).balance >= totalReward, "Not enough balance in
contract to send rewards");
payable(msg.sender).transfer(totalReward);
}
uint256 killFee = \_killFeeDebt[msg.sender];
if (killFee > 0) {
\_killFeeDebt[msg.sender] = 0;
prizePool -= killFee;
require(address(this).balance >= killFee, "Not enough balance in
contract to send rewards");
payable(msg.sender).transfer(killFee);
}
}
```

**Description :** The "claimPrizePool" function allows the owner of a non-fungible
token (NFT) to claim their share of a collective pot, as well as other rewards
associated with this NFT, under certain conditions.

**Inputs:**

- tokenId: The unique identifier of the NFT for which the owner wants to claim
  their share.

**Functionality:**

- The function can only be called if the sale is not active (saleIsNotActive).
- It checks if the NFT is associated with a "999Club" or a "10kClub" using the
  isClub function. If not, an exception is raised.
- It ensures that the caller (msg.sender) is the current owner of the NFT.
  Otherwise, it triggers an error.
- It verifies that the owner has not already claimed the prize for this NFT using
  the hasClaimedGeneral mapping. If the prize has already been claimed, an
  exception is raised.
- It deduces the owner's share from the prizePool and transfers it to them.
- It updates the state to indicate that the prize for this NFT has been claimed.
- The function updates the unclaimed rewards associated with this NFT using
  the updateUnclaimedRewards function and transfers them to the owner if they
  exist.
- It checks if the owner has a debt to the contract (via \_killFeeDebt) and, if so,
  deducts this debt from the prizePool and transfers it to the owner.

**Note:** This function handles several different elements: it allows the user to claim
their share of a pot, claim unclaimed rewards, and settle a possible debt. Each of
these elements involves ETH transfers, which requires the contract to have enough
ETH in balance to cover these transfers.

In summary, the claimPrizePool function allows an NFT owner, associated with a
"999Club" or a "10kClub", to claim their share of a pot, as well as associated rewards
and debts. The function performs several checks to ensure that only eligible owners
can claim their share and that each NFT can only claim its share once.

## “spawnKings” function

```
function spawnKings() private {
		// Black king
		_mint(address(this), 0);
		_setTokenURI(0, "ipfs://QmceFYj1a3xvhuwqb5dNstbzZ5FWNfkWfiDvPkVwvgfQpm/NumberRunner0.json");
		pieceDetails[0].totalMinted++;
		pieceDetails[0].blackMinted++;
		totalMinted++;
		currentSupply++;
		typeStacked[0] += 1;
		expiration[0] = 0;
		emit NFTMinted(address(this), 0);
		nftShares[0] = 1;
		emit nftSharesUpdated(0, 1);

		// White king
		_mint(address(this), 1);
		_setTokenURI(1, "ipfs://QmceFYj1a3xvhuwqb5dNstbzZ5FWNfkWfiDvPkVwvgfQpm/NumberRunner1.json");
		pieceDetails[0].totalMinted++;
		pieceDetails[0].whiteMinted++;
		totalMinted++;
		currentSupply++;
		typeStacked[0] += 1;
		expiration[1] = 0;
		emit NFTMinted(address(this), 1);
		nftShares[1] = 1;
		emit nftSharesUpdated(1, 1);
	}
```

**Description :** The "spawnKings" function is used to create (or "mint") two new
non-fungible tokens (NFTs) representing the kings in a chess game: a black king and
a white king.

**Functionality:**
Black King:

- It creates a new NFT with the identifier 0 and assigns it to the contract itself
  (address(this)).
- It sets an empty URI for the NFT with \_setTokenURI(0, "").
- It updates the details of the pieces (pieceDetails) to reflect that a new black
  king has been created. Specifically, it increases the total number of pieces of
  this type created (totalMinted), as well as the number of black kings created
  (blackMinted).
- It also increases the general totalMinted and the contract's currentSupply to
  reflect the creation of the NFT.
- It updates the stack of this type of piece (typeStacked) by adding one unit.
- It emits an NFTMinted event to signal the creation of the NFT.
- It sets the share of the NFT (represented by nftShares) to 1 and emits an
  nftSharesUpdated event.

White King:

- It follows the same process as for the black king, but with identifier 1 for the
  NFT representing the white king and updates the whiteMinted counter to
  reflect the creation of a new white king.

  In summary, the spawnKings function creates two NFTs (a black king and a white
  king) and assigns them to the contract itself. It also updates several counters and
  emits events to signal the creation of the NFTs.

## “updateShareType” function

```
function updateShareType(uint256 \_tax) private {
epoch += 1;
uint256[6] memory newShares;
for (uint8 i = 0; i < 6; i++) {
if (typeStacked[i] > 0) {
uint256 pieceShare = (\_tax \* pieceDetails[i].percentage) / 1000;
newShares[i] = shareTypeAccumulator[i][epoch - 1] +
pieceShare / typeStacked[i];
} else {
newShares[i] = shareTypeAccumulator[i][epoch - 1];
}
}
for (uint8 i = 0; i < 6; i++) {
shareTypeAccumulator[i].push(newShares[i]);
}
emit globalSharesUpdated(newShares);
}
```

**Description :** The "updateShareType" function is a private function that updates
the distribution of shares by type of piece (or NFT) based on a certain tax or fee
(\_tax). These accumulated shares are used to determine how much each piece
holder receives based on the type of piece they own.

**Functionality:** Incrementing the Epoch: The epoch variable is incremented,
representing a new time period or cycle.

**Calculation of New Shares:**

- A loop goes through each type of piece (from type 0 to type 5).
- If the total number of pieces of this type (typeStacked[i]) is greater than zero:
  It calculates the share for this type of piece using the percentage associated
  with this type of piece (pieceDetails[i].percentage) and divides it by the total
  number of this type of piece (typeStacked[i]).
- If the total number of pieces of this type is zero: The share for this type of
  piece remains the same as in the previous epoch.
- The newly calculated shares are stored in the newShares array.

**Updating the Accumulator:** Another loop goes through each type of piece again
and updates the shareTypeAccumulator with the newly calculated shares.

**Event:** It emits a globalSharesUpdated event that notifies listeners of the newly
calculated shares.

In summary, the updateShareType function divides a certain amount of tax (or fee)
among different types of pieces based on their associated percentage and the total
number of each type of piece. The shares are then accumulated for each epoch or
cycle, and piece holders can use these accumulated shares to determine how much
they should receive.

## “updateUnclaimedRewards” function

```
function updateUnclaimedRewards(uint8 \_pieceType, uint256 tokenId) private {
uint256 currentShares = shareTypeAccumulator[\_pieceType][epoch];
uint256 unclaimedReward;
if (currentShares > 0 && nftShares[tokenId] > 0) {
unclaimedReward = currentShares - nftShares[tokenId];
// update unclaimed rewards
unclaimedRewards[tokenId] += unclaimedReward;
}
}
```

**Description :** The "updateUnclaimedRewards" function is a private function that
updates the unclaimed rewards for a specific token (NFT) based on its type.
Functionality: Retrieving Current Shares: The current shares for the type of piece
(\_pieceType) for the current epoch (epoch) are retrieved from
shareTypeAccumulator.

**Calculation of Unclaimed Reward:**

- If the current shares (currentShares) and the shares of the specific token
  (nftShares[tokenId]) are both greater than zero, then the unclaimed reward is
  calculated.
- The unclaimed reward is equal to the difference between the current shares
  (currentShares) and the shares of the specific token (nftShares[tokenId]).
- This calculation determines how much reward has not yet been claimed by
  the token holder.

**Updating Unclaimed Rewards:** The unclaimed reward is added to the total
unclaimed rewards for this token (unclaimedRewards[tokenId]).

In summary, the updateUnclaimedRewards function determines and updates how
much reward has not yet been claimed by a specific token holder. Rewards are
based on the shares of this token compared to the accumulated shares for its type
during the current epoch. If the holder has not yet claimed their full share of the
reward, then this reward is considered unclaimed.

## “getNftPrice” function

```
function getNftPrice(uint256 tokenId) public view returns (uint256) {
return (nftPriceForSale[tokenId]);
}

```

**Description :** The "getNftPrice" function is a straightforward function that returns
the price of a non-fungible token (NFT) based on its unique identifier (tokenId).

**Input:** The unique identifier of the NFT (tokenId) is the input to this function.

**Price Retrieval:** The function directly accesses the nftPriceForSale mapping using
the tokenId as the key. It returns the value associated with this tokenId, which
represents the NFT's sale price.

**Output:** The function returns the price of the NFT (nftPriceForSale[tokenId]).

In summary, the getNftPrice function allows for easily and directly retrieving the sale
price of a specific NFT by simply providing its unique identifier (tokenId). If the
provided tokenId doesn't have an associated price in the nftPriceForSale mapping,
the function will return the default value for a uint256, which is 0.

## “setNftPrice” function

```
function \_setNftPrice(uint256 tokenId, uint256 price) private {
nftPriceForSale[tokenId] = price;
}
```

**Description :** The "\_setNftPrice" function allows setting the price of a
non-fungible token (NFT) based on its unique identifier (tokenId).

**Inputs:**

- tokenId: The unique identifier of the NFT for which a price is to be set.
- price: The price intended to be set for this NFT.

**Price Update:** The function updates the nftPriceForSale mapping using the tokenId
as the key and sets its value to the specified price.

**Private Visibility:** With the private modifier, this function can only be called from
within the contract (and not externally). This means only the contract itself can set
the price of an NFT, likely through other functions or mechanisms defined within the
contract.

In summary, the \_setNftPrice function allows for setting the sale price of a specific
NFT by providing its unique identifier (tokenId) and the desired price. Its private
scope ensures that the price can only be modified by the contract itself, providing
stricter control over the adjustment of NFT prices.

## “isForSale” function

```
function isForSale(uint256 tokenId) public view returns (bool) {
if (nftPriceForSale[tokenId] > 0) {
return true;
}
return false;
}
```

**Description :** The "isForSale" function determines if a non-fungible token (NFT) is
listed for sale on the marketplace based on its unique identifier (tokenId).

**Input:**

- tokenId: The unique identifier of the NFT that one wishes to check.

**Verification of the listing:** The function checks the value associated with this tokenId
in the nftPriceForSale array. If the value associated with the tokenId is greater than 0,
it means that the NFT is for sale at that price. In this case, the function returns true;
otherwise, it returns false.

In summary, the isForSale function checks if a given NFT is currently listed for sale. If
the sale price of the NFT is greater than zero, then the NFT is considered as being for
sale, and the function returns true. If the price is equal to zero, the NFT is not for sale,
and the function returns false.

## “getShareTypeAccumulator” function

```
function getShareTypeAccumulator(uint i, uint j) public view returns (uint256) {
return shareTypeAccumulator[i][j];
}
```

**Description :** The "getShareTypeAccumulator" function allows access to
accumulated shared data for a specific type of piece for a given epoch.

**Inputs:**

- i: The index representing the type of piece. This could be, for example, a king,
  queen, pawn, etc.
- j: The index representing the epoch. An epoch might represent a specific
  period or cycle within the contract's context.

**Process:** The function uses the indices i and j to access the corresponding value in
the two-dimensional array shareTypeAccumulator.

**Output:** Returns the accumulated value of shares for piece type i during epoch j.

In summary, this function provides a means to access information about the
accumulated amount of shares for a specific type of piece in a given epoch. This
information could be used to determine the distribution of rewards or other
mechanisms related to share-based distribution.

## “getShareTypeAccumulatorSize” function

```
function getShareTypeAccumulatorSize() public view returns (uint, uint) {
return (shareTypeAccumulator.length, shareTypeAccumulator[0].length);
}
```

**Description :** The "getShareTypeAccumulatorSize" function provides the size of
the two-dimensional array "shareTypeAccumulator" which contains accumulated
share data for various types of pieces and epochs.

**Inputs:** No inputs are required for this function.

**Process:**

- The function first fetches the size of the outer array "shareTypeAccumulator"
  with "shareTypeAccumulator.length". This indicates the number of types of
  pieces (e.g., king, queen, pawn, etc.).
- Next, it retrieves the size of the inner array at index 0 with
  "shareTypeAccumulator[0].length". This indicates the number of epochs or
  periods for which accumulated data has been recorded.

**Output:** The function returns two values:

- The size of the outer array (number of types of pieces).
- The size of the inner array (number of epochs).

  In summary, this function is useful for determining how many types of pieces have
  accumulated data and how many epochs have been recorded in the
  "shareTypeAccumulator" array. This information can assist in iterating over the array
  or understanding its structure.

## “getNftShares” function

```
function getNftShares(uint256 tokenId) public view returns (uint256) {
return nftShares[tokenId];
}
```

**Description :** The "getNftShares" function retrieves the number of shares
associated with a specific non-fungible token (NFT) based on its identifier (tokenId).

**Inputs:**

- tokenId: The unique identifier of the NFT for which one wants to know the
  number of shares.

**Process:** The function directly accesses the "nftShares" mapping using the tokenId
as a key to obtain the associated value (number of shares).

**Output:** The function returns the number of shares (uint256) associated with the
given NFT's identifier.

In summary, the "getNftShares" function is a simple and straightforward function
that provides the number of shares associated with a specific NFT based on its
identifier. This can be used to know how many shares an NFT owner holds, which
might be relevant for reward distribution mechanisms or other contract logics.

## “getUserColor” function

```
function getUserColor(address user) public view returns (uint8) {
return userColor[user];
}
```

**Description :** The "getUserColor" function retrieves the color chosen by a specific
user.

**Inputs:**

- user: The Ethereum address of the user for whom one wants to know the
  chosen color.

**Process:** The function directly accesses the "userColor" mapping using the user's
address as a key to obtain the associated value (chosen color).

**Output:** The function returns the color (uint8) associated with the given user's
address. The returned value can be 1 (to signify the white color), 2 (to signify the
black color), or 0 (if the user has not yet chosen a color).

In summary, the "getUserColor" function is a read function that provides the color
chosen by a specific user based on their Ethereum address. This can be used in
various scenarios where a user's color is relevant, for instance, to determine the
validity of an action or to display user-specific information in a user interface.

## “getTokenIdOfNode” function

```
function getTokenIdOfNode(bytes32 node) public view returns (uint256) {
return tokenIdOfNode[node];
}
```

**Description :** The "getTokenIdOfNode" function allows retrieving the token
identifier (tokenId) associated with a specific node.

**Inputs:**

- node: This is a bytes32 value representing a node (maybe a unique identifier
  or a key).

**Process:** The function directly accesses the "tokenIdOfNode" mapping using the
node as a key to obtain the associated value (tokenId).

**Output:** The function returns the token identifier (uint256) associated with the
provided node.

In summary, the "getTokenIdOfNode" function is a read function that provides the
token identifier (tokenId) associated with a given node. This function is useful in
scenarios where you have a specific node and wish to obtain the corresponding
tokenId, perhaps to interact with the token or to get information about it.

## “getBurnedCount” function

```
function getBurnedCount(address user) public view returns (uint256) {
return burnedCount[user];
}
```

**Description :** The "getBurnedCount" function allows retrieving the number of
tokens that have been burned (i.e., destroyed) by a specific user.

**Inputs:**

- user: This is the Ethereum address of the user for whom we wish to obtain the
  number of burned tokens.

**Process:** The function directly accesses the "burnedCount" mapping using the user
as a key to obtain the associated value.

**Output:** The function returns the number of tokens (uint256) that the user has
burned.

In summary, the "getBurnedCount" function is a read function that provides the
number of tokens a given user has burned. This can be useful in scenarios where you
want to track or verify the amount of tokens a user has chosen to permanently
remove from circulation.

## “getBurnedCounterCount” function

```
function getBurnedCounterCount(address user) public view returns (uint256) {
return burnedCounterCount[user];
}
```

**Description :** The "getBurnedCounterCount" function allows retrieving the number
of times a specific user has burned tokens.

**Inputs:**

- user: This is the Ethereum address of the user for whom we wish to obtain the
  number of times they have burned tokens.
  Process: The function directly accesses the "burnedCounterCount" mapping using
  the user as a key to obtain the associated value.

**Output:** The function returns the number of times (uint256) the user has burned
tokens.

In summary, the "getBurnedCounterCount" function provides the number of
occasions on which a given user has burned tokens. This is different from the
previous function that provides the total number of tokens burned. For instance, if a
user burns 5 tokens today and 3 tokens tomorrow, the first function would report 8
(total number of tokens burned) while this function would report 2 (number of times
the user has burned tokens).

## “getTotalMinted” function

```
function getTotalMinted() public view returns (uint256) {
return totalMinted;
}
```

**Description :** The "getTotalMinted" function returns the total number of
non-fungible tokens (NFTs) that have been minted (or created) within the contract.

**Inputs:** No input is needed for this function.

**Process:** The function directly accesses the "totalMinted" state variable to get its
value.

**Output:** The function returns the total number (uint256) of NFTs that have been
minted.
In summary, the "getTotalMinted" function provides information on how many NFTs
have been created within the contract so far. This is useful to keep track of the
number of NFTs that have been distributed or sold.

## “getCurrentSupply” function

```
function getCurrentSupply() public view returns (uint256) {
return currentSupply;
}
```

**Description :** The "getCurrentSupply" function returns the current number of
non-fungible tokens (NFTs) in circulation within the contract.

**Inputs:** No input is needed for this function.

**Process:** The function directly accesses the "currentSupply" state variable to get its
value.

**Output:** The function returns the current number (uint256) of NFTs in circulation.

In summary, the "getCurrentSupply" function provides information on how many
NFTs are currently in circulation. This may differ from the total minted number if
some NFTs have been burned or removed from circulation.

## “getPrizePool” function & close “NumberRunnerClub” contract

```
function getPrizePool() public view returns (uint256) {
return prizePool;
}
}
```

**Description :** The "getPrizePool" function returns the current value of the prize
pool in the contract.

**Inputs:** No input is needed for this function.

**Process:** The function directly accesses the "prizePool" state variable to get its value.

**Output:** The function returns the current amount (uint256) of the prize pool.

In summary, the "getPrizePool" function provides information on the amount
currently stored in the prize pool. This prize pool could be used to reward users or for
other mechanisms defined in the contract.

## Conclusion

The project transcends the simple notion of strategy to become a vibrant echo to the
importance of vision, appreciation of value, and diversity, much like a game of chess.
However, beyond the metaphor of the game, it is the community's strength that
drives its direction. One does not need to be a chess master to appreciate the
treasure that ENS domains and this NFT collection are. This project is carved in the
spirit of community belonging, and its future trajectory is primarily shaped by
collective decisions. Designed as a game, it thrives but with the impetus and
management of its devoted community. For more information, clarifications, or
updates, please consult the project's official channels.
