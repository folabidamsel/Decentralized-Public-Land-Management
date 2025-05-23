;; Habitat Verification Contract
;; Validates ecosystem boundaries and habitat data

(define-data-var admin principal tx-sender)

;; Data structure for habitats
(define-map habitats
  { habitat-id: uint }
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    area-sq-km: uint,
    verified: bool,
    verification-date: uint,
    verifier: principal
  }
)

;; Counter for habitat IDs
(define-data-var habitat-counter uint u0)

;; Add a new habitat
(define-public (add-habitat (name (string-utf8 100)) (location (string-utf8 100)) (area-sq-km uint))
  (let ((habitat-id (+ (var-get habitat-counter) u1)))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u403))
      (var-set habitat-counter habitat-id)
      (map-set habitats
        { habitat-id: habitat-id }
        {
          name: name,
          location: location,
          area-sq-km: area-sq-km,
          verified: false,
          verification-date: u0,
          verifier: tx-sender
        }
      )
      (ok habitat-id)
    )
  )
)

;; Verify a habitat
(define-public (verify-habitat (habitat-id uint))
  (let ((habitat (unwrap! (map-get? habitats { habitat-id: habitat-id }) (err u404))))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u403))
      (map-set habitats
        { habitat-id: habitat-id }
        (merge habitat {
          verified: true,
          verification-date: block-height,
          verifier: tx-sender
        })
      )
      (ok true)
    )
  )
)

;; Get habitat details
(define-read-only (get-habitat (habitat-id uint))
  (map-get? habitats { habitat-id: habitat-id })
)

;; Set a new admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
