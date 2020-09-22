//
//  SyncScheduler.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/8/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Describes the order in which synchronous access to the enclosed `value` will be granted
public class SyncScheduler<Value>: SchedulerConcrete<Value> { }

// MARK: SyncSchedulerInterface
extension SyncScheduler: SyncSchedulerInterface {
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
