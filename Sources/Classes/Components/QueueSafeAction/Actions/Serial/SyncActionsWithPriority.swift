//
//  SyncActionsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 6/30/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/**
 Describes the available functions that can manipulate a `value`, wrapped in a `ValueContainer` object.
 All functions will run synchronously on the queue that calls them.
 */
public class SyncActionsWithPriority<Value>: ActionsWithPriority<Value> {

    /**
     Thread-safe (queue-safe) `value` reading.
     - Important: Blocks a queue where this code runs until it completed.
     - Returns: enum instance that contains `CurrentValue` or `QueueSafeValueError`.
     */
    public func get() -> Result<CurrentValue, QueueSafeValueError> { execute { $0 } }

    /**
     Thread-safe (queue-safe) `value` writing.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter value: value to set
     - Returns: enum instance that contains `UpdatedValue` or `QueueSafeValueError`.
     */
    @discardableResult
    public func set(newValue: Value) -> Result<UpdatedValue, QueueSafeValueError> {
        execute { currentValue in
            currentValue = newValue
            return currentValue
        }
    }

    /**
     Thread-safe (queue-safe) `value` updating.
     - Important: Blocks a queue where this code runs until it completed..
     - Parameter closure: A block that updates the original `value` instance.
     - Attention: `closure` will not be run if any ` QueueSafeValueError` occurs.
     - Returns: enum instance that contains `UpdatedValue` or `QueueSafeValueError`.
     */
    @discardableResult
    public func update(closure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError> {
        execute { currentValue in
            closure?(&currentValue)
            return currentValue
        }
    }

    /**
     Thread-safe  (queue-safe) `value` transforming.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that transform the original `value` instance.
     - Returns: enum instance that contains `TransformedValue` or `QueueSafeValueError`.
     */
    public func transform<TransformedValue>(closure: ((CurrentValue) -> TransformedValue)?) -> Result<TransformedValue, QueueSafeValueError> {
        execute { closure!($0) }
    }

    /**
     Thread-safe (queue-safe) `value` manipulating.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    public func perform(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        let result = execute { currentValue -> Void in
            closure?(.success(currentValue))
            return Void()
        }
        switch result {
        case .failure(let error): closure?(.failure(error))
        default: break
        }
    }
    
    /**
     Performs `command` synchronously in defined order.
     - Parameter command: A block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object.
     - Returns: enum instance that contains `ResultValue` or `QueueSafeValueError`.
     */

    @discardableResult
    func execute<ResultValue>(command: @escaping (inout CurrentValue) -> ResultValue) -> Result<ResultValue, QueueSafeValueError> {
        guard let valueContainer = valueContainer else { return .failure(.valueContainerDeinited) }
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var resultValue: ResultValue!
        executeInCommandStack(valueContainer: valueContainer) { currentValue in
            resultValue = command(&currentValue)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return .success(resultValue)
    }

    /**
     Defines performing order.
     - Important: Blocks a queue where this code runs until it completed.  Must be redefined (overridden).
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
        - command: A block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    func executeInCommandStack(valueContainer: Container, command: @escaping Container.Closure) { fatalError() }
}
