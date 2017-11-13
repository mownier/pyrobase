# Changelog

## Build 1.0.1
- Improved usability of errors
- Added code and message property in `RequestError`
- `RequestError` implemented `Equatable` protocol
- `RequestError` is equal if code and message are the same
- Defined static message for `invalidURL`, `unparseableJSON`, `noURLResponse`, `nullJSON`, and `unknown` cases
- Defined code for `RequestError` cases

## Version 1.0
- Implemented simple Firebase REST API
- User can do authentication
- User can issue GET, POST, PUT, PATCH requests
- User can stream paths
- User can run transactions
