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

    /// The type of closures to be passed onto the `serialQueue` and execute.
    public typealias Closure = (inout Value) -> Void

    /// The original instance of the value we are going to read / write synchronously or asynchronousl.
    private var value: Value

    /// Abstraction of a queue that stacks closures and executes them sequentially.
    private var serialQueue: ValueProcessingSerialQueue

    /**
     Initialize object with properties.
     - Parameter value: Instance of the value that we are going to read/write from one or several DispatchQueue
     - Returns: Container that provides limited and thread safe access to the `value`.
     */
    public init (value: Value) {
        self.value = value
        serialQueue = ValueProcessingSerialQueue()
    }
}

// MARK: Performing closures in `stack`
extension ValueContainer {
    /**
     Adds closure to the end of `serialQueue` and perform it.
     - Parameter closure: code that we want to perform.
     */
    public func appendAndPerform(closure: @escaping Closure) {
        serialQueue.append { closure(&self.value) }
        serialQueue.perform()
    }

    //func performNow(closure: Closure?) { accessQueue.sync { closure?(&self.value) } }
}

extension ValueContainer where Value: AnyObject {
    /**
     Get retain count of wrapped value
     - Note: only for objects
     - Returns:retain count of wrapped value
     */
    public func countObjectReferences() -> CFIndex { CFGetRetainCount(value) }
}
