//
//  CommandQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//

import Foundation

/// A queue that stacks closures and executes them sequentially.
public class CommandQueue {

    /**
     Describes the order in which `closures` will be performed.
     `closure` with  `highest priority` will be execurted first.
     */
    public enum Priority: Int { case highest, lowest }

    /// The type of closures to be placed in the `priorityQueue` and executed afterwards.
    public typealias Closure = Command.Closure

    /// A semaphore that allows only one command to be executed at a time.
    private var executionCommandSemaphore: DispatchSemaphore!

    /// A semaphore that provides only sequential (serial) access to a `priorityQueue`.
    private var priorityQueueAccessSemaphore: DispatchSemaphore!

    /// Container in which all closures are stored.
    private var priorityQueue: PriorityQueue<Command>!

    /**
     Initialize object with properties.
     - Returns: Abstraction of a queue that stacks closures and executes them sequentially .
     */
    public init () {
        executionCommandSemaphore = DispatchSemaphore(value: 1)
        priorityQueueAccessSemaphore = DispatchSemaphore(value: 1)
        priorityQueue = PriorityQueue(priority: .parentsLessThanOrEqualChildren)
    }
}

// MARK: Working with priority queue

extension CommandQueue {

    /**
     Insert `closure` in `priorityQueue`.
     - Parameters:
        - priority: Defines where `closure` will be placed in` priorityQueue`. `priority` describes when `closure` will be executed (in what order).
        - closure: code that we want to perform.
     */
    public func append(priority: Priority, closure: @escaping Closure) {
        priorityQueueAccessSemaphore.wait()
        var priorityValue: Int!
        switch priority {
        case .highest:
            priorityValue = (priorityQueue.peek()?.prioriy ?? 0) + 1
        case .lowest:
            priorityValue = (priorityQueue.peek()?.prioriy ?? 0) + 1
        }
        priorityQueue.insert(Command(prioriy: priorityValue, closure: closure))
        priorityQueueAccessSemaphore.signal()
    }

    /// Performs closures `sequentially`.` Closure` with highest priority will be performed first.
    public func perform() {
        var command: Command?
        priorityQueueAccessSemaphore.wait()
        command = priorityQueue.removeElementWithLowestPriority()
        priorityQueueAccessSemaphore.signal()
        guard let closure = command?.closure else { return }

        executionCommandSemaphore.wait()
        closure()
        executionCommandSemaphore.signal()
        perform()
    }
}
