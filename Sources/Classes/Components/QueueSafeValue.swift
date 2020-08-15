//
//  QueueSafeValue.swift
//  QueueSafeValue
//
//  Created by Vasily on 6/30/20.
//

import Foundation

/// Main class that provides thread-safe access to the `value`
public class QueueSafeValue<Value> {

    /// Retains the original instance of the value and provides thread-safe access to it.
    private let valueContainer: ValueContainer<Value>
    
    /**
     Initialize object with properties.
     - Parameter value: Instance of the value that we are going to read/write from one or several DispatchQueue
     - Returns: Container that provides limited and thread safe access to the `value`.
     */
    public init (value: Value) { valueContainer = ValueContainer(value: value) }
    
    /// Locks the current queue at runtime.
    public var wait: QueueSafeSchedule<Value> { .init(valueContainer: valueContainer) }
}

extension QueueSafeValue where Value: AnyObject {
    /**
     Get retain count of wrapped value
     - Note: only for objects
     - Returns:retain count of wrapped value
     */
    public func getRetainCount() -> CFIndex { valueContainer.getRetainCount() }
}
