//
//  AsyncedCommandsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/**
 Defines the available functions that can manipulate an enclosed `value`.
 All functions will run asynchronously on the queue that calls them.
 */
public class AsyncedCommandsWithPriority<Value>: CommandsWithPriority<Value> {

    /// A queue in which access to the `value` will be granted.
    let queue: DispatchQueue

    /**
     Initialize object with properties.
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
        - queue: a queue in which access to the `value` will be granted (where `command` will be executed)
     - Returns: an object that defines the available functions which can manipulate the nested `value`.
     */
    init(valueContainer: ValueContainer<Value>?, grantAccessIn queue: DispatchQueue) {
        self.queue = queue
        super.init(valueContainer: valueContainer)
    }

    /**
     Performs `command` asynchronously  in embeded `queue` in defined order.
     - Important: `command` will be executed asynchronously in the `CommandQueue`.
     - Parameters:
        - command: a closure that updates (provides access) the original `value` instance, wrapped in a `ValueContainer` object and returns `ResultValue`
        - completion: a closure that returns `ResultValue` on success or  `QueueSafeValueError` on fail.
     */

    func execute<ResultValue>(command: @escaping (inout CurrentValue) -> ResultValue,
                              completion: ((Result<ResultValue, QueueSafeValueError>) -> Void)?) {
        guard let valueContainer = valueContainer else {
            queue.async { completion?(.failure(.valueContainerDeinited)) }
            return
        }

        queue.async {
            self.executeInCommandQueue(valueContainer: valueContainer) { currentValue in
                let resultValue = command(&currentValue)
                completion?(.success(resultValue))
            }
        }
    }

    /**
     Defines performing order.
     - Note: `command` will be executed asynchronously in `CommandQueue`.
     - Important: must be redefined (overridden).
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides queue-safe (thread-safe) access to it.
        - command: a closure that updates (provides access) the original `value` instance, wrapped in a `ValueContainer` object.
     */
    func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) { fatalError() }
}

// MARK: Get commands
extension AsyncedCommandsWithPriority {

    /**
     Queue-safe (thread-safe) `value` getting command.
     - Important: the func will be executed asynchronously in the `CommandQueue`.
     - Parameter completion: a closure that returns the `CurrentValue` on success or  `QueueSafeValueError` on fail. Expected sequential code inside the `commandClosure`.
     */
    public func get(completion commandClosure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        execute(command: { $0 }, completion: commandClosure)
    }
}
    
// MARK: Change value commands
extension AsyncedCommandsWithPriority {

    /**
     Queue-safe (thread-safe) `value` setting command.
     - Important: the func will be executed asynchronously in the `CommandQueue`.
     - Parameters:
        - newValue: value to set.
        - completion: a closure that returns the `UpdatedValue` on success or  `QueueSafeValueError` on fail. Expected sequential code inside the `commandClosure`.
     */
    public func set(newValue: Value, completion commandClosure: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil) {
        execute(command: {
            $0 = newValue
            return $0
        }, completion: commandClosure)
    }

    /**
     Queue-safe (thread-safe) `value` updating command.
     - Important: the func will be executed asynchronously in `CommandQueue`.
     - Parameters:
        - accessClosure: a closure that provide access to the `CurrentValue`,  where it is possible to change the original instance of the `CurrentValue`. Expected sequential code inside the `accessClosure`.
        - completion: a closure that returns the `UpdatedValue` on success or  `QueueSafeValueError` on fail. Expected sequential code inside the `commandClosure`.
     - Attention: `accessClosure` will not be run if any ` QueueSafeValueError` occurs.
     */
    public func update(accessClosure: ((inout CurrentValue) -> Void)?,
                       completion commandClosure: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil) {
        execute(command: {
            accessClosure?(&$0)
            return $0
        }, completion: commandClosure)
    }
}
