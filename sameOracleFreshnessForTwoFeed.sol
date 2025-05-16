// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DualSecurePriceFeed {
    AggregatorV3Interface public immutable priceFeed1;
    AggregatorV3Interface public immutable priceFeed2;
    uint256 public immutable GRACE_PERIOD_SECONDS;

    constructor(
        address _feed1,
        address _feed2,
        uint256 _gracePeriodSeconds
    ) {
        require(_feed1 != address(0) && _feed2 != address(0), "Invalid feed address");
        require(_gracePeriodSeconds > 0, "Grace period must be > 0");

        priceFeed1 = AggregatorV3Interface(_feed1);
        priceFeed2 = AggregatorV3Interface(_feed2);
        GRACE_PERIOD_SECONDS = _gracePeriodSeconds;
    }

    function getLatestPrices() external view returns (int256 price1, int256 price2) {
        price1 = _getPrice(priceFeed1);
        price2 = _getPrice(priceFeed2);
    }

    function _getPrice(AggregatorV3Interface feed) internal view returns (int256) {
        (
            ,              // roundId
            int256 price,  // answer
            ,              // startedAt
            uint256 updatedAt,
            // answeredInRound
        ) = feed.latestRoundData();

        require(price > 0, "Invalid price: <= 0");
        require(block.timestamp - updatedAt <= GRACE_PERIOD_SECONDS, "Stale price");

        return price;
    }
}
