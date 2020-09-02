//
//  LowPriorityAsyncedCommands.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available async functions that can manipulate a `value` enclosed in a `ValueContainer` and executes them in `low priority` order.
public class LowPriorityAsyncedCommands<Value>: AsyncedCommandsWithPriority<Value> {

    /// Override func. Read the documentation in the parent class
    override func executeInCommandStack(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.appendAndPerform(closure: command)
    }
}
