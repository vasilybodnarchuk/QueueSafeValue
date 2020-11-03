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
     - Parameter command: a closure that updates (provides access) the original `value` instance, wrapped in the`ValueContainer` object.
     - Returns: `ResultValue` on success or  `QueueSafeValueError` on fail.
     */

    @discardableResult
    func execute<ResultValue>(command: @escaping (inout CurrentValue) -> Result<ResultValue, QueueSafeValueError>) -> Result<ResultValue, QueueSafeValueError> {
        guard let valueContainer = valueContainer else { return .failure(.valueContainerDeinited) }
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var resultValue: Result<ResultValue, QueueSafeValueError>!
        executeInCommandQueue(valueContainer: valueContainer) { currentValue in
            resultValue = command(&currentValue)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return resultValue
    }
}

// MARK: Get commands
extension SyncedCommandsWithPriority {
    /**
     Queue-safe (thread-safe) `value` getting command.
     - Important: the func runs synchronously in `CommandQueue` (blocks a queue where this code runs until it completed).
     - Returns:`CurrentValue` on success or  `QueueSafeValueError` on fail.
     */
    public func get() -> Result<CurrentValue, QueueSafeValueError> { execute { .success($0) } }

    /**
     Queue-safe (thread-safe) `value` getting inside a closure command.
     - Important: the func runs synchronously in `command queue` (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure that returns the `CurrentValue` on success or  `QueueSafeValueError` on fail. Expected sequential code inside the `commandClosure`.
     */
    public func get(completion commandClosure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        let result = execute { currentValue -> Result<Void, QueueSafeValueError> in
            commandClosure?(.success(currentValue))
            return .success(Void())
        }
        switch result {
        case .failure(let error): commandClosure?(.failure(error))
        default: break
        }
    }

    /**
     Queue-safe (thread-safe) `value` getting inside a closure that must be completed manually command.
     - Important: the func runs synchronously in `CommandQueue` (blocks a queue where this code runs until it completed).
     - Requires: `CommandCompletionClosure`  must always be executed (called).
     - Parameter manualCompletion: a closure that returns the `CurrentValue` on success or  `QueueSafeValueError` on fail. Expected sequential or asynchronous code inside the `commandClosure`.
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
     - Important: the func runs synchronously in `CommandQueue` (blocks a queue where this code runs until it completed).
     - Parameter newValue: value to set
     - Returns: `UpdatedValue` on success or  `QueueSafeValueError` on fail.
     */
    @discardableResult
    public func set(newValue: Value) -> Result<UpdatedValue, QueueSafeValueError> {
        execute { currentValue in
            currentValue = newValue
            return .success(newValue)
        }
    }

    /**
     Queue-safe (thread-safe) `value` setting inside the `accessClosure` command.
     - Important: the func runs synchronously in `CommandQueue` (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure that provide access to the `CurrentValue`,  where it is possible to change the original instance of the `CurrentValue`. Expected sequential code inside the `accessClosure`.
     - Attention: `accessClosure` will not be run if any ` QueueSafeValueError` occurs.
     - Returns: `UpdatedValue` on success or  `QueueSafeValueError` on fail.
     */
    @discardableResult
    public func set(completion accessClosure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError> {
        execute { currentValue in
            accessClosure?(&currentValue)
            return .success(currentValue)
        }
    }

    /**
     Queue-safe (thread-safe) `value` setting inside the `accessClosure` command that must be completed manually.
     - Important: the func runs synchronously in `CommandQueue` (blocks a queue where this code runs until it completed).
     - Requires: `CommandCompletionClosure`  must always be executed (called).
     - Parameter manualCompletion: a closure that  provide access to the `CurrentValue`,  where it is possible to change the original instance of the `CurrentValue`. Sequential or asynchronous code is expected inside the `accessClosure`.
     - Attention: `accessClosure` will not be run if any ` QueueSafeValueError` occurs.
     - Returns: `UpdatedValue` on success or  `QueueSafeValueError` on fail.
     */
    @discardableResult
    public func set(manualCompletion accessClosure: ((inout CurrentValue, @escaping CommandCompletionClosure) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError> {
        var result: Result<UpdatedValue, QueueSafeValueError>!
        manuallyCompleted { complete in
            result = execute { currentValue in
                accessClosure?(&currentValue, complete)
                return .success(currentValue)
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
     - Important: the func runs synchronously in `CommandQueue` (blocks a queue where this code runs until it completed).
     - Parameter completion: a closure that  provide access to the `CurrentValue`,  where it is possible to return transformed (mapped) `CurrentValue`. Sequential code is expected inside the `commandClosure`.
     - Returns: `MappedValue` on success or  `QueueSafeValueError` on fail.
     */
    public func map<MappedValue>(completion commandClosure: ((CurrentValue) -> MappedValue)?) -> Result<MappedValue, QueueSafeValueError> {
        execute { currentValue -> Result<MappedValue, QueueSafeValueError> in
            guard let closure = commandClosure else { return .failure(.commandClosureDeallocated) }
            return .success(closure(currentValue))
        }
    }
}
