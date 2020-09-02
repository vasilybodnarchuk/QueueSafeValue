//
//  ImmediatelyRunningAsyncedCommands.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//

import Foundation

/// Defines the available async functions that can manipulate a `value` enclosed in a `ValueContainer` and  executes them as soon as possible.
public class ImmediatelyRunningAsyncedCommands<Value>: AsyncedCommandsWithPriority<Value> {

    /// Override func. Read the documentation in the parent class
    override func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.appendAndPerform(closure: command)
    }
}
