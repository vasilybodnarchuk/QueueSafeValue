//
//  ActionsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//

import Foundation

/// An inheritance class that describes the interface for sync / async actions.
public class ActionsWithPriority<Value> {
    /// The type of closures to be pushed onto the stack and executed.
    typealias Closure = ValueContainer<Value>.Closure

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
    func executeCommand(closure: @escaping Closure) { fatalError() }

    /**
     Thread-safe (queue-safe) value updating.
     - Important: If synchronous execution is scheduled, blocks the queue on which this code is running until it completes.
     - Parameter closure: a block that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    public func update(closure: ((_ currentValue: inout Value) -> Void)?) {
        executeCommand { closure?(&$0) }
    }

    /**
     Thread-safe (queue-safe) value manipulating.
     - Important: If synchronous execution is scheduled, blocks the queue on which this code is running until it completes.
     - Parameter closure: A block that updates the original `value` instance, wrapped in a `ValueContainer` object.
     */
    public func perform(closure: ((Value) -> Void)?) { executeCommand { closure?($0) } }
}
