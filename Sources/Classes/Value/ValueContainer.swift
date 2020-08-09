//
//  ValueContainer.swift
//  QueueSafeValue
//
//  Created by Vasily on 8/8/20.
//

import Foundation

struct WeakReferencedValue<T> { var value: T }

public class ValueContainer<T> {
    typealias Closure = (inout T) -> Void
    private var stack: Stack<WeakReferencedValue<Closure>>
    private var accessQueue: DispatchQueue!
    private var value: T
    init (value: T) {
        self.value = value
        stack = Stack<WeakReferencedValue<Closure>>()
        let address = Unmanaged.passUnretained(self).toOpaque()
        let label = "accessQueue.\(type(of: self)).\(address)"
        accessQueue = DispatchQueue(label: label,
                                    qos: .unspecified,
                                    attributes: [.concurrent],
                                    autoreleaseFrequency: .inherit,
                                    target: nil)
    }
    
    func performLast(closure: @escaping Closure) {
        stack.push(.init(value: closure))
        perform()
    }
    
    func performNow(closure: Closure?) {
        accessQueue.sync { closure?(&self.value) }
    }

    private func perform() {
        if stack.isEmpty { return }
        guard let closure = stack.pop()?.value else {
            perform()
            return
        }
        accessQueue.sync { closure(&self.value) }
        perform()
    }
}

extension ValueContainer where T: AnyObject {
    public func getRetainCount() -> CFIndex { CFGetRetainCount(value) }
}
