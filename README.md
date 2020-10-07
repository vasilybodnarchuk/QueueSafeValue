# QueueSafeValue

![Build&Test](https://github.com/vasilybodnarchuk/QueueSafeValue/workflows/Build&Test/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![License](https://img.shields.io/cocoapods/l/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![Platform](https://img.shields.io/cocoapods/p/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)

Framework that provides thread-safe (queue-safe) access to the value. 

## Advantages
1. #### Embedded `DispatchSemaphore`

    *Just use specific access functions (`commands`) of a `QueueSafeValue` and don't think about thread synchronization.*
    
2. #### Built-in `scheduler`

    *Scheduler organises synchronous and asynchronous `commands` executing.*
    
3. #### Embedded `Comand Queue` (`Priority queue`)

    *`Command Queue` needed to organize the sequence of `commands`. All `commands` will be executed in order of priority, one after the other.*
    
4. #### Priority `command` execution

    *Ability to prioritize updates or access to `QueueSafeValue`. This means that some `commands` will run faster than others.*
    
5. #### Doesn't increment object reference count
    
6. #### Always returns a result and avoids returning optionals

    *always returns* `Result<Value, QueueSafeValueError>`
    
7. #### Implemented both atomic functions and value processing functions in a closure

    *atomic function:* `queueSafeValue.wait.lowestPriority.get()`
   
   *value processing function in a closure:* ` queueSafeValue.wait.lowestPriority.get { result in ... }`

## Documentation

#### Base structure of command

`queueSafeValue.{schedule}.{priority}.{command}`

### Definitions:

## 🇨​​​​​🇴​​​​​🇲​​​​​🇲​​​​​🇦​​​​​🇳​​​​​🇩​​​​​ 🇶​​​​​🇺​​​​​🇪​​​​​🇺​​​​​🇪​​​​​

> stores `commands` and executes them sequentially with the correct priority.
> `QueueSafeValue` has a built-in `command queue` (`priority queue`) where all 
> `closures` (`commands`) will be placed and perfomed after. 

### Request components:

## 🇸​​​​​🇨​​​​​🇭​​​​​🇪​​​​​🇩​​​​​🇺​​​​​🇱​​​​​🇪​​​​​

> describes will func be executed synchronously or asynchronously. 

*Available schedules*: 
- `wait` - (sync) performs `commands` sequentially. Blocks the queue where this code runs until it completed.
- `async` - performs a `command` asynchronously of the queue that calls this function.

## 🇵​​​​​🇷​​​​​🇮​​​​​🇴​​​​​🇷​​​​​🇮​​​​​🇹​​​​​🇾​​​​​

> describes when (in what order) `command` will be executed in `command queue`. 

*Available priorities*: 
- `lowestPriority` - a `command` with `lowest priority` will be executed last.
- `highestPriority` - a `command` with `highest priority` will be executed first.

## 🇨​​​​​🇴​​​​​🇲​​​​​🇲​​​​​🇦​​​​​🇳​​​​​🇩​​​​​

> describes what to do with value 

### Available synchronous commands: 

### 1. Synchronous `get` value

>  returns `CurrentValue` or `QueueSafeValueError`

```Swift
func get() -> Result<CurrentValue, QueueSafeValueError>
```
> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: true)
DispatchQueue.global(qos: .utility).async {
    let result = queueSafeValue.wait.lowestPriority.get()
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: "a")
DispatchQueue.global(qos: .utility).async {
    let result = queueSafeSyncedValue.lowestPriority.get()
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 2. Synchronous `get` value in closure

> returns `CurrentValue` or `QueueSafeValueError` in `command closure`

```Swift
func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 6)
DispatchQueue.global(qos: .unspecified).async {
    queueSafeValue.wait.lowestPriority.get { result in
        switch result {
        case .failure(let error): print(error)
        case .success(let value): print(value)
        }
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: [1,2,3])
DispatchQueue.global(qos: .utility).async {
    queueSafeSyncedValue.lowestPriority.get { result in
        switch result {
        case .failure(let error): print(error)
        case .success(let value): print(value)
        }
    }
}
```

### 3. Synchronous `get` value in closure with manual `command` completion

> returns `CurrentValue` or `QueueSafeValueError` and  `command completion closure` in `command closure`

```Swift
public func get(manualCompletion closure: ((Result<CurrentValue, QueueSafeValueError>, @escaping CommandCompletionClosure) -> Void)?)
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 4.44)
DispatchQueue.global(qos: .unspecified).async {
    queueSafeValue.wait.highestPriority.get { (result, complete) in
        switch result {
        case .failure(let error): print(error)
        case .success(let value): print(value)
        }
        complete() // should always be executed (called)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: 4.45)
DispatchQueue.global(qos: .utility).async {
    queueSafeSyncedValue.highestPriority.get { (result, complete) in
        switch result {
        case .failure(let error): print(error)
        case .success(let value): print(value)
        }
        complete() // should always be executed (called)
    }
}
```

### 4. Synchronous `set` 

> sets `value`

```Swift
func set(newValue: Value) -> Result<UpdatedValue, QueueSafeValueError>
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue<Int>(value: 1)
DispatchQueue.global(qos: .userInitiated).async {
    let result = queueSafeValue.wait.lowestPriority.set(newValue: 2)
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: "b")
DispatchQueue.global(qos: .userInitiated).async {
    let result = queueSafeSyncedValue.lowestPriority.set(newValue: "b1")
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 5. Synchronous `update` 

>  updates `CurrentValue` in closure.  Useful when processing / updating a value consists of multiple lines of code.

```Swift
func update(closure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError>
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 1)
DispatchQueue.main.async {
    let result = queueSafeValue.wait.lowestPriority.update { currentValue in
        currentValue = 3
    }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: ["a":1])
DispatchQueue.main.async {
    let result = queueSafeSyncedValue.lowestPriority.update { currentValue in
        currentValue["b"] = 2
    }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 6. Synchronous `transform` 

> transforms value without changing original instance

```Swift
func transform<TransformedValue>(closure: ((CurrentValue) -> TransformedValue)?) -> Result<TransformedValue, QueueSafeValueError>
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 5)
DispatchQueue.global(qos: .background).async {
    let result = queueSafeValue.wait.lowestPriority.transform { "\($0)" }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: "1")
DispatchQueue.global(qos: .background).async {
    let result = queueSafeSyncedValue.lowestPriority.transform { Int($0) }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(String(describing: value))
    }
}
```

### Available asynchronous commands: 

### 1. Asynchronous `get`

> asynchronously returns the `value` in a `closure`

```Swift
func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: true)
queueSafeValue.async(performIn: .global(qos: .utility)).highestPriority.get { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: true, queue: .global(qos: .utility))
queueSafeAsyncedValue.highestPriority.get { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 2. Asynchronous `set` 

> asynchronously sets `value`

```Swift
func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 7)

// Without completion block
queueSafeValue.async(performIn: .main).highestPriority.set(newValue: 8)

// With completion block
queueSafeValue.async(performIn: .main).highestPriority.set(newValue: 9) { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: 7, queue: .global())

// Without completion block
queueSafeAsyncedValue.highestPriority.set(newValue: 8)

// With completion block
queueSafeAsyncedValue.highestPriority.set(newValue: 9) { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 3. Asynchronous `update`

> asynchronously updates `value` in closure. 

```Swift
func update(closure: ((inout CurrentValue) -> Void)?, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```

> Code sample

```Swift
// Option 1.
let queueSafeValue = QueueSafeValue<Int>(value: 1)

// Without completion block
queueSafeValue.async(performIn: .background).highestPriority.update(closure: { currentValue in
    currentValue = 10
})

// With completion block
queueSafeValue.async(performIn: .background).highestPriority.update(closure: { currentValue in
    currentValue = 11
}, completion: { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
})

// Option 2.
let queueSafeAsyncedValue = QueueSafeAsyncedValue<Int>(value: 1, queue: .global(qos: .userInteractive))

// Without completion block
queueSafeAsyncedValue.highestPriority.update(closure: { currentValue in
    currentValue = 10
})

// With completion block
queueSafeAsyncedValue.highestPriority.update(closure: { currentValue in
    currentValue = 11
}, completion: { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
})
```
    
## Requirements

- iOS 8.0+
- Xcode 10+
- Swift 5.1+

## Installation

#### Step 1:

QueueSafeValue is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'QueueSafeValue'
```

#### Step 2:

run `pod install` in your project root folder

#### Step 3:

To use the installed `QueueSafeValue` framework, simply `import the QueueSafeValue` in the swift file in which you are going to apply it.

## Author

Vasily Bodnarchuk, https://www.linkedin.com/in/vasily-bodnarchuk/

## License

QueueSafeValue is available under the MIT license. See the LICENSE file for more info.
