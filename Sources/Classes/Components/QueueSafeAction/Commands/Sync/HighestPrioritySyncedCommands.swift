//
//  HighestPrioritySyncedCommands.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/4/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available async `commands` that can manipulate an enclosed `value` and executes them in `highest priority` order.
public class HighestPrioritySyncedCommands<Value>: SyncedCommandsWithPriority<Value> {

    /// Overriden. Read the documentation in the parent class
    override func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.perform(priority: .commandQueue(priority: .highest), closure: command)
    }
}
