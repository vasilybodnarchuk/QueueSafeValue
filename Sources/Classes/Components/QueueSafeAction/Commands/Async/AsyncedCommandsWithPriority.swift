//
//  AsyncedCommandsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/**
 Defines the available functions that can manipulate a `value`, wrapped in a `ValueContainer` object.
 All functions will run asynchronously on the queue that calls them.
 */
public class AsyncedCommandsWithPriority<Value>: CommandsWithPriority<Value> {

    /// A queue in which access to the `value` will be granted.
    let queue: DispatchQueue

    /**
     Initialize object with properties.
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
        - queue: a queue in which access to the `value` will be granted.
     - Returns: An object that  describes the available functions that can manipulate a `value`, wrapped in a `ValueContainer` object.
     */
    init(valueContainer: ValueContainer<Value>?, grantAccessIn queue: DispatchQueue) {
        self.queue = queue
        super.init(valueContainer: valueContainer)
    }

    /**
     Thread-safe (queue-safe) value reading.
     - Important: Will be executed asynchronously in own `queue`.
     - Parameter closure: a closure that returns an enum instance with the value `CurrentValue` or` QueueSafeValueError`.
     */
    public func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        execute(command: { $0 }, completion: closure)
    }

    /**
     Thread-safe (queue-safe) `value` writing.
     - Important: Will be executed asynchronously in own `queue`.
     - Parameters:
        - newValue: value to set.
        - completion: a closure that returns an enum instance with the value `UpdatedValue` or` QueueSafeValueError`.
     */
    public func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil) {
        execute(command: {
            $0 = newValue
            return $0
        }, completion: completion)
    }

    /**
     Thread-safe (queue-safe) `value` updating. 
     - Important: Will be executed asynchronously in own `queue`.
     - Parameters:
        - closure: A closure that updates the original `value` instance.
        - completion: a closure that returns an enum instance with the value `UpdatedValue` or` QueueSafeValueError`.
     - Attention: `closure` will not be run if any ` QueueSafeValueError` occurs.
     */
    public func update(closure: ((inout CurrentValue) -> Void)?,
                       completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil) {
        execute(command: {
            closure?(&$0)
            return $0
        }, completion: completion)
    }

    /**
     Performs `command` asynchronously  in embeded `queue` in defined order.
     - Important: Will be executed asynchronously in own `queue`.
     - Parameters:
        - command: A block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object and returns `ResultValue`
        - completion: a closure that returns an enum instance with the value `ResultValue` or` QueueSafeValueError`.
     */

    func execute<ResultValue>(command: @escaping (inout CurrentValue) -> ResultValue,
                              completion: ((Result<ResultValue, QueueSafeValueError>) -> Void)?) {
        guard let valueContainer = valueContainer else {
            queue.async { completion?(.failure(.valueContainerDeinited)) }
            return
        }

        queue.async {
            self.executeInCommandStack(valueContainer: valueContainer) { currentValue in
                let resultValue = command(&currentValue)
                completion?(.success(resultValue))
            }
        }
    }

    /**
     Defines performing order.
     - Important: Will be executed asynchronously in own `queue`.
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
        - command: A block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    func executeInCommandStack(valueContainer: Container, command: @escaping Container.Closure) { fatalError() }

}
