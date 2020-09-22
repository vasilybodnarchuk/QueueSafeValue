//
//  CommandsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//

import Foundation

/// An inheritance class that describes available the interface for sync / async commands.
public class CommandsWithPriority<Value> {

    /// Same as `Value` type. Used to improve readability
    public typealias UpdatedValue = Value

    /// Same as `Value` type. Used to improve readability
    public typealias CurrentValue = Value

    /// The type of container that stores original instance of `value`.
    typealias Container = ValueContainer<Value>

    /// Retains the original instance of the `value` and provides queue-safe (thread-safe) access to it.
    private(set) weak var valueContainer: Container?

    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original `value` instance and provides queue-safe (thread-safe) access to it.
     - Returns: An object that defines available `value` access functions and provides queue-safe (thread-safe) access to this `value `.
     */
    init (valueContainer: Container?) { self.valueContainer = valueContainer }
}
