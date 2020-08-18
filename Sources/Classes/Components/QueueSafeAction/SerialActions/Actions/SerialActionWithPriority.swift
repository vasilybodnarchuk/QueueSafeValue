//
//  SerialActionsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 6/30/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

public class SerialActionsWithPriority<Value> {
    /// The type of closures to be pushed onto the stack and executed.
    typealias Closure = ValueContainer<Value>.Closure
    
    /// Retains the original instance of the `value` and provides thread-safe access to it.
    private(set) weak var valueContainer: ValueContainer<Value>?
    
    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original value instance and provides thread-safe access to it.
     - Returns: An object that defines manipulations and provides serial access to the value enclosed in the `ValueContainer` object.
     */
    init (valueContainer: ValueContainer<Value>?) { self.valueContainer = valueContainer }
    
    /**
     Performs `closure` in defined order and blocks the queue at runtime.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: block to be executed
     */
    func _perform(closure: @escaping Closure) { fatalError() }
    
    /**
     Thread-safe value reading. Locks the current queue at runtime.
     - Important: Blocks a queue where this code runs until it completed.
     - Returns: original instance of a `value`.
     */
    public func get() -> Value? {
        var result: Value?
        _perform { result = $0 }
        return result
    }
    
    /**
     Thread-safe value writing. Locks the current queue at runtime.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter value: value to set
     */
    public func set(value: Value) { _perform { $0 = value } }
    
    /**
     Thread-safe value updating. Locks the current queue at runtime.
     - Important: Blocks the queue where this code runs until it completed.
     - Parameter closure: a block that updates the original `value` instance
     */
    public func update(closure: ((_ currentValue: inout Value) -> Void)?) { _perform { closure?(&$0) } }
    
    /**
     Thread-safe value updating.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that updates the original `value` instance.
     - Returns: An updated instance of the value.
     */
    public func updated(closure: ((_ currentValue: inout Value) -> Void)?) -> Value? {
        var newValue: Value?
        _perform {
            closure?(&$0)
            newValue = $0
        }
        return newValue
    }
    
    /**
     Thread-safe value manipulating. Can be used
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that updates the original `value` instance.
     - Returns: An updated instance of the value.
     */
    public func perform(closure: ((Value) -> Void)?) { _perform { closure?($0) } }
    
    /**
     Thread-safe value transforming.
     - Important: Blocks a queue where this code runs until it completed.
     - Parameter closure: A block that transform the original `value` instance
     - Returns: An updated instance of the value.
     */
    public func transform<Output>(closure: ((_ currentValue: Value) -> Output)?) -> Output? {
        var newValue: Output?
        _perform { newValue = closure?($0) }
        return newValue
    }
}
