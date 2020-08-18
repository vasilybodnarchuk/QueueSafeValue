# QueueSafeValue

[![CI Status](https://img.shields.io/travis/vasilybodnarchuk/QueueSafeValue.svg?style=flat)](https://travis-ci.org/vasilybodnarchuk/QueueSafeValue)
[![Version](https://img.shields.io/cocoapods/v/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![License](https://img.shields.io/cocoapods/l/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)
[![Platform](https://img.shields.io/cocoapods/p/QueueSafeValue.svg?style=flat)](https://cocoapods.org/pods/QueueSafeValue)

## Example

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
> `QueueSafeValue` has a built-in stack where all closures will be pushed. Every closure on that stack will be executed sequentially.
> `priority` means position of a closure in the stack.

*Available orders*: 
- `lowPriority` - adds a closure to the end of a stack
    
#### { action }
> describes what to do with value 

*Available actions*: 
- `get` - returns wrapped value
> `func get() -> Value?`
- `set` - sets value
> `func set(value: Value)`
- `update` - updates value in closure
> `func update(closure: ((_ currentValue: inout Value) -> Void)?)`
- `updated` - updates value in closure and returns updated value
> `func updated(closure: ((_ currentValue: inout Value) -> Void)?)` 
-  `perform` - do something with value without changing it
> `func perform(closure: ((Value) -> Void)?)`
- `transform` -  transforms value without changing original instance
> `func transform<Output>(closure: ((_ currentValue: Value) -> Output)?)`
    
## Requirements

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
