# QueueSafeValue

![Build&Test](https://github.com/vasilybodnarchuk/QueueSafeValue/workflows/Build&Test/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![License](https://img.shields.io/cocoapods/l/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![Platform](https://img.shields.io/cocoapods/p/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)

Framework that provides thread-safe (queue-safe) access to the value. 

## Documentation

#### Base structure of command

`queueSafeValue.{schedule}.{priority}.{command}`

### Definitions:

## 🇨​​​​​🇴​​​​​🇲​​​​​🇲​​​​​🇦​​​​​🇳​​​​​🇩​​​​​ 🇶​​​​​🇺​​​​​🇪​​​​​🇺​​​​​🇪​​​​​

> stores `commands` and executes them sequentially with the correct priority.
> `QueueSafeValue` has a built-in `command queue` (priority queue) where all 
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
- `lowestPriority` - a `comand` with `lowest priority` will be executed last.
- `highestPriority` - a `comand` with `highest priority` will be executed first.

## 🇨​​​​​🇴​​​​​🇲​​​​​🇲​​​​​🇦​​​​​🇳​​​​​🇩​​​​​

> describes what to do with value 

### Available synchronous comands: 

### 1. Synchronous `get`

>  returns `CurrentValue` or `QueueSafeValueError`

```Swift
func get() -> Result<CurrentValue, QueueSafeValueError>
```
> Code sample

```Swift
let queueSafeValue = QueueSafeValue(value: true)
DispatchQueue.global(qos: .utility).async {
    let result = queueSafeValue.wait.lowestPriority.get()
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 2. Synchronous `get` in closure

> returns `CurrentValue` or `QueueSafeValueError` in closure

```Swift
func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
```

> Code sample

```Swift
let queueSafeValue = QueueSafeValue(value: 6)
DispatchQueue.global(qos: .unspecified).async {
    queueSafeValue.wait.lowestPriority.get { result in
        switch result {
        case .failure(let error): print(error)
        case .success(let value): print(value)
        }
    }
}
```

### 3. Synchronous `set` 

> sets `value`

```Swift
func set(newValue: Value) -> Result<UpdatedValue, QueueSafeValueError>
```

> Code sample

```Swift
let queueSafeValue = QueueSafeValue<Int>(value: 1)
DispatchQueue.global(qos: .userInitiated).async {
    let result = queueSafeValue.wait.lowestPriority.set(newValue: 2)
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 4. Synchronous `update` 

>  updates `CurrentValue` in closure.  Useful when processing / updating a value consists of multiple lines of code.

```Swift
func update(closure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError>
```

> Code sample

```Swift
let queueSafeValue = QueueSafeValue(value: 1)
DispatchQueue.global(qos: .userInitiated).async {
    let result = queueSafeValue.wait.lowestPriority.update { currentValue in
        currentValue = 3
    }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 5. Synchronous `transform` 

> transforms value without changing original instance

```Swift
func transform<TransformedValue>(closure: ((CurrentValue) -> TransformedValue)?) -> Result<TransformedValue, QueueSafeValueError>
```

> Code sample

```Swift
let queueSafeValue = QueueSafeValue(value: 5)
DispatchQueue.global(qos: .background).async {
    let result = queueSafeValue.wait.lowestPriority.transform { "\($0)" }
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
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
let queueSafeValue = QueueSafeValue(value: true)
queueSafeValue.async(performIn: .global(qos: .utility)).lowestPriority.get { result in
    switch result {
    case .failure(let error): print(error)
    case .success(let value): print(value)
    }
}
```

### 2. Asynchronous `set` 

> asynchronously sets `value`

```Swift
`func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```

> Code sample

```Swift
let queueSafeValue = QueueSafeValue(value: 7)

// Without completion block
queueSafeValue.async(performIn: .main).lowestPriority.set(newValue: 8)

// With completion block
queueSafeValue.async(performIn: .main).lowestPriority.set(newValue: 9) { result in
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
let queueSafeValue = QueueSafeValue<Int>(value: 1)

// Without completion block
queueSafeValue.async(performIn: .background).lowestPriority.update(closure: { currentValue in
    currentValue = 10
})

// With completion block
queueSafeValue.async(performIn: .background).lowestPriority.update(closure: { currentValue in
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
