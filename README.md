# 🔐 Token-Gated Access Control

A Stacks blockchain smart contract that enables access control to digital resources and services based on NFT ownership. Users must own specific access tokens with appropriate access levels to interact with protected content.

## ✨ Features

- 🎫 **NFT-Based Access Control**: Grant access to resources based on NFT ownership
- 📊 **Tiered Access Levels**: Different access levels for various types of content
- 🏗️ **Resource Management**: Create and manage protected resources
- 📈 **Usage Analytics**: Track access patterns and usage statistics
- 🔥 **Token Burning**: Remove access by burning tokens
- 👥 **Multi-User Support**: Handle multiple users and resource creators

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing

### Installation

1. Clone this repository
2. Run clarinet tests:
```bash
clarinet test
```

## 📖 Usage

### For Contract Owners 👑

#### Mint Access Tokens
```clarity
(contract-call? .Token-Gated-Access-Control mint-access-token 
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE 
  (some "https://metadata-uri.com/token/1") 
  u3)
```

#### Set Contract URI
```clarity
(contract-call? .Token-Gated-Access-Control set-contract-uri 
  (some "https://contract-metadata.com"))
```

### For Resource Creators 🛠️

#### Create Protected Resources
```clarity
(contract-call? .Token-Gated-Access-Control create-resource 
  "Premium Course" 
  "Advanced blockchain development course" 
  u2)
```

#### Manage Resource Status
```clarity
(contract-call? .Token-Gated-Access-Control update-resource-status u1 false)
```

#### Revoke User Access
```clarity
(contract-call? .Token-Gated-Access-Control revoke-access 
  u1 
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

### For End Users 🎯

#### Request Resource Access
```clarity
(contract-call? .Token-Gated-Access-Control request-access u1)
```

#### Transfer Access Tokens
```clarity
(contract-call? .Token-Gated-Access-Control transfer 
  u1 
  tx-sender 
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

#### Burn Tokens
```clarity
(contract-call? .Token-Gated-Access-Control burn-token u1)
```

## 🔍 Query Functions

### Check Access Permissions
```clarity
(contract-call? .Token-Gated-Access-Control can-access-resource 
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE 
  u1)
```

### Get User Access Level
```clarity
(contract-call? .Token-Gated-Access-Control get-user-access-level 
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

### Get Token Information
```clarity
(contract-call? .Token-Gated-Access-Control get-token-info u1)
```

### Get Resource Details
```clarity
(contract-call? .Token-Gated-Access-Control get-resource-info u1)
```

### Get User's Access History
```clarity
(contract-call? .Token-Gated-Access-Control get-access-history 
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

## 📊 Access Levels

- **Level 0**: No access
- **Level 1**: Basic access 
- **Level 2**: Premium access
- **Level 3**: VIP access
- **Level 4+**: Custom tiers

## 🔧 Contract Architecture

The contract implements several key components:

- **NFT Management**: Handles minting, transferring, and burning of access tokens
- **Resource System**: Manages protected resources with access level requirements
- **Access Control**: Validates user permissions based on token ownership
- **Analytics**: Tracks usage patterns and access history

## 🧪 Testing

Run the test suite:
```bash
clarinet test
```

Example test scenarios:
- Minting access tokens with different levels
- Creating resources with various access requirements
- Testing access control validation
- Verifying transfer and burn functionality

## 🛡️ Security Features

- ✅ Owner-only functions for critical operations
- ✅ Access level validation
- ✅ Token ownership verification
- ✅ Resource creator permissions
- ✅ Comprehensive error handling

## 📄 Error Codes

- `u100`: Owner only operation
- `u101`: Not authorized
- `u102`: Invalid resource
- `u103`: Access denied
- `u104`: NFT not found
- `u105`: Invalid token ID
- `u106`: Already exists
- `u107`: Not found
- `u108`: Expired

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)
