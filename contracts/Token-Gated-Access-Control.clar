(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-009-nft-trait.nft-trait)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-invalid-resource (err u102))
(define-constant err-access-denied (err u103))
(define-constant err-nft-not-found (err u104))
(define-constant err-invalid-token-id (err u105))
(define-constant err-already-exists (err u106))
(define-constant err-not-found (err u107))
(define-constant err-expired (err u108))

(define-data-var contract-uri (optional (string-utf8 256)) none)
(define-data-var last-token-id uint u0)
(define-data-var access-fee uint u1000000)

(define-map tokens uint 
  {
    owner: principal,
    metadata-uri: (optional (string-utf8 256)),
    minted-at: uint,
    access-level: uint
  }
)

(define-map token-count principal uint)

(define-map resources uint
  {
    name: (string-ascii 64),
    description: (string-ascii 256),
    required-access-level: uint,
    creator: principal,
    created-at: uint,
    active: bool,
    access-count: uint
  }
)

(define-map resource-access {resource-id: uint, user: principal}
  {
    granted-at: uint,
    expires-at: (optional uint),
    access-count: uint
  }
)

(define-map user-access-history principal (list 100 uint))
(define-map resource-count principal uint)
(define-data-var last-resource-id uint u0)

(define-read-only (get-contract-uri)
  (ok (var-get contract-uri))
)

(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (ok (get metadata-uri (map-get? tokens token-id)))
)

(define-read-only (get-owner (token-id uint))
  (ok (get owner (map-get? tokens token-id)))
)

(define-read-only (get-token-info (token-id uint))
  (map-get? tokens token-id)
)

(define-read-only (get-balance (user principal))
  (default-to u0 (map-get? token-count user))
)

(define-read-only (get-resource-info (resource-id uint))
  (map-get? resources resource-id)
)

(define-read-only (get-user-access-level (user principal))
  (let 
    (
      (user-tokens (get-user-tokens user))
      (max-level (fold get-max-access-level user-tokens u0))
    )
    max-level
  )
)

(define-read-only (get-user-tokens (user principal))
  (let 
    (
      (total-tokens (var-get last-token-id))
    )
    (filter-user-tokens user (list-range u1 total-tokens))
  )
)

(define-private (filter-user-tokens (user principal) (token-list (list 1000 uint)))
  (filter (lambda (token-id) (is-owner user token-id)) token-list)
)

(define-private (is-owner (user principal) (token-id uint))
  (match (map-get? tokens token-id)
    token-data (is-eq user (get owner token-data))
    false
  )
)

(define-private (get-max-access-level (token-id uint) (current-max uint))
  (match (map-get? tokens token-id)
    token-data 
      (let ((token-level (get access-level token-data)))
        (if (> token-level current-max) token-level current-max)
      )
    current-max
  )
)

(define-private (list-range (start uint) (end uint))
  (if (<= start end)
    (unwrap! (as-max-len? (append (list-range start (- end u1)) end) u1000) (list))
    (list)
  )
)

(define-read-only (can-access-resource (user principal) (resource-id uint))
  (match (map-get? resources resource-id)
    resource-data
      (let 
        (
          (required-level (get required-access-level resource-data))
          (user-level (get-user-access-level user))
          (is-active (get active resource-data))
        )
        (and is-active (>= user-level required-level))
      )
    false
  )
)

(define-read-only (get-access-history (user principal))
  (default-to (list) (map-get? user-access-history user))
)

(define-public (set-contract-uri (uri (optional (string-utf8 256))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set contract-uri uri))
  )
)

(define-public (mint-access-token (to principal) (metadata-uri (optional (string-utf8 256))) (access-level uint))
  (let 
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? access-nft token-id to))
    (map-set tokens token-id
      {
        owner: to,
        metadata-uri: metadata-uri,
        minted-at: stacks-block-height,
        access-level: access-level
      }
    )
    (map-set token-count to (+ (get-balance to) u1))
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (asserts! (is-some (map-get? tokens token-id)) err-invalid-token-id)
    (try! (nft-transfer? access-nft token-id sender recipient))
    (map-set tokens token-id
      (merge 
        (unwrap-panic (map-get? tokens token-id))
        {owner: recipient}
      )
    )
    (map-set token-count sender (- (get-balance sender) u1))
    (map-set token-count recipient (+ (get-balance recipient) u1))
    (ok true)
  )
)

(define-public (create-resource (name (string-ascii 64)) (description (string-ascii 256)) (required-access-level uint))
  (let 
    (
      (resource-id (+ (var-get last-resource-id) u1))
    )
    (map-set resources resource-id
      {
        name: name,
        description: description,
        required-access-level: required-access-level,
        creator: tx-sender,
        created-at: stacks-block-height,
        active: true,
        access-count: u0
      }
    )
    (map-set resource-count tx-sender (+ (default-to u0 (map-get? resource-count tx-sender)) u1))
    (var-set last-resource-id resource-id)
    (ok resource-id)
  )
)

(define-public (update-resource-status (resource-id uint) (active bool))
  (match (map-get? resources resource-id)
    resource-data
      (begin
        (asserts! (is-eq tx-sender (get creator resource-data)) err-not-authorized)
        (map-set resources resource-id
          (merge resource-data {active: active})
        )
        (ok true)
      )
    err-not-found
  )
)

(define-public (request-access (resource-id uint))
  (let 
    (
      (user tx-sender)
    )
    (asserts! (can-access-resource user resource-id) err-access-denied)
    (match (map-get? resources resource-id)
      resource-data
        (begin
          (map-set resource-access {resource-id: resource-id, user: user}
            {
              granted-at: stacks-block-height,
              expires-at: none,
              access-count: (+ (default-to u0 (get access-count (default-to {granted-at: u0, expires-at: none, access-count: u0} (map-get? resource-access {resource-id: resource-id, user: user})))) u1)
            }
          )
          (map-set resources resource-id
            (merge resource-data {access-count: (+ (get access-count resource-data) u1)})
          )
          (map-set user-access-history user 
            (unwrap! (as-max-len? (append (get-access-history user) resource-id) u100) err-invalid-resource)
          )
          (ok true)
        )
      err-invalid-resource
    )
  )
)

(define-public (revoke-access (resource-id uint) (user principal))
  (match (map-get? resources resource-id)
    resource-data
      (begin
        (asserts! (is-eq tx-sender (get creator resource-data)) err-not-authorized)
        (map-delete resource-access {resource-id: resource-id, user: user})
        (ok true)
      )
    err-not-found
  )
)

(define-public (set-access-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set access-fee new-fee))
  )
)

(define-public (burn-token (token-id uint))
  (let 
    (
      (owner (unwrap! (get-owner token-id) err-invalid-token-id))
    )
    (asserts! (is-eq tx-sender (unwrap-panic owner)) err-not-authorized)
    (try! (nft-burn? access-nft token-id tx-sender))
    (map-delete tokens token-id)
    (map-set token-count tx-sender (- (get-balance tx-sender) u1))
    (ok true)
  )
)

(define-non-fungible-token access-nft uint)
