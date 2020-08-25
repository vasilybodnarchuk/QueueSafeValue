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
     Thread-safe value reading.
     - Important: Blocks a queue where this code runs until it completed.
     - Returns: enum instance that contains `CurrentValue` or `QueueSafeValueError`.
     */
    public func get() -> Result<CurrentValue, QueueSafeValueError> {
        do {
            var result: Value!
            try executeCommand { result = $0 }
            return .success(result)
        } catch let error as QueueSafeValueError {
            return .failure(error)
        } catch { fatalError() }
    }

    /**
     Thread-safe value writing.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter value: value to set
     - Returns: enum instance that contains `UpdatedValue` or `QueueSafeValueError`.
     */
    @discardableResult
    public func set(value: Value) -> Result<UpdatedValue, QueueSafeValueError> {
        do {
            var result: UpdatedValue!
            try executeCommand {
                $0 = value
                result = $0
            }
            return .success(result)
        } catch let error as QueueSafeValueError {
            return .failure(error)
        } catch { fatalError() }
    }

    /**
     Thread-safe value updating.
     - Important: Blocks a queue where this code runs until it completed..
     - Parameter closure: A block that updates the original `value` instance.
     - Attention: `closure` will not be run if any ` QueueSafeValueError` occurs.
     - Returns: enum instance that contains `UpdatedValue` or `QueueSafeValueError`.
     */
    @discardableResult
    public func update(closure: ((inout CurrentValue) -> Void)?) -> Result<UpdatedValue, QueueSafeValueError> {
        do {
            var result: UpdatedValue!
            try executeCommand {
                closure?(&$0)
                result = $0
            }
            return .success(result)
        } catch let error as QueueSafeValueError {
            return .failure(error)
        } catch { fatalError() }
    }

    /**
     Thread-safe value transforming.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that transform the original `value` instance.
     - Returns: enum instance that contains `TransformedValue` or `QueueSafeValueError`.
     */
    public func transform<TransformedValue>(closure: ((CurrentValue) -> TransformedValue)?) -> Result<TransformedValue, QueueSafeValueError> {
        do {
            var newValue: TransformedValue!
            try executeCommand { newValue = closure?($0) }
            return .success(newValue)
        } catch let error as QueueSafeValueError {
            return .failure(error)
        } catch { fatalError() }
    }

    /**
     Thread-safe (queue-safe) value manipulating.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    public func perform(closure: ((Result<CurrentValue, QueueSafeValueError>) -> Void)?) {
        do {
            try executeCommand { closure?(.success($0)) }
        } catch let error as QueueSafeValueError {
            closure?(.failure(error))
        } catch { fatalError() }
    }
}
