# QueueSafeValue

![Build&Test](https://github.com/vasilybodnarchuk/QueueSafeValue/workflows/Build&Test/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![License](https://img.shields.io/cocoapods/l/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![Platform](https://img.shields.io/cocoapods/p/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)

## Documentation

To run the example project, clone the repo, and run `pod install` from the Example directory first.

#### Create QueueSafeValue

```Swift
let queueSafeValue = QueueSafeValue(value: 0)
```
___

### Base structure of command

`queueSafeValue.{schedule}.{priority}.{action}`

### Components:

#### { schedule }

> describes will func be executed synchronously or asynchronously. 

*Available schedules*: 
- `wait` - performs action sequentially (Blocks the queue where this code runs until it completed).

#### { priority }

> describes when (in what order) the function will be executed. 
> `QueueSafeValue` has a built-in command stack where all closures will be pushed. Every closure on that stack will be executed sequentially.
> `priority` means position of a closure in the command stack.

*Available orders*: 
- `lowPriority` - adds a closure to the end of a command stack
    
#### { action }
> describes what to do with value 

*Available sync actions*: 

- `get` - returns `CurrentValue` or `QueueSafeValueError`
```Swift
func get() -> Result<CurrentValue, QueueSafeValueError> { execute { $0 } }
```
- `get` - returns `CurrentValue` or `QueueSafeValueError` in closure
```Swift
func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
```

- `set` - sets `value`
```Swift
func set(newValue: Value) -> Result<UpdatedValue, QueueSafeValueError>
```
- `update` - updates `CurrentValue` in closure. Useful when processing a value from multiple code codes
```Swift
func update(closure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError>
```

- `transform` -  transforms value without changing original instance
```Swift
func transform<TransformedValue>(closure: ((CurrentValue) -> TransformedValue)?) -> Result<TransformedValue, QueueSafeValueError>
```

*Available async actions*: 

- `get` - asynchronously returns the `value` in a `closure`
```Swift
func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?)
```
- `set` - asynchronously sets `value`
```Swift
`func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```
- `update` - asynchronously updates `value` in closure. 
```Swift
func update(closure: ((inout CurrentValue) -> Void)?, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil)
```

## Examples

```Swift
private func getSample() {
    let atomicValue = QueueSafeValue(value: true)
    print(atomicValue.wait.lowPriority.get())                   // Optional(true)
}

private func setSample() {
    let atomicValue = QueueSafeValue<Int>(value: 1)
    atomicValue.wait.lowPriority.set(value: 2)
    print(atomicValue.wait.lowPriority.get())                   // Optional(2)
}

private func updateSample() {
    let atomicValue = QueueSafeValue(value: 1)
    atomicValue.wait.lowPriority.update { $0 = 3 }
    print(atomicValue.wait.lowPriority.get())                   // Optional(3)
}

private func updatedSample() {
    let atomicValue = QueueSafeValue(value: 1)
    print(atomicValue.wait.lowPriority.updated { $0 = 4 })       // Optional(4)
}

private func performSample() {
    let atomicValue = QueueSafeValue(value: 6)
    atomicValue.wait.lowPriority.perform { print($0) }           // 6
}

private func transformSample() {
    let atomicValue = QueueSafeValue(value: 5)
    print(atomicValue.wait.lowPriority.transform { "\($0)" })   // Optional("5")
}
```
    
## Requirements

iOS 8.0+
Xcode 10 +

## Installation

QueueSafeValue is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'QueueSafeValue'
```

## Author

Vasily Bodnarchuk, https://www.linkedin.com/in/vasily-bodnarchuk/

## License

QueueSafeValue is available under the MIT license. See the LICENSE file for more info.
