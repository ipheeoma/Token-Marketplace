;; Title: SIP-010 NFT trait
;; Description: This trait definition outlines the standard interface for non-fungible tokens (NFTs) in the Stacks ecosystem

(define-trait nft-token
    (
        ;; Get the last token ID in this contract
        (get-last-token-id () (response uint uint))

        ;; Get the owner of a given token ID
        (get-owner (uint) (response (optional principal) uint))

        ;; Get the URI for a given token ID
        (get-token-uri (uint) (response (optional (string-utf8 256)) uint))

        ;; Transfer token to a specified principal
        (transfer (uint principal principal) (response bool uint))

        ;; Get the total supply of tokens
        (get-total-supply () (response uint uint))
    )
)