# NFT Marketplace Smart Contract

## Overview

This project implements a robust NFT (Non-Fungible Token) marketplace smart contract using Clarity, the smart contract language for the Stacks blockchain. The contract enables users to list, buy, and cancel NFT listings, with support for royalties and platform fees.

## Features

- *NFT Listing*: Users can list their NFTs for sale, specifying price, duration, and royalty information.
- *NFT Purchasing*: Buyers can purchase listed NFTs, with automatic transfer of the token and distribution of funds.
- *Listing Cancellation*: Sellers can cancel their listings and retrieve their NFTs.
- *Royalty Payments*: Supports royalty payments to original creators when NFTs are sold.
- *Platform Fees*: Configurable platform fee for each transaction.
- *Expiration Mechanism*: Listings automatically expire after a set duration.
- *Owner-only Administration*: Certain functions (e.g., setting platform fees) are restricted to the contract owner.

## Contract Structure

The main contract file is nft-auction.clar. It contains the following key components:

- Constants for error codes and the contract owner
- Data maps for storing NFT listings
- Public functions for listing, buying, and canceling NFT sales
- Getter functions for retrieving listing details and platform fee rates
- Admin functions for managing platform fees

## Prerequisites

- Clarity language knowledge
- A Stacks blockchain development environment (e.g., Clarinet)
- Basic understanding of NFTs and blockchain concepts

## Usage

### Deploying the Contract

Deploy the contract to the Stacks blockchain using your preferred method (e.g., Clarinet or directly through the Stacks CLI).

### Interacting with the Contract

Here are the main functions you can interact with:

1. *Listing an NFT*:
   clarity
   (list-nft token-contract nft-id listing-price listing-duration creator-address creator-royalty-rate)
   

2. *Buying an NFT*:
   clarity
   (buy-nft nft-listing-id)
   

3. *Canceling a Listing*:
   clarity
   (cancel-listing nft-listing-id)
   

4. *Getting Listing Details*:
   clarity
   (get-nft-listing nft-listing-id)
   

5. *Getting Platform Fee Rate*:
   clarity
   (get-marketplace-fee-rate)
   

6. *Setting Platform Fee Rate* (owner only):
   clarity
   (set-marketplace-fee-rate new-fee-rate)
   

## Security Considerations

- The contract includes checks to ensure only authorized users can perform certain actions.
- Royalty percentages and platform fees are capped to prevent excessive charges.
- Proper error handling is implemented throughout the contract.

## Contributing

Contributions to improve the contract are welcome. Please follow these steps:

1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request