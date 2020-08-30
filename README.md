# QueueSafeValue

![Build&Test](https://github.com/vasilybodnarchuk/QueueSafeValue/workflows/Build&Test/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![License](https://img.shields.io/cocoapods/l/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![Platform](https://img.shields.io/cocoapods/p/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)

Framework that provides thread-safe (queue-safe) access to the value. 

## Documentation

#### Base structure of command

`queueSafeValue.{schedule}.{priority}.{action}`

### Components:

#### 🇸​​​​​🇨​​​​​🇭​​​​​🇪​​​​​🇩​​​​​🇺​​​​​🇱​​​​​🇪​​​​​

> describes will func be executed synchronously or asynchronously. 

*Available schedules*: 
- `wait` - (sync) performs action sequentially. Blocks the queue where this code runs until it completed.
- `async` - performs a function asynchronously of the queue that calls this function.

#### 🇵​​​​​🇷​​​​​🇮​​​​​🇴​​​​​🇷​​​​​🇮​​​​​🇹​​​​​🇾​​​​​

> describes when (in what order) the function will be executed. 
> `QueueSafeValue` has a built-in `command stack` where all closures will be pushed. 
> Every closure on that stack will be executed sequentially.
> `priority` means position of a closure in the command stack.

*Available orders*: 
- `lowPriority` - adds a closure to the end of a `command stack`
    
#### 🇦​​​​​🇨​​​​​🇹​​​​​🇮​​​​​🇴​​​​​🇳​​​​​
> describes what to do with value 

*Available sync actions*: 

1. `get` - returns `CurrentValue` or `QueueSafeValueError`
```Swift
func get() -> Result<CurrentValue, QueueSafeValueError>
```

2. `get` - returns `CurrentValue` or `QueueSafeValueError` in closure
```Swift
func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
```

3. `set` - sets `value`
```Swift
func set(newValue: Value) -> Result<UpdatedValue, QueueSafeValueError>
```

4. `update` - updates `CurrentValue` in closure.  Useful when processing / updating a value consists of multiple lines of code.
```Swift
func update(closure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError>
```

5. `transform` -  transforms value without changing original instance
```Swift
func transform<TransformedValue>(closure: ((CurrentValue) -> TransformedValue)?) -> Result<TransformedValue, QueueSafeValueError>
```

*Available async actions*: 

1. `get` - asynchronously returns the `value` in a `closure`
```Swift
func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
```

2. `set` - asynchronously sets `value`
```Swift
`func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```

3. `update` - asynchronously updates `value` in closure. 
```Swift
func update(closure: ((inout CurrentValue) -> Void)?, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```

___

## Examples

```Swift
class Examples {
    func run() {
        runSyncActions()
        runAsyncActions()
    }
}

extension Examples {
    private func log<Value>(title: String, result: (Result<Value, QueueSafeValueError>)) {
        var description = "\"\(title)\" func result: "
        switch result {
        case .failure(let error): description += "\(error)"
        case .success(let value): description += "\(value)"
        }
        print(description + " or \(result)")
    }
}

/// MARK: Sync actions

extension Examples {
    func runSyncActions() {
        syncGetActionSample()
        syncGetInClosureActionSample()
        syncSetActionSample()
        syncUpdateActionSample()
        syncTransformActionSample()
    }
    
    private func syncGetActionSample() {
        let queueSafeValue = QueueSafeValue(value: true)
        DispatchQueue.global(qos: .utility).async {
            let result = queueSafeValue.wait.lowPriority.get()
            self.log(title: "Sync lowPriority get", result: result)
        }
    }
    
    private func syncGetInClosureActionSample() {
        let queueSafeValue = QueueSafeValue(value: 6)
        DispatchQueue.global(qos: .unspecified).async {
            queueSafeValue.wait.lowPriority.get { result in
                self.log(title: "Sync lowPriority get in closure", result: result)
            }
        }
    }
    
    private func syncSetActionSample() {
        let queueSafeValue = QueueSafeValue<Int>(value: 1)
        DispatchQueue.global(qos: .userInitiated).async {
            let result = queueSafeValue.wait.lowPriority.set(newValue: 2)
            self.log(title: "Sync lowPriority set", result: result)
        }
    }
    
    private func syncUpdateActionSample() {
        let queueSafeValue = QueueSafeValue(value: 1)
        DispatchQueue.main.async {
            let result = queueSafeValue.wait.lowPriority.update { currentValue in
                currentValue = 3
            }
            self.log(title: "Sync lowPriority update", result: result)
        }
    }
    
    private func syncTransformActionSample() {
        let queueSafeValue = QueueSafeValue(value: 5)
        DispatchQueue.global(qos: .background).async {
            let result = queueSafeValue.wait.lowPriority.transform { "\($0)" }
            self.log(title: "Sync lowPriority transform", result: result)
        }
    }
}

/// MARK: Async actions

extension Examples {
    func runAsyncActions() {
        asyncGetActionSample()
        asyncSetActionSample()
        asyncUpdateActionSample()
    }

    private func asyncGetActionSample() {
        let queueSafeValue = QueueSafeValue(value: true)
        queueSafeValue.async(performIn: .global(qos: .utility)).lowPriority.get { result in
            self.log(title: "Async lowPriority get", result: result)
        }
    }
    
    private func asyncSetActionSample() {
        let queueSafeValue = QueueSafeValue(value: 7)
        
        // Without completion block
        queueSafeValue.async(performIn: .main).lowPriority.set(newValue: 8)
        
        // With completion block
        queueSafeValue.async(performIn: .main).lowPriority.set(newValue: 9) { result in
            self.log(title: "Async lowPriority set", result: result)
        }
    }
    
    private func asyncUpdateActionSample() {
        let queueSafeValue = QueueSafeValue<Int>(value: 1)
        // Without completion block
        queueSafeValue.async(performIn: .background).lowPriority.update(closure: { currentValue in
            currentValue = 10
        })
        
        // With completion block
        queueSafeValue.async(performIn: .background).lowPriority.update(closure: { currentValue in
            currentValue = 11
        }, completion: { result in
            self.log(title: "Async lowPriority update", result: result)
        })
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
