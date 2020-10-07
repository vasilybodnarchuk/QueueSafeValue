//
//  SyncedCommandsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 6/30/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/**
 Defines the available functions that can manipulate an enclosed `value`.
 All functions will run synchronously on the queue that calls them.
 */
public class SyncedCommandsWithPriority<Value>: CommandsWithPriority<Value> {

    /**
     Queue-safe (thread-safe) `value` reading.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Returns: enum instance that contains `CurrentValue` or `QueueSafeValueError`.
     */
    public func get() -> Result<CurrentValue, QueueSafeValueError> { execute { $0 } }

    /**
     Queue-safe (thread-safe) `value` reading in closure.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure containing sequential code that updates the original nested `value`.
     */
    public func get(completion closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
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
     Queue-safe (thread-safe) `value` reading in closure that must be completed manually.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter manualCompletion: a closure with asynchronous code that updates the original nested `value`.
     */
    public func get(manualCompletion closure: ((Result<CurrentValue, QueueSafeValueError>, @escaping CompleteAction) -> Void)?) {
        manuallyCompleted { complete in
            self.get { result in closure?(result, complete) }
        }
    }

    /**
     Queue-safe (thread-safe) `value` writing.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter newValue: value to set
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
     Queue-safe (thread-safe) `value` updating.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure containing sequential code that updates the original nested `value`.
     - Attention: `closure` will not be run if any ` QueueSafeValueError` occurs.
     - Returns: enum instance that contains `UpdatedValue` or `QueueSafeValueError`.
     */
    @discardableResult
    public func update(completion closure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError> {
        execute { currentValue in
            closure?(&currentValue)
            return currentValue
        }
    }

    /**
     Queue-safe (thread-safe) `value` transforming.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure containing sequential code that updates the original nested `value`.
     - Returns: enum instance that contains `TransformedValue` or `QueueSafeValueError`.
     */
    public func transform<TransformedValue>(completion closure: ((CurrentValue) -> TransformedValue)?) -> Result<TransformedValue, QueueSafeValueError> {
        execute { closure!($0) }
    }

    /**
     Performs `command` synchronously in defined order.
     - Parameter command: a closure (block) that updates the original `value` instance, wrapped in a `ValueContainer` object.
     - Returns: enum instance that contains `ResultValue` or `QueueSafeValueError`.
     */

    @discardableResult
    func execute<ResultValue>(command: @escaping (inout CurrentValue) -> ResultValue) -> Result<ResultValue, QueueSafeValueError> {
        guard let valueContainer = valueContainer else { return .failure(.valueContainerDeinited) }
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var resultValue: ResultValue!
        executeInCommandQueue(valueContainer: valueContainer) { currentValue in
            resultValue = command(&currentValue)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return .success(resultValue)
    }

    /**
     Defines performing order.
     - Note: the func blocks a queue where this code runs until it completed.
     - Important: must be redefined (overridden).
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
        - command: a closure (block) that updates the original enclosed `value`.
     */
    func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) { fatalError() }
}
