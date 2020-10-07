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
        - queue: a queue in which access to the `value` will be granted.
     - Returns: an object that defines the available functions which can manipulate the nested `value`.
     */
    init(valueContainer: ValueContainer<Value>?, grantAccessIn queue: DispatchQueue) {
        self.queue = queue
        super.init(valueContainer: valueContainer)
    }

    /**
     Queue-safe (thread-safe) `value` reading.
     - Important: the func will be executed asynchronously in `command queue`.
     - Parameter closure: a closure that returns an enum instance containing `CurrentValue` or `QueueSafeValueError`.
     */
    public func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        execute(command: { $0 }, completion: closure)
    }
    
    /**
     Queue-safe (thread-safe) `value` writing.
     - Important: the func will be executed asynchronously in `command queue`.
     - Parameters:
        - newValue: value to set.
        - completion: a closure that returns an enum instance containing `UpdatedValue` or `QueueSafeValueError`.
     */
    public func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)? = nil) {
        execute(command: {
            $0 = newValue
            return $0
        }, completion: completion)
    }

    /**
     Queue-safe (thread-safe) `value` updating.
     - Important: the func will be executed asynchronously in `command queue`.
     - Parameters:
        - closure: a closure that updates the original `value` instance.
        - completion: a closure that returns an enum instance containing `UpdatedValue` or `QueueSafeValueError`.
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
     - Important: `command` will be executed asynchronously in `command queue`.
     - Parameters:
        - command: a block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object and returns `ResultValue`
        - completion: a closure that returns an enum instance containing `ResultValue` or `QueueSafeValueError`.
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
     - Note: `command` will be executed asynchronously in `command queue`.
     - Important: must be redefined (overridden).
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides queue-safe (thread-safe) access to it.
        - command: A block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) { fatalError() }

}
