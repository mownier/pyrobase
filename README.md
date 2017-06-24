# Pyrobase
An iOS lightweight wrapper for Firebase REST API. For more Firebase's details, see it [here.](https://firebase.google.com/docs/reference/rest/database/) It is written in Swift and has 100% code coverage.

## Usage

### Authentication

Make sure to copy `PyroAuthInfo.plist`. And keep in mind the bundle identifier where the said file is added. 

#### Initialization
```swift
let apiKey = "yourFirebaseAPIKey"
let bundleIdentifier = "com.my.app"
let auth = PyroAuth.create(key: apiKey, bundleIdentifier: bundleIdentifier)
// The variable 'auth' is nil if you provide an invalid bundle identifier.
// Otherwise, you are good to go.
// NOTE: If you build this project as framework, you can opt out
//       providing the bundle identifier. The default value
//       is the project's bundle identifier
```

#### Sign In
```swift
auth.signIn(email: email, password: password) { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
        // 'data' is PyroAuthContent
    }
}
```

#### Register
```swift
auth.register(email: email, password: password) { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
        // 'data' is PyroAuthContent
    }
}
```

#### Refresh Token
```swift
auth.refresh(token: "refreshToken") { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
        // 'data' is PyroAuthTokenContent
    }
}
```

#### Send Password Reset
```swift
auth.sendPasswordReset(email: "me@me.com") { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
        // 'data' is Bool
    }
}
```

### REST

#### Initialization
```swift
let baseURL = "https://foo.firebaseio.com"
let accessToken = "accessToken"
let pyrobase = Pyrobase.create(baseURL: baseURL, accessToken: accessToken)
```

#### GET Request
```swift
pyrobase.get(path: "users/abcde12345wert", query: [:]) { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
    }
}
```

#### POST Request
```swift
pyrobase.post(path: "messages", value: ["message": "hello world", "user_id": "abcde12345qwert"]) { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
    }
}
```

#### PUT Request
```swift
pyrobase.put(path: "users/abcde12345wert", value: ["first_name": "Juan", "last_name": "Dela Cruz"]) { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
    }
}
```

#### PATCH Request
```swift
pyrobase.patch(path: "users/abcde12345wert", value: ["first_name": "Jose"]) { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
    }
}
```

### Transaction

#### Initialization
```swift
let baseURL = "https://foo.firebaseio.com"
let accessToken = "accessToken"
let transaction = PyroTransaction.create(baseURL: baseURL, accessToken: accessToken)
```
#### Run
```swift
transaction.run(
    parentPath: "posts/yuiop98765nbcwe",
    childKey: "likes_count", 
    mutator: { data in
    	let likesCount = data as! Int
    	return likesCount + 1
}) { result in
    switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
    }
}
```


### Event Source

#### Callback
```swift
class StreamCallback: PyroEventSourceCallback {

    func pyroEventSource(_ eventSource: PyroEventSource, didReceiveError error: Error) {
        // Do some stuff
    }
    
     func pyroEventSource(_ eventSource: PyroEventSource, didReceiveMessage message: PyroEventSourceMessage) {
        // Do some stuff
    }

    func pyroEventSourceOnOpen(_ eventSource: PyroEventSource) {
        // Do some stuff
    }
    
    func pyroEventSourceOnClosed(_ eventSource: PyroEventSource) {
        // Do some stuff
    }
    
    func pyroEventSourceOnConnecting(_ eventSource: PyroEventSource) {
        // Do some stuff
    }
}
```

#### Initialization
```swift
let callback = StreamCallback()
let baseURL = "https://foo.firebaseio.com"
let accessToken = "accessToken"
let eventSource = PyroEventSource.create(baseURL: baseURL, accessToken: accessToken)
eventSource.callback = callback
```

#### Stream
```swift
eventSource.stream("chat/rooms/hdjye53910kwdop")
```

#### Close
```swift
eventSource.close()
```

### Query Parameters
Always keep in mind of adding `.indexOn` in your rules for the path you want to query. You may receive a `badRequest` error if you don't set it.

```swift
let query = ["orderBy": "\"$key\"", "limitToFirst": 1]
pyrobase.get("posts", query: query) { result in
   switch result {
    case .failed(let error):
        print(error)
        // Do some stuff
            
    case .succeeded(let data):
        print(data)
        // Do some stuff
    }
}
```


### License

MIT License