;; OpenSea-like Marketplace Contract

;; Constants
(define-constant MARKETPLACE-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-LISTING-NOT-FOUND (err u101))
(define-constant ERR-EXPIRED-LISTING (err u102))
(define-constant ERR-INADEQUATE-FUNDS (err u103))
(define-constant ERR-EXCESSIVE-ROYALTY (err u104))
(define-constant ERR-EXCESSIVE-FEE (err u105))

;; Define the listing structure
(define-map nft-listings
  { id: uint }
  {
    seller: principal,
    token-contract: principal,
    nft-id: uint,
    listing-price: uint,
    expiry: uint,
    creator-address: (optional principal),
    creator-royalty-rate: uint
  }
)

;; Marketplace fee rate (e.g., 2.5%)
(define-data-var marketplace-fee-rate uint u250)

;; Counter for listing IDs
(define-data-var next-nft-listing-id uint u1)

;; Public functions

;; List an NFT for sale
(define-public (list-nft (token-contract principal) (nft-id uint) (listing-price uint) (listing-duration uint) (creator-address (optional principal)) (creator-royalty-rate uint))
  (let
    (
      (new-listing-id (var-get next-nft-listing-id))
    )
    ;; Ensure the caller owns the NFT
    (asserts! (is-eq (contract-call? token-contract get-owner nft-id) tx-sender) ERR-UNAUTHORIZED)
    ;; Ensure the royalty percentage is not too high
    (asserts! (< creator-royalty-rate u1000) ERR-EXCESSIVE-ROYALTY) ;; Max 10% royalty
    ;; Create the listing
    (map-set nft-listings
      { id: new-listing-id }
      {
        seller: tx-sender,
        token-contract: token-contract,
        nft-id: nft-id,
        listing-price: listing-price,
        expiry: (+ block-height listing-duration),
        creator-address: creator-address,
        creator-royalty-rate: creator-royalty-rate
      }
    )
    ;; Transfer NFT to this contract
    (try! (contract-call? token-contract transfer nft-id tx-sender (as-contract tx-sender)))
    ;; Increment the listing ID
    (var-set next-nft-listing-id (+ new-listing-id u1))
    ;; Return the listing ID
    (ok new-listing-id)
  )
)

;; Buy a listed NFT
(define-public (buy-nft (nft-listing-id uint))
  (let
    (
      (nft-listing (unwrap! (map-get? nft-listings { id: nft-listing-id }) ERR-LISTING-NOT-FOUND))
      (listing-price (get listing-price nft-listing))
      (nft-seller (get seller nft-listing))
      (token-contract (get token-contract nft-listing))
      (nft-id (get nft-id nft-listing))
      (creator-address (get creator-address nft-listing))
      (creator-royalty-rate (get creator-royalty-rate nft-listing))
      (marketplace-fee (/ (* listing-price (var-get marketplace-fee-rate)) u10000))
      (creator-royalty (/ (* listing-price creator-royalty-rate) u10000))
      (seller-payout (- listing-price (+ marketplace-fee creator-royalty)))
    )
    ;; Ensure the listing hasn't expired
    (asserts! (<= block-height (get expiry nft-listing)) ERR-EXPIRED-LISTING)
    ;; Ensure the buyer has sufficient balance
    (asserts! (>= (stx-get-balance tx-sender) listing-price) ERR-INADEQUATE-FUNDS)
    ;; Transfer the NFT to the buyer
    (try! (as-contract (contract-call? token-contract transfer nft-id tx-sender tx-sender)))
    ;; Transfer payment to the seller
    (try! (stx-transfer? seller-payout tx-sender nft-seller))
    ;; Transfer marketplace fee
    (try! (stx-transfer? marketplace-fee tx-sender MARKETPLACE-OWNER))
    ;; Transfer royalty if applicable
    (match creator-address recipient
      (try! (stx-transfer? creator-royalty tx-sender recipient))
      true
    )
    ;; Remove the listing
    (map-delete nft-listings { id: nft-listing-id })
    ;; Return success
    (ok true)
  )
)

;; Cancel a listing
(define-public (cancel-listing (nft-listing-id uint))
  (let
    (
      (nft-listing (unwrap! (map-get? nft-listings { id: nft-listing-id }) ERR-LISTING-NOT-FOUND))
    )
    ;; Ensure the caller is the seller
    (asserts! (is-eq tx-sender (get seller nft-listing)) ERR-UNAUTHORIZED)
    ;; Transfer the NFT back to the seller
    (try! (as-contract (contract-call? (get token-contract nft-listing) transfer (get nft-id nft-listing) tx-sender tx-sender)))
    ;; Remove the listing
    (map-delete nft-listings { id: nft-listing-id })
    ;; Return success
    (ok true)
  )
)

;; Getter functions

;; Get listing details
(define-read-only (get-nft-listing (nft-listing-id uint))
  (map-get? nft-listings { id: nft-listing-id })
)

;; Get the current marketplace fee rate
(define-read-only (get-marketplace-fee-rate)
  (ok (var-get marketplace-fee-rate))
)

;; Admin functions

;; Set the marketplace fee rate (only contract owner)
(define-public (set-marketplace-fee-rate (new-fee-rate uint))
  (begin
    (asserts! (is-eq tx-sender MARKETPLACE-OWNER) ERR-UNAUTHORIZED)
    (asserts! (<= new-fee-rate u1000) ERR-EXCESSIVE-FEE) ;; Max 10% fee
    (ok (var-set marketplace-fee-rate new-fee-rate))
  )
)