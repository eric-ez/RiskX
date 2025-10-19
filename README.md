# RiskX

RiskX is a decentralized insurance smart contract that enables the creation, purchase, and claim of on-chain insurance policies. It automates premium collection, policy tracking, and payout execution while maintaining transparency through immutable blockchain records.

---

## Overview

RiskX brings traditional insurance concepts to a decentralized environment. The contract allows an administrator to define policies and users to purchase coverage, paying premiums directly in STX. It manages an insurance fund from which valid claims are paid out, ensuring all operations are verifiable on-chain.

---

## Core Features

* On-chain policy creation, purchase, and claim management
* Automated premium calculation and fund updates
* Transparent claim payout mechanism
* Fund tracking with real-time visibility
* Parameter safeguards for maximum coverage, duration, and minimum premium

---

## Constants

| Constant                   | Description                                                     |
| -------------------------- | --------------------------------------------------------------- |
| `contract-owner`           | The administrator who can create insurance policy templates.    |
| `err-owner-only`           | Raised when a non-admin attempts to perform restricted actions. |
| `err-invalid-claim`        | Raised when a claim exceeds coverage or violates policy terms.  |
| `err-insufficient-payment` | Raised if a claim payout cannot be processed.                   |
| `err-not-insured`          | Raised when a non-policyholder tries to file a claim.           |
| `err-invalid-params`       | Raised when supplied parameters are outside allowed bounds.     |
| `max-coverage`             | Maximum allowable coverage for any policy.                      |
| `max-duration`             | Maximum policy duration (approx. one year in blocks).           |
| `min-premium`              | Minimum premium amount required for any policy.                 |

---

## Data Maps

| Map                  | Key         | Description                                                                            |
| -------------------- | ----------- | -------------------------------------------------------------------------------------- |
| `insurance-policies` | `principal` | Stores each user's active policy details, including coverage, premium, and expiration. |
| `insurance-claims`   | `principal` | Tracks filed claims and their statuses.                                                |

---

## Variables

| Variable         | Type | Description                                                                        |
| ---------------- | ---- | ---------------------------------------------------------------------------------- |
| `insurance-fund` | uint | Represents the total available STX balance held by the contract for claim payouts. |

---

## Public Functions

### `create-policy (coverage-amount premium duration)`

Admin-only function that creates a new insurance policy structure.

**Checks:**

* Caller must be `contract-owner`.
* Coverage ≤ `max-coverage`.
* Premium ≥ `min-premium`.
* Duration ≤ `max-duration`.

**Returns:** `(ok true)`

---

### `purchase-policy (coverage-amount duration)`

Allows users to purchase insurance coverage. Premiums are automatically calculated and transferred to the contract.

**Logic:**

* Calculates `policy-premium = coverage-amount * (1/100) * duration`
* Transfers premium to the contract
* Stores the user's policy details
* Updates the total `insurance-fund`

**Returns:** `(ok true)`

---

### `file-claim (amount)`

Lets a policyholder submit a claim request for a payout.

**Logic:**

* Validates claimant’s policy and amount
* Ensures sufficient fund availability
* Executes STX payout to the claimant
* Records claim details and marks as complete

**Returns:** `(ok true)`

---

## Read-Only Functions

| Function                       | Description                                                |
| ------------------------------ | ---------------------------------------------------------- |
| `get-policy-details (owner)`   | Returns the insurance policy details of a given principal. |
| `get-claim-details (claimant)` | Returns claim information and status for a user.           |
| `get-fund-balance`             | Displays the total STX held in the insurance fund.         |

---

## Workflow Summary

1. **Admin Setup**

   * The `contract-owner` defines available policy templates with coverage, premium, and duration constraints.

2. **User Purchase**

   * Users call `purchase-policy` to buy coverage, transferring the premium to the contract.

3. **Claim Filing**

   * Insured users can call `file-claim` to request compensation, subject to policy and fund conditions.

4. **Fund Management**

   * The insurance fund automatically updates with each premium payment and claim payout.

---

## Summary

RiskX provides a transparent and autonomous framework for decentralized insurance. By automating policy creation, payment processing, and claim settlements through smart contracts, it removes intermediaries while ensuring fairness and security across all participants.
