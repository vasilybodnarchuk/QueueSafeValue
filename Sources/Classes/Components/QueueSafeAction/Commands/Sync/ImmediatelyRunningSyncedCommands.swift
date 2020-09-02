//
//  ImmediatelyRunningSyncedCommands.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available sync functions that can manipulate a `value` enclosed in a `ValueContainer` and executes them as soon as possible.
public class ImmediatelyRunningSyncedCommands<Value>: SyncedCommandsWithPriority<Value> {

    /// Override func. Read the documentation in the parent class
    override func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.performNow(closure: command)
    }
}
