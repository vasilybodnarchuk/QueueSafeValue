//
//  ActionsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//

import Foundation

/// An inheritance class that describes the interface for sync / async actions.
public class ActionsWithPriority<Value> {

    /// Same as `value` type. Used to improve readability
    public typealias UpdatedValue = Value
    
    /// Same as `value` type. Used to improve readability
    public typealias CurrentValue = Value

    /// The type of closures to be pushed onto the stack and executed.
    typealias Closure = (Result<Value, QueueSafeValueError>) -> Void

    /// Retains the original instance of the `value` and provides thread-safe access to it.
    private(set) weak var valueContainer: ValueContainer<Value>?

    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
     - Returns: An object that defines `value` manipulating functions enclosed in a `ValueContainer` object and provides thread-safe (queue-safe) access to this `value `.
     */
    init (valueContainer: ValueContainer<Value>?) { self.valueContainer = valueContainer }

    /**
     Performs `closure` synchronously or asynchronously in defined order.
     - Parameter closure: block to be executed.
     */
    func executeCommand(closure: @escaping ValueContainer<Value>.Closure) throws { fatalError() }
}
