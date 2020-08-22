//
//  SyncScheduler.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/8/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Describes the order in which sync access to the `value` enclosed in the `ValueContainer `object will be granted.
public class SyncScheduler<Value>: ActionScheduler<Value> {

    /**
    Schedules function execution in a `command queue` that is integrated into the `ValueContainer` object.
    Each function is pushed onto the command stack and executed in FIFO order.
    The `lowPriority` function will be placed at the end of the command queue.
    */
    public var lowPriority: QueueSafeAction.LowPrioritySerialActions<Value> { .init(valueContainer: valueContainer) }
}
