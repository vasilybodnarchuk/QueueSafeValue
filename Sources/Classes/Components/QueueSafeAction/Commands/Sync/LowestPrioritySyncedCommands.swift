//
//  LowestPrioritySyncedCommands.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/16/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available async `commands` that can manipulate an enclosed `value` and executes them in `lowest priority` order.
public class LowestPrioritySyncedCommands<Value>: SyncedCommandsWithPriority<Value> {

    /// Overriden. Read the documentation in the parent class
    override func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.perform(priority: .commandQueue(priority: .lowest), closure: command)
    }
}
