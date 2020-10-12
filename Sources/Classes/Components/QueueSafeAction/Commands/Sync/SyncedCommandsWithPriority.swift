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

// MARK: Get commands
extension SyncedCommandsWithPriority {
    /**
     Queue-safe (thread-safe) `value` getting command.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Returns: enum instance that contains `CurrentValue` or `QueueSafeValueError`.
     */
    public func get() -> Result<CurrentValue, QueueSafeValueError> { execute { $0 } }

    /**
     Queue-safe (thread-safe) `value` getting inside a closure command.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure that get an enumeration instance consisting of `CurrentValue` or `QueueSafeValueError`. Expected sequential code inside a closure.
     */
    public func get(completion commandClosure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        let result = execute { currentValue -> Void in
            commandClosure?(.success(currentValue))
            return Void()
        }
        switch result {
        case .failure(let error): commandClosure?(.failure(error))
        default: break
        }
    }

    /**
     Queue-safe (thread-safe) `value` getting inside a closure that must be completed manually command.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Requires: `CommandCompletionClosure`  must always be executed (called).
     - Parameter manualCompletion:a closure that get an enumeration instance consisting of `CurrentValue` (or `QueueSafeValueError`) and `CommandCompletionClosure`.
     */
    public func get(manualCompletion commandClosure: ((Result<CurrentValue, QueueSafeValueError>,
                                                       @escaping CommandCompletionClosure) -> Void)?) {
        manuallyCompleted { complete in
            self.get { result in commandClosure?(result, complete) }
        }
    }
}

// MARK: Change value commands
extension SyncedCommandsWithPriority {
    /**
     Queue-safe (thread-safe) `value` setting command.
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
     Queue-safe (thread-safe) `value` setting inside closure command.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure containing sequential code that updates the original nested `value`.
     - Attention: `commandClosure` will not be run if any ` QueueSafeValueError` occurs.
     - Returns: enum instance that contains `UpdatedValue` or `QueueSafeValueError`.
     */
    @discardableResult
    public func set(completion commandClosure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError> {
        execute { currentValue in
            commandClosure?(&currentValue)
            return currentValue
        }
    }

    /**
     Queue-safe (thread-safe) `value` setting inside closure that must be completed manually.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter manualCompletion: a closure with asynchronous code that updates the original nested `value`.
     - Attention: `commandClosure` will not be run if any ` QueueSafeValueError` occurs. Sequential or asynchronous code is expected inside the `commandClosure`.
     - Returns: enum instance that contains `UpdatedValue` or `QueueSafeValueError`.
     */
    @discardableResult
    public func set(manualCompletion commandClosure: ((inout CurrentValue, @escaping CommandCompletionClosure) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError> {
        var result: Result<UpdatedValue, QueueSafeValueError>!
        manuallyCompleted { complete in
            result = execute { currentValue in
                commandClosure?(&currentValue, complete)
                return currentValue
            }
            switch result {
            case .failure, .none: complete()
            case .success: break
            }
        }
        return result
    }
}

// MARK: Other commands
extension SyncedCommandsWithPriority {
    /**
     Queue-safe (thread-safe) `value` mapping.
     - Important: the func runs synchronously (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure containing sequential code that updates the original nested `value`.
     - Returns: enum instance that contains `MappedValue` or `QueueSafeValueError`.
     */
    public func map<MappedValue>(completion commandClosure: ((CurrentValue) -> MappedValue)?) -> Result<MappedValue, QueueSafeValueError> {
        execute { commandClosure!($0) }
//        var resultError: QueueSafeValueError?
//        let result = execute { currentValue -> MappedValue? in
//            guard let closure = commandClosure else {
//                resultError = .commandClosureDeallocated
//                return nil
//            }
//            return closure(currentValue)
//        }
//        
    }
}
