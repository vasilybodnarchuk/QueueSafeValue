//
//  AsyncScheduler.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Describes the order in which async access to the `value` enclosed in the `ValueContainer` object will be granted.
public class AsyncScheduler<Value>: Scheduler<Value> {

    /// A queue in which access to the `value` will be granted.
    private let queue: DispatchQueue

    /**
     Initialize object with properties.
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides thread-safe (queue-safe) access to it.
        - queue: a queue in which access to the `value` will be granted.
     - Returns: An object that describes when (in what order) the `value` enclosed in the `ValueContainer` will be accessed.
     */
    init(valueContainer: ValueContainer<Value>, queue: DispatchQueue = .global(qos: .default)) {
        self.queue = queue
        super.init(valueContainer: valueContainer)
    }

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `ValueContainer` object.
     Each function is pushed onto the `command stack` and executed in FIFO order.
     The `lowPriority` function will be placed at the end of the `command queue`.
     */
    public var lowPriority: LowPriorityAsyncedCommands<Value> {
        .init(valueContainer: valueContainer, grantAccessIn: queue)
    }
}
