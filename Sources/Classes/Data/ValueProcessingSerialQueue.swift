//
//  ValueProcessingSerialQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//

import Foundation


/// Abstraction of a queue that stacks closures and executes them sequentially
public class ValueProcessingSerialQueue {
    
    /// The type of closures to be pushed onto the stack and executed.
    public typealias Closure = () -> Void
    
    /// Queue that performs stacked closures synchronously.
    private var accessQueue: DispatchQueue!

    /// Container in which all closures are stored.
    private var stack: Stack<Closure>
    
    /**
     Initialize object with properties.
     - Returns: Abstraction of a queue that stacks closures and executes them sequentially .
     */
    public init () {
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

extension ValueProcessingSerialQueue {

    /**
     Adds closure to the end of our `stack`.
     - Parameter closure: code that we want to perform.
     */
    public func append(closure: @escaping Closure) { stack.push(closure) }
    
    //func performNow(closure: Closure?) { accessQueue.sync { closure?(&self.value) } }
    
    /// Performs closures sequentially that contained in `stack`.
    func perform() {
        if stack.isEmpty { return }
        guard let closure = stack.pop() else {
            perform()
            return
        }
        accessQueue.sync { closure() }
        perform()
    }
}
