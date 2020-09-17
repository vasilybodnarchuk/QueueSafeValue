//
//  CommandQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// A queue that stores commands and executes them sequentially with the correct priority.
public class CommandQueue {

    /**
     Describes the order in which `Commands` will be performed.
     `command` with  `highest priority` will be execurted first.
     */
    public enum Priority: Int { case highest, lowest }

    /// The type of closures to be placed in the `priorityQueue` and executed afterwards.
    public typealias Closure = Command.Closure

    /// A semaphore that allows only one command to be executed at a time.
    private var executionCommandSemaphore: DispatchSemaphore!

    /// A semaphore that provides only sequential (serial) access to a `priorityQueue`.
    private var priorityQueueAccessSemaphore: DispatchSemaphore!

    /// Container in which all commands are stored.
    private var priorityQueue: PriorityQueue<Command>!

    /**
     Initialize object with properties.
     - Returns: A queue that stores commands and executes them sequentially with the correct priority.
     */
    public init () {
        executionCommandSemaphore = DispatchSemaphore(value: 1)
        priorityQueueAccessSemaphore = DispatchSemaphore(value: 1)
        priorityQueue = PriorityQueue(priority: .parentsGreaterThanOrEqualChildren)
    }
}

// MARK: Working with priority queue

extension CommandQueue {

    /**
     Insert `closure` in `priorityQueue`.
     - Parameters:
        - priority: Defines where `closure`  (`command`) will be placed in` priorityQueue`.  `priority` describes when `command` will be executed (in what order).
        - closure: `closure` (`command`) to be performed.
     */
    public func append(priority: Priority, closure: @escaping Closure) {
        priorityQueueAccessSemaphore.wait()
        var priorityValue: Int!
        switch priorityQueue.count {
        case 0: priorityValue = 0
        case 1: priorityValue = priorityQueue.elements[0].prioriy
        default:
            switch priority {
            case .highest: priorityValue = priorityQueue.elements[0].prioriy
            case .lowest:
                let halfElemets = priorityQueue.elements.count/2
                priorityValue = priorityQueue.elements[halfElemets].prioriy
                priorityQueue.elements[halfElemets+1..<priorityQueue.elements.count].forEach { command in
                    if command.prioriy < priorityValue { priorityValue = command.prioriy }
                }
            }
        }

        switch priority {
        case .highest: priorityValue += 1
        case .lowest: priorityValue -= 1
        }
        priorityQueue.insert(Command(prioriy: priorityValue, closure: closure))
        priorityQueueAccessSemaphore.signal()
    }

    /// Sequentially executes all the `closures` (`commands`) placed on the `command stack`.  `Commands` with the highest priority will be executed first.

    public func perform() {
        var command: Command?
        priorityQueueAccessSemaphore.wait()
        command = priorityQueue.removeElementWithHighestPriority()
        priorityQueueAccessSemaphore.signal()

        guard let closure = command?.closure else { return }
        performNow(closure: closure)
        perform()
    }

    /**
     Thrrad-safe (queue-safe)`closures`  (`commands`) execution.
     - Parameter closure:`closure` (`command`) to be executed.
     */
    public func performNow(closure: @escaping Closure) {
        executionCommandSemaphore.wait()
        closure()
        executionCommandSemaphore.signal()
    }
}
