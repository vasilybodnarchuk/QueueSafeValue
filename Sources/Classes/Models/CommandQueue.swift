//
//  CommandQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//

import Foundation

/// A queue that stacks closures and executes them sequentially.
public class CommandQueue {

    public enum Priority: Int {
        case highest
        case lowest
    }

//    private var highestPriority: Int
//    private var lowestPriority: Int

    /// The type of closures to be pushed onto the `stack` and executed.
    public typealias Closure = Command.Closure

    /// A semaphore that allows only one command to be executed at a time.
    private var executionCommandSemaphore: DispatchSemaphore!

    private var priorityQueueAccessSemaphore: DispatchSemaphore!

    /// Container in which all closures are stored.
    //private var stack: QueueSafeStack<Closure>

    private var priorityQueue: PriorityQueue<Command>!

    /**
     Initialize object with properties.
     - Returns: Abstraction of a queue that stacks closures and executes them sequentially .
     */
    public init () {
        executionCommandSemaphore = DispatchSemaphore(value: 1)
        priorityQueueAccessSemaphore = DispatchSemaphore(value: 1)
        priorityQueue = PriorityQueue(priority: .parentsGreaterThanOrEqualChildren)
//        highestPriority = 1000
//        lowestPriority = 0
    }
}

// MARK: Performing closures in `stack`

extension CommandQueue {

    /**
     Adds closure to the end of the `stack`.
     - Parameter closure: code that we want to perform.
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

    /// Performs closures sequentially that contained in `stack`.
    public func perform() {
        var command: Command?
        priorityQueueAccessSemaphore.wait()
        command = priorityQueue.removeElementWithHighestPriority()
        priorityQueueAccessSemaphore.signal()
        guard let closure = command?.closure else { return }

        executionCommandSemaphore.wait()
        closure()
        executionCommandSemaphore.signal()
        perform()
    }
}
