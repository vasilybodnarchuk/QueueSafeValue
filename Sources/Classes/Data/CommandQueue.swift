//
//  CommandQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//

import Foundation

/// Abstraction of a queue that stacks closures and executes them sequentially
public class CommandQueue {

    /// The type of closures to be pushed onto the stack and executed.
    public typealias Closure = () -> Void

    /// Queue that performs stacked closures synchronously.
    private var accessQueue: DispatchQueue!

    /// Container in which all closures are stored.
    private var stack: QueueSafeStack<Closure>

    /**
     Initialize object with properties.
     - Returns: Abstraction of a queue that stacks closures and executes them sequentially .
     */
    public init () {
        stack = QueueSafeStack<Closure>()
        accessQueue = DispatchQueue.createSerialAccessQueue()
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
        accessQueue.sync { closure() }
        perform()
    }
}
