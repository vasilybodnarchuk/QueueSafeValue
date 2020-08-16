//
//  ValueContainer.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/8/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Main class where we keep an original value that we are going to read/write asynchronously.
public class ValueContainer<Value> {
    /// The type of closures to be pushed onto the stack and executed.
    typealias Closure = (inout Value) -> Void
    
    /// `Built-in run queue` container. Keeps all actions (closures) that will be performed.
    private var stack: Stack<Closure>
    
    /// Provides safe access to the value. Protects value from simultaneous reading/writing.
    private var accessQueue: DispatchQueue!
    
    /// Instance of the value that we are going to read/write from one or several threads
    private var value: Value
    
    /**
     Initialize object with properties.
     - Parameter value: Instance of the value that we are going to read/write from one or several DispatchQueue
     - Returns: Container that provides limited and thread safe access to the `value`.
     */
    init (value: Value) {
        self.value = value
        stack = Stack<Closure>()
        let address = Unmanaged.passUnretained(self).toOpaque()
        let label = "accessQueue.\(type(of: self)).\(address)"
        accessQueue = DispatchQueue(label: label,
                                    qos: .unspecified,
                                    attributes: [.concurrent],
                                    autoreleaseFrequency: .inherit,
                                    target: nil)
    }
}

// MARK: Performing closures in `stack`
extension ValueContainer {
    
    /**
     Adds closure to the end of our `stack` and perform it queue order.
     - Parameter closure: code that we want to perform.
     */
    func performLast(closure: @escaping Closure) {
        stack.push(closure)
        perform()
    }
    
    //func performNow(closure: Closure?) { accessQueue.sync { closure?(&self.value) } }
    
    /// Performs closures in that `Stack` in queue order. One by one.
    private func perform() {
        if stack.isEmpty { return }
        guard let closure = stack.pop() else {
            perform()
            return
        }
        accessQueue.sync { closure(&self.value) }
        perform()
    }
}

extension ValueContainer where Value: AnyObject {
    /**
     Get retain count of wrapped value
     - Note: only for objects
     - Returns:retain count of wrapped value
     */
    public func getRetainCount() -> CFIndex { CFGetRetainCount(value) }
}
