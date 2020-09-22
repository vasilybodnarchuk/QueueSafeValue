//
//  QueueSafeValue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 6/30/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// The main class providing synchronous and asynchronous queue-safe (thread-safe) access to a `value`.
public class QueueSafeValue<Value>: QueueSafeValueConcrete<Value> {

    /**
     Returns the scheduler in which the priority of the `value access command` will be selected.
     Each function that the scheduler will execute will block (synchronize) the queue (thread) in which that function is running until it finishes.
     */
    public var wait: SyncScheduler<Value> { .init(valueContainer: valueContainer) }

    /**
     Returns the scheduler in which the priority of the `value access command` will be selected.
     Each function that the scheduler will execute will be executed in parallel (asynchronously) a queue (thread) that called it.
     - Parameter queue: a queue in which access to the `value` will be granted (where a `command` will be executed).
     - Returns: A scheduler in which the execution priority will be selected.
     */
    public func async(performIn queue: DispatchQueue) -> AsyncScheduler<Value> {
        .init(valueContainer: valueContainer, queue: queue)
    }

    /**
     Returns the scheduler in which the priority of the `value access command` will be selected.
     Each function that the scheduler will execute will be executed in parallel (asynchronously) a queue (thread) that called it.
     - Parameter qos: A `quality of service` of a  queue in which access to the `value` will be granted (where a `command` will be executed).
     - Returns: A scheduler in which the execution priority will be selected.
     */
    public func async(performIn qos: DispatchQoS.QoSClass) -> AsyncScheduler<Value> {
        async(performIn: DispatchQueue.global(qos: qos))
    }
}
