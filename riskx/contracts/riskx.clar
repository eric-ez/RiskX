;; Decentralized Insurance Contract

;; Constants
(define-constant system-admin tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-claim-invalid (err u101))
(define-constant err-payment-low (err u102))
(define-constant err-no-coverage (err u103))
(define-constant err-params-bad (err u104))
(define-constant max-insurable-amount u1000000000) ;; Maximum coverage amount
(define-constant max-policy-duration u52560) ;; Maximum duration (about 1 year in blocks)
(define-constant min-policy-premium u1000) ;; Minimum premium amount

;; Data Maps
(define-map policy-registry
    principal
    {
        insurable-amount: uint,
        policy-fee: uint,
        expiry-block: uint
    })

(define-map claim-registry
    principal
    {
        amount: uint, 
        is-approved: bool
    })

;; Variables
(define-data-var reserve-pool uint u0)

;; Admin Functions
(define-public (setup-policy-template (insurable-amount uint) (policy-fee uint) (duration uint))
    (let ((expiry-block (+ block-height duration)))
        (begin
            (asserts! (is-eq tx-sender system-admin) err-admin-only)
            (asserts! (<= insurable-amount max-insurable-amount) err-params-bad)
            (asserts! (>= policy-fee min-policy-premium) err-params-bad)
            (asserts! (<= duration max-policy-duration) err-params-bad)
            (map-set policy-registry tx-sender
                {
                    insurable-amount: insurable-amount,
                    policy-fee: policy-fee,
                    expiry-block: expiry-block
                })
            (ok true))))

;; User Functions
(define-public (buy-coverage (insurable-amount uint) (duration uint))
    (let 
        ((coverage-fee (* insurable-amount (/ u1 u100) duration))
         (expiry-block (+ block-height duration)))
        (begin
            (asserts! (<= insurable-amount max-insurable-amount) err-params-bad)
            (asserts! (<= duration max-policy-duration) err-params-bad)
            (asserts! (>= coverage-fee min-policy-premium) err-params-bad)
            
            ;; Safe arithmetic operations with checks
            (asserts! (>= (+ (var-get reserve-pool) coverage-fee) 
                         (var-get reserve-pool)) 
                     err-params-bad)
            
            (try! (stx-transfer? coverage-fee tx-sender (as-contract tx-sender)))
            (var-set reserve-pool (+ (var-get reserve-pool) coverage-fee))
            (map-set policy-registry tx-sender
                {
                    insurable-amount: insurable-amount,
                    policy-fee: coverage-fee,
                    expiry-block: expiry-block
                })
            (ok true))))

(define-public (submit-claim (amount uint))
    (let 
        ((policy (unwrap! (map-get? policy-registry tx-sender) (err err-no-coverage))))
        (begin
            (asserts! (<= amount (get insurable-amount policy)) (err err-claim-invalid))
            (asserts! (is-ok (as-contract (stx-transfer? amount tx-sender tx-sender))) (err err-payment-low))
            (var-set reserve-pool (- (var-get reserve-pool) amount))
            (map-set claim-registry tx-sender
                {
                    amount: amount,
                    is-approved: true
                })
            (ok true))))

;; Read-Only Functions
(define-read-only (get-coverage-info (policyholder principal))
    (map-get? policy-registry policyholder))

(define-read-only (get-claim-info (claim-filer principal))
    (map-get? claim-registry claim-filer))

(define-read-only (get-reserve-balance)
    (var-get reserve-pool))