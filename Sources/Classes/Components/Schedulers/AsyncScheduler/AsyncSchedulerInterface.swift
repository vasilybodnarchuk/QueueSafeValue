//
//  AsyncSchedulerInterface.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/21/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Interface of ` scheduler` that provides sync queue-safe (thread-safe) access to the enclosed `value`
public protocol AsyncSchedulerInterface: InterfaceWithEnclosedValue {

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `value container` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `lowest priority command`  will be executed last.
     */
    var lowestPriority: LowestPriorityAsyncedCommands<Value> { get }

    /**
     Schedules `command` execution in a `command queue` that is integrated into the `value container` object.
     Each `command` will be placed in a `command queue` and executed in order of priority.
     The `highest priority command`  will be executed first.
     */
    var highestPriority: HighestPriorityAsyncedCommands<Value> { get }
}

