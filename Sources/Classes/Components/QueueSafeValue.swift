//
//  QueueSafeValue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 6/30/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Main class that provides thread-safe (queue-safe) access to the `value`.
public class QueueSafeValue<Value> {

    /// Retains the original instance of the `value` and provides thread-safe (queue-safe) access to it.
    private let valueContainer: ValueContainer<Value>

    /**
     Initialize object with properties.
     - Parameter value: Instance of the `value` that we are going to read/write from one or several DispatchQueues.
     - Returns: Container that provides limited and thread safe access to the `value`.
     */
    public init (value: Value) { valueContainer = ValueContainer(value: value) }

    /// Blocks (synchronizes) the thread this function is running on and provides thread-safe (queue-safe) access to `value`
    public var wait: SyncScheduler<Value> { .init(valueContainer: valueContainer) }

    /**
     Execute this function in parallel (asynchronously) on a queue that executes it and provides thread-safe (queue-safe) access to `value`
     - Parameter queue: a queue in which access to the `value` will be granted.
     - Returns: A scheduler in which the execution priority will be selected.
     */
    public func async(performIn queue: DispatchQueue) -> AsyncScheduler<Value> {
        .init(valueContainer: valueContainer, queue: queue)
    }

    /**
     Execute this function in parallel (asynchronously) on a queue that executes it and provides thread-safe (queue-safe) access to `value`
     - Parameter qos: A `quality of service` of a  queue in which access to the `value` will be granted.
     - Returns: A scheduler in which the execution priority will be selected.
     */
    public func async(performIn qos: DispatchQoS.QoSClass) -> AsyncScheduler<Value> {
        async(performIn: DispatchQueue.global(qos: qos))
    }
}

extension QueueSafeValue where Value: AnyObject {
    /**
     Get retain count of wrapped value
     - Note: only for objects
     - Returns:retain count of wrapped value
     */
    public func countObjectReferences() -> CFIndex { valueContainer.countObjectReferences() }
}
