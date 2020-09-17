//
//  ValueContainer.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/8/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Retains the original `value`(nstance) and provides limited thread-safe (queue-safe) access to it.
public class ValueContainer<Value> {

    /// The type of closures to be placed in the `command queue` and executed afterwards.
    public typealias Closure = (inout Value) -> Void

    /// The original `value` (instance) for thread-safe (queue-safe)  read / write / update.
    private var value: Value

    /// A queue that stores `closures` (`commands`) and executes them sequentially in correct order.
    private var commandQueue: CommandQueue

    /**
     Initialize object with properties.
     - Parameter value: Instance of the value that we are going to read/write from one or several DispatchQueue
     - Returns: Container that provides limited and thread safe access to the `value`.
     */
    public init (value: Value) {
        self.value = value
        commandQueue = CommandQueue()
    }
}

// MARK: Performing closures in `stack`
extension ValueContainer {

    /// Defines all possible command execution priorities
    public enum PerformPriority {
        case commandQueue(priority: CommandQueue.Priority)
    }
    /**
     Places `closure`to the `command queue` and perform it in correct order.
     - Parameters:
        - priority: Describes the order in which `closures`  (`commands`) will be performed. `closure` (`command`) with  `highest priority` will be execurted first.
        - closure: `closure` (`command`)  where access to the `value` granted.
     */
    public func perform(priority: PerformPriority, closure: @escaping Closure) {
        switch priority {
        case .commandQueue(let priority):
            commandQueue.append(priority: priority) { closure(&self.value) }
            commandQueue.perform()
        }
    }
}

extension ValueContainer where Value: AnyObject {
    /**
     Get retain count of wrapped value
     - Note: only for objects
     - Returns:retain count of wrapped value
     */
    public func countObjectReferences() -> CFIndex { CFGetRetainCount(value) }
}
