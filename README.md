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

`queueSafeValue.{schedule}.{order}.{action}`

### Components:

#### { schedule }

> describes will func be executed synchronously or asynchronously. 

*Available schedules*: 
- `wait` - blocks the queue on which the given command is running until it completes

#### { order }

> describes when (in what order) the function will be executed. 

*Available orders*: 
- `performLast` - add a closure to the end of the command stack
    
#### { action }
> describes what to do with value 

*Available actions*: 
- `func get() -> Value?` - gat value
- `func set(value: Value)` - set value
- `update(closure: ((_ currentValue: inout Value) -> Void)?)` - update value in closure
- `updated(closure: ((_ currentValue: inout Value) -> Void)?)` - update value in closure and return updated value
- `func perform(closure: ((Value) -> Void)?)` - do something with value without changing it
- `func transform<Output>(closure: ((_ currentValue: Value) -> Output)?)` - transform value without changing original instance
    
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
