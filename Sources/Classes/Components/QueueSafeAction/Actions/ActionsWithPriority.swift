//
//  ActionsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//

import Foundation

public class ActionsWithPriority<Value> {
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
     Performs `closure` synchronously or asynchronously in defined order.
     - Parameter closure: block to be executed
     */
    func executeCommand(closure: @escaping Closure) { fatalError() }
}
