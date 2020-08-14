//
//  ValueContainer.swift
//  QueueSafeValue
//
//  Created by Vasily on 8/8/20.
//

import Foundation

/// Main class where we keep an original value that we are going to read/write asynchronously.

public class ValueContainer<T> {
    /// Type of closures that will be placed in stack and performed
    typealias Closure = (inout T) -> Void
    
    /// Queue where closures will be added (stacked)
    private var stack: Stack<Closure>
    
    /// Provides safe access to the value. Protects value from simultaneous reading/writing.
    private var accessQueue: DispatchQueue!
    
    /// Instance of the value that we are going to read/write from one or several threads
    private var value: T
    
    /**
     Initializes a new bicycle with the provided parts and specifications.

     - Parameters:
        - value: Instance of the value that we are going to read/write from one or several DispatchQueue

     - Returns: Container that provides limited and thread safe access to the `value`.
     */
    init (value: T) {
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
     - Parameters:
        - closure: code that we want to perform.
     */
     
     func performLast(closure: @escaping Closure) {
         stack.push(closure)
         perform()
     }
     
     //func performNow(closure: Closure?) { accessQueue.sync { closure?(&self.value) } }

     /**
     Performs closures in that `Stack` in queue order. One by one.
     */
     
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

// MARK: Extensions values that is objects

extension ValueContainer where T: AnyObject {
    /**
     Adds closure to the end of our `stack` and perform it queue order.

     - Returns:retain count of object
     */
     
    public func getRetainCount() -> CFIndex { CFGetRetainCount(value) }
}
