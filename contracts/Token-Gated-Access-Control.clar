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

(define-constant err-delegation-expired (err u109))
(define-constant err-delegation-not-found (err u110))
(define-constant err-invalid-delegation (err u111))

(define-constant err-subscription-expired (err u112))
(define-constant err-subscription-not-found (err u113))
(define-constant err-invalid-duration (err u114))

(define-constant err-not-co-owner (err u200))
(define-constant err-invalid-shares (err u201))
(define-constant err-too-many-owners (err u202))
(define-constant err-already-co-owner (err u203))
(define-constant err-no-balance (err u204))

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

(define-read-only (get-user-tokens (user principal))
  (let 
    (
      (total-tokens (var-get last-token-id))
      (result (fold check-token-ownership (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100) {user: user, max-id: total-tokens, tokens: (list)}))
    )
    (get tokens result)
  )
)

(define-private (check-token-ownership (token-id uint) (acc {user: principal, max-id: uint, tokens: (list 100 uint)}))
  (if (and (<= token-id (get max-id acc)) (is-owner (get user acc) token-id))
    (let ((new-list (as-max-len? (append (get tokens acc) token-id) u100)))
      (if (is-some new-list)
        (merge acc {tokens: (unwrap-panic new-list)})
        acc))
    acc
  )
)

(define-read-only (get-user-access-level (user principal))
  (let 
    (
      (total-tokens (var-get last-token-id))
      (max-level (fold check-user-token-level (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31 u32 u33 u34 u35 u36 u37 u38 u39 u40 u41 u42 u43 u44 u45 u46 u47 u48 u49 u50 u51 u52 u53 u54 u55 u56 u57 u58 u59 u60 u61 u62 u63 u64 u65 u66 u67 u68 u69 u70 u71 u72 u73 u74 u75 u76 u77 u78 u79 u80 u81 u82 u83 u84 u85 u86 u87 u88 u89 u90 u91 u92 u93 u94 u95 u96 u97 u98 u99 u100) {user: user, max-id: total-tokens, level: u0}))
    )
    (get level max-level)
  )
)

(define-private (check-user-token-level (token-id uint) (acc {user: principal, max-id: uint, level: uint}))
  (if (and (<= token-id (get max-id acc)) (is-owner (get user acc) token-id))
    (let 
      (
        (token-data (unwrap-panic (map-get? tokens token-id)))
        (token-level (get access-level token-data))
        (current-max (get level acc))
      )
      (merge acc {level: (if (> token-level current-max) token-level current-max)})
    )
    acc
  )
)

(define-private (is-owner (user principal) (token-id uint))
  (match (map-get? tokens token-id)
    token-data (is-eq user (get owner token-data))
    false
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
    (var-set contract-uri uri)
    (ok true)
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
          (let 
            (
              (existing-access (map-get? resource-access {resource-id: resource-id, user: user}))
              (current-count (match existing-access
                access-data (get access-count access-data)
                u0))
            )
            (map-set resource-access {resource-id: resource-id, user: user}
              {
                granted-at: stacks-block-height,
                expires-at: none,
                access-count: (+ current-count u1)
              }
            )
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
    (var-set access-fee new-fee)
    (ok true)
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


(define-map token-delegations {token-id: uint, delegatee: principal}
  {
    delegator: principal,
    expires-at: uint,
    created-at: uint,
    active: bool
  }
)

(define-map user-delegations principal (list 50 uint))


(define-read-only (has-delegated-access (user principal) (token-id uint))
  (match (map-get? token-delegations {token-id: token-id, delegatee: user})
    delegation-data
      (and 
        (get active delegation-data)
        (> (get expires-at delegation-data) stacks-block-height)
      )
    false
  )
)

(define-read-only (get-delegation-info (token-id uint) (delegatee principal))
  (map-get? token-delegations {token-id: token-id, delegatee: delegatee})
)


(define-read-only (get-effective-access-level (user principal))
  (let 
    (
      (owned-level (get-user-access-level user))
      (delegated-tokens (default-to (list) (map-get? user-delegations user)))
      (delegated-level (fold check-delegated-token-level delegated-tokens u0))
    )
    (if (> delegated-level owned-level) delegated-level owned-level)
  )
)

(define-private (check-delegated-token-level (token-id uint) (current-max uint))
  (if (has-delegated-access tx-sender token-id)
    (match (map-get? tokens token-id)
      token-data
        (let ((token-level (get access-level token-data)))
          (if (> token-level current-max) token-level current-max)
        )
      current-max
    )
    current-max
  )
)


(define-public (delegate-token (token-id uint) (delegatee principal) (duration uint))
  (let 
    (
      (expires-at (+ stacks-block-height duration))
    )
    (asserts! (is-owner tx-sender token-id) err-not-authorized)
    (asserts! (not (is-eq tx-sender delegatee)) err-invalid-delegation)
    (asserts! (> duration u0) err-invalid-delegation)
    (map-set token-delegations {token-id: token-id, delegatee: delegatee}
      {
        delegator: tx-sender,
        expires-at: expires-at,
        created-at: stacks-block-height,
        active: true
      }
    )
    (map-set user-delegations delegatee
      (unwrap! (as-max-len? (append (default-to (list) (map-get? user-delegations delegatee)) token-id) u50) err-invalid-delegation)
    )
    (ok expires-at)
  )
)


(define-public (revoke-delegation (token-id uint) (delegatee principal))
  (begin
    (asserts! (is-owner tx-sender token-id) err-not-authorized)
    (map-delete token-delegations {token-id: token-id, delegatee: delegatee})
    (ok true)
  )
)


(define-read-only (can-access-resource-enhanced (user principal) (resource-id uint))
  (match (map-get? resources resource-id)
    resource-data
      (let 
        (
          (required-level (get required-access-level resource-data))
          (user-level (get-effective-access-level user))
          (is-active (get active resource-data))
        )
        (and is-active (>= user-level required-level))
      )
    false
  )
)

(define-map resource-subscriptions {resource-id: uint, user: principal}
  {
    expires-at: uint,
    created-at: uint,
    renewed-count: uint,
    subscription-type: (string-ascii 32)
  }
)

(define-map subscription-plans uint
  {
    resource-id: uint,
    duration: uint,
    price: uint,
    plan-name: (string-ascii 32),
    active: bool
  }
)

(define-data-var last-plan-id uint u0)

(define-read-only (has-active-subscription (user principal) (resource-id uint))
  (match (map-get? resource-subscriptions {resource-id: resource-id, user: user})
    subscription-data
      (> (get expires-at subscription-data) stacks-block-height)
    false
  )
)

(define-read-only (get-subscription-info (user principal) (resource-id uint))
  (map-get? resource-subscriptions {resource-id: resource-id, user: user})
)

(define-read-only (get-plan-info (plan-id uint))
  (map-get? subscription-plans plan-id)
)

(define-public (create-subscription-plan (resource-id uint) (duration uint) (price uint) (plan-name (string-ascii 32)))
  (let ((plan-id (+ (var-get last-plan-id) u1)))
    (asserts! (is-some (map-get? resources resource-id)) err-invalid-resource)
    (asserts! (> duration u0) err-invalid-duration)
    (map-set subscription-plans plan-id
      {
        resource-id: resource-id,
        duration: duration,
        price: price,
        plan-name: plan-name,
        active: true
      }
    )
    (var-set last-plan-id plan-id)
    (ok plan-id)
  )
)

(define-public (subscribe-to-resource (plan-id uint))
  (match (map-get? subscription-plans plan-id)
    plan-data
      (let 
        (
          (resource-id (get resource-id plan-data))
          (duration (get duration plan-data))
          (expires-at (+ stacks-block-height duration))
          (existing-sub (map-get? resource-subscriptions {resource-id: resource-id, user: tx-sender}))
        )
        (asserts! (get active plan-data) err-not-found)
        (map-set resource-subscriptions {resource-id: resource-id, user: tx-sender}
          {
            expires-at: expires-at,
            created-at: stacks-block-height,
            renewed-count: (match existing-sub sub-data (+ (get renewed-count sub-data) u1) u0),
            subscription-type: (get plan-name plan-data)
          }
        )
        (ok expires-at)
      )
    err-not-found
  )
)

(define-read-only (can-access-resource-with-subscription (user principal) (resource-id uint))
  (or 
    (can-access-resource-enhanced user resource-id)
    (has-active-subscription user resource-id)
  )
)

(define-map user-reputation principal
  {
    total-score: uint,
    last-activity: uint,
    resource-access-count: uint,
    token-transfer-count: uint,
    streak-days: uint,
    bonus-level: uint
  }
)

(define-map daily-activity {user: principal, day: uint} bool)
(define-data-var reputation-multiplier uint u10)

(define-read-only (get-reputation-info (user principal))
  (default-to 
    {total-score: u0, last-activity: u0, resource-access-count: u0, 
     token-transfer-count: u0, streak-days: u0, bonus-level: u0}
    (map-get? user-reputation user)
  )
)

(define-read-only (calculate-reputation-bonus (user principal))
  (let ((rep-data (get-reputation-info user)))
    (if (> (get total-score rep-data) u1000)
        (if (> (get streak-days rep-data) u7) u3
            (if (> (get streak-days rep-data) u3) u2 u1))
        u0)
  )
)

(define-read-only (get-enhanced-access-level (user principal))
  (let 
    ((base-level (get-effective-access-level user))
     (reputation-bonus (calculate-reputation-bonus user)))
    (+ base-level reputation-bonus)
  )
)

(define-private (update-reputation (user principal) (activity-type (string-ascii 20)) (points uint))
  (let 
    ((current-rep (get-reputation-info user))
     (current-day (/ stacks-block-height u144))
     (last-day (/ (get last-activity current-rep) u144))
     (new-streak (if (is-eq (+ last-day u1) current-day) 
                     (+ (get streak-days current-rep) u1) 
                     (if (is-eq last-day current-day) (get streak-days current-rep) u1))))
    (map-set user-reputation user
      {
        total-score: (+ (get total-score current-rep) points),
        last-activity: stacks-block-height,
        resource-access-count: (if (is-eq activity-type "resource-access") 
                                   (+ (get resource-access-count current-rep) u1)
                                   (get resource-access-count current-rep)),
        token-transfer-count: (if (is-eq activity-type "token-transfer")
                                  (+ (get token-transfer-count current-rep) u1)
                                  (get token-transfer-count current-rep)),
        streak-days: new-streak,
        bonus-level: (calculate-reputation-bonus user)
      }
    )
    (map-set daily-activity {user: user, day: current-day} true)
  )
)

(define-public (request-access-with-reputation (resource-id uint))
  (let ((user tx-sender))
    (asserts! (>= (get-enhanced-access-level user) 
                  (unwrap! (get required-access-level (map-get? resources resource-id)) err-invalid-resource))
              err-access-denied)
    (try! (request-access resource-id))
    (update-reputation user "resource-access" (* (var-get reputation-multiplier) u5))
    (ok true)
  )
)

(define-public (transfer-with-reputation (token-id uint) (sender principal) (recipient principal))
  (begin
    (try! (transfer token-id sender recipient))
    (update-reputation sender "token-transfer" (* (var-get reputation-multiplier) u2))
    (update-reputation recipient "token-receive" (var-get reputation-multiplier))
    (ok true)
  )
)

(define-public (set-reputation-multiplier (new-multiplier uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set reputation-multiplier new-multiplier)
    (ok true)
  )
)


(define-map resource-co-owners {resource-id: uint, owner: principal}
  {
    share-percentage: uint,
    earnings-balance: uint,
    joined-at: uint,
    active: bool
  }
)

(define-map resource-owner-list uint (list 10 principal))
(define-map resource-total-earnings uint uint)
(define-map resource-withdrawal-count uint uint)

(define-read-only (get-co-owner-info (resource-id uint) (owner principal))
  (map-get? resource-co-owners {resource-id: resource-id, owner: owner})
)

(define-read-only (get-owner-list (resource-id uint))
  (default-to (list) (map-get? resource-owner-list resource-id))
)

(define-read-only (get-total-earnings (resource-id uint))
  (default-to u0 (map-get? resource-total-earnings resource-id))
)

(define-read-only (calculate-owner-share (resource-id uint) (owner principal) (total-amount uint))
  (match (map-get? resource-co-owners {resource-id: resource-id, owner: owner})
    co-owner-data
      (/ (* total-amount (get share-percentage co-owner-data)) u100)
    u0
  )
)

(define-public (add-co-owner (resource-id uint) (new-owner principal) (share-percentage uint))
  (let
    (
      (current-owners (get-owner-list resource-id))
      (existing-data (map-get? resource-co-owners {resource-id: resource-id, owner: tx-sender}))
    )
    (asserts! (is-some existing-data) err-not-co-owner)
    (asserts! (< (len current-owners) u10) err-too-many-owners)
    (asserts! (and (> share-percentage u0) (<= share-percentage u100)) err-invalid-shares)
    (asserts! (is-none (map-get? resource-co-owners {resource-id: resource-id, owner: new-owner})) err-already-co-owner)
    (map-set resource-co-owners {resource-id: resource-id, owner: new-owner}
      {
        share-percentage: share-percentage,
        earnings-balance: u0,
        joined-at: stacks-block-height,
        active: true
      }
    )
    (map-set resource-owner-list resource-id
      (unwrap! (as-max-len? (append current-owners new-owner) u10) err-too-many-owners)
    )
    (ok true)
  )
)

(define-public (distribute-earnings (resource-id uint) (amount uint))
  (let ((owners (get-owner-list resource-id)))
    (map-set resource-total-earnings resource-id (+ (get-total-earnings resource-id) amount))
    (ok (fold distribute-to-owner owners {resource-id: resource-id, amount: amount}))
  )
)

(define-private (distribute-to-owner (owner principal) (context {resource-id: uint, amount: uint}))
  (let
    (
      (resource-id (get resource-id context))
      (total-amount (get amount context))
      (owner-share (calculate-owner-share resource-id owner total-amount))
    )
    (match (map-get? resource-co-owners {resource-id: resource-id, owner: owner})
      co-owner-data
        (if (get active co-owner-data)
          (map-set resource-co-owners {resource-id: resource-id, owner: owner}
            (merge co-owner-data {earnings-balance: (+ (get earnings-balance co-owner-data) owner-share)})
          )
          false
        )
      false
    )
    context
  )
)

(define-public (withdraw-earnings (resource-id uint))
  (match (map-get? resource-co-owners {resource-id: resource-id, owner: tx-sender})
    co-owner-data
      (let ((balance (get earnings-balance co-owner-data)))
        (asserts! (> balance u0) err-no-balance)
        (map-set resource-co-owners {resource-id: resource-id, owner: tx-sender}
          (merge co-owner-data {earnings-balance: u0})
        )
        (map-set resource-withdrawal-count resource-id 
          (+ (default-to u0 (map-get? resource-withdrawal-count resource-id)) u1)
        )
        (ok balance)
      )
    err-not-co-owner
  )
)