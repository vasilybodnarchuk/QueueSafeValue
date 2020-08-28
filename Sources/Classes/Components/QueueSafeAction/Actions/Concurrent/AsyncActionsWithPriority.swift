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
        execute(command: { $0 }, completion: closure)
    }

    /**
     Thread-safe (queue-safe) `value` writing.
     - Important: Will be executed asynchronously on the queue where this function was called.
     - Parameters:
        - newValue: value to set.
        - completion: block that returns updated `value`.
     */
    public func set(newValue: Value, completion: ((Result<UpdatedValue, QueueSafeValueError>) -> Void)?) {
        execute(command: {
            $0 = newValue
            return $0
        }, completion: completion)
    }

//    override func execute(command: @escaping ValueContainer<Value>.Closure,
//                          completion: (Result<ValueContainer<Value>.Closure, Qu>) -> ) throws {
//        guard let valueContainer = valueContainer else { throw QueueSafeValueError.valueContainerDeinited }
//        let dispatchGroup = DispatchGroup()
//        dispatchGroup.enter()
//        valueContainer.appendAndPerform { current in
//            closure(&current)
//            dispatchGroup.leave()
//        }
//        dispatchGroup.wait()
//    }

//    func executeCommand(closure: @escaping ValueContainer<Value>.Closure) throws {
//        guard let valueContainer = valueContainer else { throw QueueSafeValueError.valueContainerDeinited }
//        queue.async {
//            valueContainer.appendAndPerform { current in
//                closure(&current)
//            }
//        }
//    }

    /**
     Performs `command` synchronously in defined order.
     - Parameter command: A block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object.
     - Returns: enum instance that contains `ResultValue` or `QueueSafeValueError`.
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
     - Important: Blocks a queue where this code runs until it completed.  Must be redefined (overridden).
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
        - command: A block (closure) that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    func executeInCommandStack(valueContainer: Container, command: @escaping Container.Closure) { fatalError() }

}
