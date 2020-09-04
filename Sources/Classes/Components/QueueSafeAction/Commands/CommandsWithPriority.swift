//
//  CommandsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//

import Foundation

/// An inheritance class that describes the interface for sync / async commands.
public class CommandsWithPriority<Value> {

    /// Same as `value` type. Used to improve readability
    public typealias UpdatedValue = Value

    /// Same as `value` type. Used to improve readability
    public typealias CurrentValue = Value

    /// The type of container that stores original instance of `value`.
    typealias Container = ValueContainer<Value>

    /// Retains the original instance of the `value` and provides thread-safe access to it.
    private(set) weak var valueContainer: Container?

    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
     - Returns: An object that defines `value` manipulating functions enclosed in a `ValueContainer` object and provides thread-safe (queue-safe) access to this `value `.
     */
    init (valueContainer: Container?) { self.valueContainer = valueContainer }
}
