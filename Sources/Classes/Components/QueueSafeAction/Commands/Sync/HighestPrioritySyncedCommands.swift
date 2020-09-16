//
//  HighestPrioritySyncedCommands.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/4/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available sync `commands` that can manipulate a `value` enclosed in a `ValueContainer` and executes them in `highest priority` order.
public class HighestPrioritySyncedCommands<Value>: SyncedCommandsWithPriority<Value> {

    /// Override func. Read the documentation in the parent class
    override func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.perform(priority: .commandQueue(priority: .highest), closure: command)
    }
}
