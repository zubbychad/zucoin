;; Zucoin (ZUCOIN)
;; SIP-010 compatible fungible token implemented in Clarity.
;;
;; Notes:
;; - The deployer becomes the initial contract owner.
;; - Only the owner can mint or transfer ownership.
;; - Transfers require `sender` = `tx-sender` (no allowances in this minimal implementation).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Trait (SIP-010 FT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(impl-trait .sip-010-ft-trait.sip-010-ft-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant TOKEN_NAME "Zucoin")
(define-constant TOKEN_SYMBOL "ZUCOIN")
(define-constant TOKEN_DECIMALS u6)

(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-NOT-ENOUGH-BALANCE u101)
(define-constant ERR-INVALID-AMOUNT u102)
(define-constant ERR-SAME-PRINCIPAL u103)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Storage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var contract-owner principal tx-sender)
(define-data-var total-supply uint u0)

(define-map balances
  { account: principal }
  { balance: uint }
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq sender tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    (asserts! (not (is-eq sender recipient)) (err ERR-SAME-PRINCIPAL))
    (let ((sender-balance (get-balance-or-zero sender)))
      (asserts! (>= sender-balance amount) (err ERR-NOT-ENOUGH-BALANCE))
      (begin
        (set-balance sender (- sender-balance amount))
        (set-balance recipient (+ (get-balance-or-zero recipient) amount))
        ;; Memo is accepted for SIP-010 compatibility but not stored.
        memo
        (ok true))
    )
  )
)

(define-public (mint (recipient principal) (amount uint))
  (begin
    (asserts! (is-owner tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    (set-balance recipient (+ (get-balance-or-zero recipient) amount))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)
  )
)

(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    (let ((bal (get-balance-or-zero tx-sender)))
      (asserts! (>= bal amount) (err ERR-NOT-ENOUGH-BALANCE))
      (begin
        (set-balance tx-sender (- bal amount))
        (var-set total-supply (- (var-get total-supply) amount))
        (ok true)
      )
    )
  )
)

(define-public (set-owner (new-owner principal))
  (begin
    (asserts! (is-owner tx-sender) (err ERR-NOT-AUTHORIZED))
    (var-set contract-owner new-owner)
    (ok true)
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read-only functions (SIP-010)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-balance (who principal))
  (ok (get-balance-or-zero who))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read-only helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-owner)
  (ok (var-get contract-owner))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Private helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (is-owner (who principal))
  (is-eq who (var-get contract-owner))
)

(define-private (get-balance-or-zero (who principal))
  (default-to u0 (get balance (map-get? balances { account: who })))
)

(define-private (set-balance (who principal) (amount uint))
  (map-set balances { account: who } { balance: amount })
)
