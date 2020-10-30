//
//  CommandsWithPriority.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//

import Foundation

/// An inheritance class that describes available the interface for sync / async commands.
public class CommandsWithPriority<Value> {

    /// Same as `Value` type. Used to improve readability
    public typealias UpdatedValue = Value

    /// Same as `Value` type. Used to improve readability
    public typealias CurrentValue = Value

    /// The type of container that stores original instance of `value`.
    typealias Container = ValueContainer<Value>

    /// The type of closures to be called (executed) in commands with manual completion.
    public typealias CommandCompletionClosure = () -> Void
    public typealias ValueReturningCommandCompletionClosure = () -> UpdatedValue

    /// Retains the original instance of the `value` and provides queue-safe (thread-safe) access to it.
    private(set) weak var valueContainer: Container?

    /// Priority characterizing the order of command execution. Must be overridden!
    public var priority: ValueContainer<Value>.PerformPriority { fatalError() }

    /**
     Object initialization with parameters.
     - Parameter valueContainer: an object that stores the original `value` instance and provides queue-safe (thread-safe) access to it.
     - Returns: An object that defines available `value` access functions and provides queue-safe (thread-safe) access to this `value `.
     */
    init (valueContainer: Container?) { self.valueContainer = valueContainer }

    /**
     Performs a `closure` that includes a nested closure (`completion handler`). The `completion handler` must always be executed.
     - Parameter closure: closure with nested completion handler.
     */
    func manuallyCompleted(closure: (@escaping CommandCompletionClosure) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        closure({ dispatchGroup.leave() })
        dispatchGroup.wait()
    }

    /**
     Defines performing order.
     - Note: `command` will be executed asynchronously or synchronously in `CommandQueue`.
     - Parameters:
        - valueContainer: an object that stores the original `value` instance and provides queue-safe (thread-safe) access to it.
        - command: a closure that updates (provides access) the original `value` instance, wrapped in a `ValueContainer` object.
     */
    func executeInCommandQueue(valueContainer: Container, command: @escaping Container.Closure) {
        valueContainer.perform(priority: priority, closure: command)
    }
}
