//
//  QueueSafeValue.swift
//  QueueSafeValue
//
//  Created by Vasily on 6/30/20.
//

import Foundation


public class QueueSafeValue<Value> {

    /// Retains the original instance of the value and provides thread-safe access to it.
    private let valueContainer: ValueContainer<Value>
    public init (value: Value) { valueContainer = ValueContainer(value: value) }
    
    /// Locks the current queue at runtime.
    public var wait: QueueSafeAction.When<Value> { .init(valueContainer: valueContainer) }
}

extension QueueSafeValue where Value: AnyObject {
    public func getRetainCount() -> CFIndex { valueContainer.getRetainCount() }
}
