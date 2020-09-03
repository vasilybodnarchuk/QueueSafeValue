//
//  ValueContainer.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/8/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Class where we keep an original value that we are going to read/write asynchronously.
public class ValueContainer<Value> {

    /// The type of closures to be passed onto the `commandQueue` and execute.
    public typealias Closure = (inout Value) -> Void

    /// The original instance of the `value` we are going to read / write synchronously or asynchronousl.
    private var value: Value

    /// A queue that stacks closures and executes them sequentially.
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
    /**
     Adds closure to the end of `commandQueue` and perform it.
     - Parameter closure: closure (block) to be performed.
     */
    public func appendAndPerform(closure: @escaping Closure) {
        commandQueue.append(priority: .highest) { closure(&self.value) }
        commandQueue.perform()
    }

    /**
     Runs closure without stacking it to `commandQueue`.
     - Parameter closure: closure (block) to be performed.
     */
    func performNow(closure: @escaping Closure) {
       // commandQueue.performImmediately { closure(&self.value) }
        commandQueue.append(priority: .highest) { closure(&self.value) }
        commandQueue.perform()
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
