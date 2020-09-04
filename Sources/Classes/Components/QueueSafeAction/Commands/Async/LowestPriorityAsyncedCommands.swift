//
//  LowestPriorityAsyncedCommands.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available async `commands` that can manipulate a `value` enclosed in a `ValueContainer` and executes them in `lowest priority` order.
public class LowestPriorityAsyncedCommands<Value>: AsyncedCommandsWithPriority<Value> {

    /// Override func. Read the documentation in the parent class
    override func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.perform(priority: .lowest, closure: command)
    }
}
