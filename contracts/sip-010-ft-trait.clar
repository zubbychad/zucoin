;; SIP-010 Fungible Token Trait
;;
;; This contract only defines the SIP-010 trait so other contracts can `use-trait` it.

(define-trait sip-010-ft-trait
  (
    ;; transfer(amount, sender, recipient, memo)
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))

    ;; token metadata
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))

    ;; balances / supply
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
  )
)
