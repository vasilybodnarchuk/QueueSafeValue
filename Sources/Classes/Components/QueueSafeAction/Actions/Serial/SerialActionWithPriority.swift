//
//  SerialActionsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 6/30/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

public class SerialActionsWithPriority<Value>: ActionsWithPriority<Value> {

    /**
     Thread-safe value reading.
     - Important: Blocks a queue where this code runs until it completed.
     - Returns: original instance of a `value`.
     */
    public func get() -> Value? {
        var result: Value?
        perform { result = $0 }
        return result
    }

    /**
     Thread-safe value writing.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter value: value to set
     */
    public func set(value: Value) { executeCommand { $0 = value } }

    /**
     Thread-safe value updating.
     - Important: Blocks the queue where this code runs until it completed.
     - Parameter closure: a block that updates the original `value` instance
     */
    public func update(closure: ((_ currentValue: inout Value) -> Void)?) { executeCommand { closure?(&$0) } }

    /**
     Thread-safe value updating.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that updates the original `value` instance.
     - Returns: An updated instance of the value.
     */
    public func updated(closure: ((_ currentValue: inout Value) -> Void)?) -> Value? {
        var newValue: Value?
        executeCommand {
            closure?(&$0)
            newValue = $0
        }
        return newValue
    }

    /**
     Thread-safe value manipulating.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that updates the original `value` instance.
     - Returns: An updated instance of the value.
     */
    public func perform(closure: ((Value) -> Void)?) { executeCommand { closure?($0) } }

    /**
     Thread-safe value transforming.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that transform the original `value` instance
     - Returns: An updated instance of the value.
     */
    public func transform<Output>(closure: ((_ currentValue: Value) -> Output)?) -> Output? {
        var newValue: Output?
        executeCommand { newValue = closure?($0) }
        return newValue
    }
}
