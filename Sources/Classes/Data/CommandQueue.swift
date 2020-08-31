//
//  CommandQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//

import Foundation

/// A queue that stacks closures and executes them sequentially.
public class CommandQueue {

    /// The type of closures to be pushed onto the `stack` and executed.
    public typealias Closure = () -> Void

    /// A semaphore that allows only one command to be executed at a time.
    private var dispatchSemaphore: DispatchSemaphore!

    /// Container in which all closures are stored.
    private var stack: QueueSafeStack<Closure>

    /**
     Initialize object with properties.
     - Returns: Abstraction of a queue that stacks closures and executes them sequentially .
     */
    public init () {
        dispatchSemaphore = DispatchSemaphore(value: 1)
        stack = QueueSafeStack<Closure>()
    }
}

// MARK: Performing closures in `stack`

extension CommandQueue {

    /**
     Adds closure to the end of the `stack`.
     - Parameter closure: code that we want to perform.
     */
    public func append(closure: @escaping Closure) { stack.push(closure) }

    /// Performs closures sequentially that contained in `stack`.
    public func perform() {
        if stack.isEmpty { return }
        guard let closure = stack.pop() else {
            perform()
            return
        }
        dispatchSemaphore.wait()
        closure()
        dispatchSemaphore.signal()
        perform()
    }
}
