//
//  SyncSchedulerInterface.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/17/20.
//

import Foundation

public protocol SyncSchedulerInterface {
    associatedtype Value

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `ValueContainer` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `Lowest priority command`  will be executed last.
     */
    var lowestPriority: LowestPrioritySyncedCommands<Value> { get }

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `ValueContainer` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `Highest priority command`  will be executed first.
     */
    var highestPriority: HighestPrioritySyncedCommands<Value> { get }
}
