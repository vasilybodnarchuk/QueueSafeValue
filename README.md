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
    
7. #### Available different value manipulation commands

    *atomic command:* `queueSafeValue.wait.lowestPriority.get()`
   
   *value processing command in a closure:* ` queueSafeValue.wait.lowestPriority.get { result in ... }`
   
   *value accessing command in a closure:* ` queueSafeValue.wait.lowestPriority.set { currentValue in currentVaule = newValue }`

## Documentation

#### Base structure of command

`queueSafeValue.{schedule}.{priority}.{command}`

### Definitions:

## 🇨​​​​​🇴​​​​​🇲​​​​​🇲​​​​​🇦​​​​​🇳​​​​​🇩 &nbsp; 🇶​​​​​🇺​​​​​🇪​​​​​🇺​​​​​🇪​​​​​

- stores `commands` and executes them sequentially with the correct priority.
-  `QueueSafeValue` has a built-in `command queue` (`priority queue`) where all 
-  `closures` (`commands`) will be placed and perfomed after. 

## 🇨​​​​​🇴​​​​​🇲​​​​​🇲​​​​​🇦​​​​​🇳​​​​​🇩 &nbsp; 🇨​​​​​🇱​​​​​🇴​​​​​🇸​​​​​🇺​​​​​🇷​​​​​🇪​​​​​

- is a closure inside which the value is accessed
- protected from concurrent access to `value` (works as `critical section`, implementation based on `DispatchGroup`)

*Available command closures*: 
- `commandClosure` - default closure that expects to work with serial code within itself 
- `manually completed commandClosure` -  closure that expects to work with serial / asynchronous code within itself. This closure must be completed manually by calling the `CommandCompletionClosure`, placed as a property inside `commandClosure`

## 🇦​​​​​🇨​​​​​🇨​​​​​🇪​​​​​🇸​​​​​🇸 &nbsp; 🇨​​​​​🇱​​​​​🇴​​​​​🇸​​​​​🇺​​​​​🇷​​​​​🇪​​​​​

- same as `commandClosure`, but has direct access to the value (using the `input` keyword)

## 🇨​​​​​🇴​​​​​🇲​​​​​🇲​​​​​🇦​​​​​🇳​​​​​🇩 &nbsp; ​​​​🇨​​​​​🇴​​​​​🇲​​​​​🇵​​​​​🇱​​​​​🇪​​​​​🇹​​​​​🇮​​​​​🇴​​​​​🇳 &nbsp; 🇨​​​​​​​​​​🇱​​​​​🇴​​​​​🇸​​​​​🇺​​​​​🇷​​​​​🇪​​​​​

- a closure that must always be performed (called) if available as a property inside the `commandClosure`

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

> describes what to do with `value` 

### Available synchronous commands: 

### 1. Synchronously `get` value

* returns `CurrentValue` or `QueueSafeValueError`
* is used when only the return `value` is required (no `value` processing)

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

### 2. Synchronously `get` value inside `commandClosure`

* returns `CurrentValue` or `QueueSafeValueError` inside `commandClosure`
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `commandClosure`
* `commandClosure` will be completed automatically

```Swift
func get(completion commandClosure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
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

### 3. Synchronously `get` value inside `commandClosure` with manual completion

* returns `CurrentValue` or `QueueSafeValueError` and  `CommandCompletionClosure` inside the `commandClosure`
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `commandClosure`
* **important**:  `commandClosure` must be completed manually by performing (calling) `CommandCompletionClosure`

```Swift
func get(manualCompletion commandClosure: ((Result<CurrentValue, QueueSafeValueError>,
                                            @escaping CommandCompletionClosure) -> Void)?)                                            
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 4.44)
DispatchQueue.global(qos: .unspecified).async {
    queueSafeValue.wait.highestPriority.get { result, done in
        switch result {
        case .failure(let error): print(error)
        case .success(let value): print(value)
        }
        done() // Must always be executed (called). Can be called in another DispatchQueue.
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: 4.45)
DispatchQueue.global(qos: .utility).async {
    queueSafeSyncedValue.highestPriority.get { result, done in
        switch result {
        case .failure(let error): print(error)
        case .success(let value): print(value)
        }
        done() // Must always be executed (called). Can be called in another DispatchQueue.
    }
}
```

### 4. Synchronously `set` value

* returns `UpdatedValue` or `QueueSafeValueError`
* is used when only the set of `value` is required (no `value` processing)

```Swift
@discardableResult
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

### 5. Synchronously `set` value inside the `accessClosure`

* sets `CurrentValue` inside the `accessClosure` 
* is used when it is necessary to both read and write a `value` inside one closure
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `accessClosure`
* **Attention**: `accessClosure` will not be run if any ` QueueSafeValueError` occurs

```Swift
@discardableResult
func set(completion accessClosure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError>
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 1)
DispatchQueue.main.async {
    let result = queueSafeValue.wait.lowestPriority.set { $0 = 3 }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: ["a":1])
DispatchQueue.main.async {
    let result = queueSafeSyncedValue.lowestPriority.set { $0["b"] = 2 }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 6. Synchronously `set` value inside the `accessClosure` with manual completion

* sets `CurrentValue` inside the `accessClosure` 
* is used when it is necessary to both read and write a `value` inside one closure
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `accessClosure`
* **important**:  `accessClosure` must be completed manually by performing (calling) `CommandCompletionClosure`
* **Attention**: `accessClosure` will not be run if any ` QueueSafeValueError` occurs.

```Swift
@discardableResult
func set(manualCompletion accessClosure: ((inout CurrentValue, 
                                           @escaping CommandCompletionClosure) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError>
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: "value 1")
DispatchQueue.main.async {
    let result = queueSafeValue.wait.lowestPriority.set { currentValue, done in
        currentValue = "value 2"
        done() // Must always be executed (called). Can be called in another DispatchQueue.
    }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: "value a")
DispatchQueue.main.async {
    let result = queueSafeSyncedValue.lowestPriority.set { currentValue, done in
        currentValue = "value b"
        done() // Must always be executed (called). Can be called in another DispatchQueue.
    }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 7. Synchronously `map` value inside a `commandClosure` 

* maps (transforms) `CurrentValue` to `MappedValue` inside the `commandClosure` 
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `commandClosure`

```Swift
func map<MappedValue>(completion commandClosure: ((CurrentValue) -> MappedValue)?) -> Result<MappedValue, QueueSafeValueError>
```

> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: 5)
DispatchQueue.global(qos: .background).async {
    let result = queueSafeValue.wait.lowestPriority.map { "\($0)" }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2
let queueSafeSyncedValue = QueueSafeSyncedValue(value: "1")
DispatchQueue.global(qos: .background).async {
    let result = queueSafeSyncedValue.lowestPriority.map { Int($0) }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(String(describing: value))
    }
}
```

### Available asynchronous commands: 

### 1. Asynchronously `get` value inside `commandClosure`

* returns `CurrentValue` or `QueueSafeValueError` inside the `commandClosure`
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `commandClosure`
* `commandClosure` will be completed automatically

```Swift
func get(completion commandClosure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
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
### 2. Asynchronously `get` value inside `commandClosure` with manual completion

* returns `CurrentValue` or `QueueSafeValueError` and  `CommandCompletionClosure` inside the `commandClosure`
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `commandClosure`
* **important**:  `commandClosure` must be completed manually by performing (calling) `CommandCompletionClosure`


```Swift
func get(manualCompletion commandClosure: ((Result<CurrentValue, QueueSafeValueError>,
                                            @escaping CommandCompletionClosure) -> Void)?)
```
> Code sample

```Swift
// Option 1
let queueSafeValue = QueueSafeValue(value: "test")
queueSafeValue.async(performIn: .global(qos: .utility)).highestPriority.get { result, done in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
    done() // Must always be executed (called). Can be called in another DispatchQueue.
}

// Option 2
let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: "super test", queue: .global(qos: .background))
queueSafeAsyncedValue.highestPriority.get { result, done in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
    done() // Must always be executed (called). Can be called in another DispatchQueue.
}
```

### 3. Asynchronously `set` 

* returns `UpdatedValue` or `QueueSafeValueError` inside the `commandClosure`
* is used when only the set of `value` is required (no `value` processing)

```Swift
func set(newValue: Value, completion commandClosure: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
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

### 4. Asynchronously `set` value inside the `accessClosure`

* sets `CurrentValue` inside the `accessClosure` 
* is used when it is necessary to both read and write a `value` inside one closure
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `accessClosure`
* **Attention**: `accessClosure` will not be run if any ` QueueSafeValueError` occurs

```Swift
func set(accessClosure: ((inout CurrentValue) -> Void)?,
         completion commandClosure: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```

> Code sample

```Swift
// Option 1.
let queueSafeValue = QueueSafeValue(value: 1)

// Without completion block
queueSafeValue.async(performIn: .background).highestPriority.set { $0 = 10 }

// With completion block
queueSafeValue.async(performIn: .background).highestPriority.set { currentValue in
    currentValue = 11
} completion: { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2.
let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: 1, queue: .global(qos: .userInteractive))

// Without completion block
queueSafeAsyncedValue.highestPriority.set { $0 = 10 }

// With completion block
queueSafeAsyncedValue.highestPriority.set { currentValue in
    currentValue = 11
} completion: { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```
### 5. Asynchronously `set` value inside the `accessClosure` with manual completion

* sets `CurrentValue` inside the `accessClosure` 
* is used when it is necessary to both read and write a `value` inside one closure
* is used as a `critical section` when it is necessary to hold reading / writing of the `value` while it is processed in the `accessClosure`
* **important**:  `accessClosure` must be completed manually by performing (calling) `CommandCompletionClosure`
* **Attention**: `accessClosure` will not be run if any ` QueueSafeValueError` occurs.

```Swift
func set(manualCompletion accessClosure: ((inout CurrentValue, @escaping CommandCompletionClosure) -> Void)?,
         completion commandClosure: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil) 
```

> Code sample

```Swift
// Option 1.
let queueSafeValue = QueueSafeValue(value: 999.1)

// Without completion block
queueSafeValue.async(performIn: .background).highestPriority.set { currentValue, done in
    currentValue = 999.2
    done() // Must always be executed (called). Can be called in another DispatchQueue.
}

// With completion block
queueSafeValue.async(performIn: .background).highestPriority.set { currentValue, done in
    currentValue = 999.3
    done() // Must always be executed (called). Can be called in another DispatchQueue.
} completion: { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}

// Option 2.
let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: 1000.1, queue: .global(qos: .userInteractive))

// Without completion block
queueSafeAsyncedValue.highestPriority.set { currentValue, done in
    currentValue = 1000.2
    done() // Must always be executed (called). Can be called in another DispatchQueue.
}

// With completion block
queueSafeAsyncedValue.highestPriority.set { currentValue, done in
    currentValue = 1000.3
    done() // Must always be executed (called). Can be called in another DispatchQueue.
} completion: { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
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
