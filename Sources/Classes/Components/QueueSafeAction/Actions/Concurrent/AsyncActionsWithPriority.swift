//
//  AsyncActionsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//

import Foundation

/**
 Defines the available functions that can manipulate a `value`, wrapped in a `ValueContainer` object.
 All functions will run asynchronously on the queue that calls them.
 */
public class AsyncActionsWithPriority<Value>: ActionsWithPriority<Value> {

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
     - Important: Will be executed asynchronously on the queue where this function was called.
     - Parameter closure: block that returns `value`.
     */
    public func get(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        do {
            try executeCommand { closure?(.success($0)) }
        } catch let error {
            closure?(.failure(error.toQueueSafeValueError()))
        }
    }

    /**
     Thread-safe (queue-safe) `value` writing.
     - Important: Will be executed asynchronously on the queue where this function was called.
     - Parameters:
        - value: value to set.
        - completion: block that returns updated `value`.
     */
    public func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)?) {
        do {
            try executeCommand {
                $0 = newValue
                completion?(.success($0))
            }
        } catch let error {
            completion?(.failure(error.toQueueSafeValueError()))
        }
    }
    
}
