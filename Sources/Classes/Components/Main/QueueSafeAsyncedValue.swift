//
//  QueueSafeAsyncedValue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/17/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// A class that provides asynchronous, queue-safe (thread-safe) access to a `value` with selected `commands` execution priority.
public class QueueSafeAsyncedValue<Value>:  QueueSafeValueConcrete<Value>, AsyncSchedulerInterface {

    /// References to the original instance of the `value` and provides thread-safe (queue-safe) access to it.
    var valueContainerReference: ValueContainer<Value>? { valueContainer }

    /// A queue in which access to the `value` will be granted.
    private let queue: DispatchQueue

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `value container` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `lowest priority command`  will be executed last.
     */
    public var lowestPriority: LowestPriorityAsyncedCommands<Value> {
        .init(valueContainer: valueContainerReference, grantAccessIn: queue)
    }

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `value container` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `highest priority command`  will be executed first.
     */
    public var highestPriority: HighestPriorityAsyncedCommands<Value> {
        .init(valueContainer: valueContainerReference, grantAccessIn: queue)
    }

    /**
     Initialize object with properties.
     - Parameters:
        - value: Instance of the `value` that we are going to read/write from one or several DispatchQueues.
        - queue: A queue in which access to the `value` will be granted.
     - Returns: Container that provides limited and thread safe sync access to the `value`.
     */
    required public init(value: Value, queue: DispatchQueue) {
        self.queue = queue
        super.init(value: value)
    }
}
