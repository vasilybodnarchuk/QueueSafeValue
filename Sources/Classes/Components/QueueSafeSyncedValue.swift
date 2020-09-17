//
//  QueueSafeSyncedValue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/16/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// A class that provides synchronous queue-safe (thread-safe ) access to a value.
public class QueueSafeSyncedValue<Value>:  QueueSafeValueConcrete<Value>, SyncSchedulerInterface {

    var valueContainerReference: ValueContainer<Value>? { valueContainer }

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `ValueContainer` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `Lowest priority command`  will be executed last.
     */
    public var lowestPriority: LowestPrioritySyncedCommands<Value> { .init(valueContainer: valueContainerReference) }

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `ValueContainer` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `Highest priority command`  will be executed first.
     */
    public var highestPriority: HighestPrioritySyncedCommands<Value> { .init(valueContainer: valueContainerReference) }
}

//extension QueueSafeSyncedValue: QueueSafeValueInterface { }
