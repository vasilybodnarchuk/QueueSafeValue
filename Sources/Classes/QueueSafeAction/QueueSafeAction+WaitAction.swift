//
//  QueueSafeWaitActions.swift
//  QueueSafeValue
//
//  Created by Vasily on 6/30/20.
//

import Foundation

extension QueueSafeAction {
    
    /**
     Describes functions that can manipulate the value in the `ValueContainer` object.
     All functions are executed in a serial queue.
     */
    public class WaitAction<T> {
        /// The type of closures to be pushed onto the stack and executed.
        typealias Closure = ValueContainer<T>.Closure
        
        /// Retains the original instance of the value and provides thread-safe access to it.
        private weak var valueContainer: ValueContainer<T>?
        
        /**
         Initialize object with properties.
         - Parameter valueContainer: an object that stores the original value instance and provides thread-safe access to it.
         - Returns: An object that defines manipulations and provides serial access to the value enclosed in the `ValueContainer` object.
         */
        init (valueContainer: ValueContainer<T>?) { self.valueContainer = valueContainer }
        
        /**
         Performs `closure` and blocks the queue at runtime.
         - Important: Locks the current queue at runtime.
         - Parameter closure: block to be executed
         */
        
        private func _perform(closure: @escaping Closure) {
            guard let valueContainer = valueContainer else { return }
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            valueContainer.performLast { current in
                closure(&current)
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
        
        /**
         Thread-safe value reading. Locks the current queue at runtime.
         - Important: Locks the current queue at runtime.
         - Returns: original instance of a `value`.
         */
        public func get() -> T? {
            var result: T?
            _perform { result = $0 }
            return result
        }
        
        /**
         Thread-safe value writing. Locks the current queue at runtime.
         - Important: Locks the current queue at runtime.
         - Parameter value: value to set
         */
        public func set(value: T) { _perform { $0 = value } }
        
        /**
         Thread-safe value updating. Locks the current queue at runtime.
         - Important: Locks the current queue at runtime.
         - Parameter closure: a block that updates the original `value` instance
         */
        public func update(closure: ((_ currentValue: inout T) -> Void)?) { _perform { closure?(&$0) } }
        
        /**
         Thread-safe value updating.
         - Important: Locks the current queue at runtime.
         - Parameter closure: A block that updates the original `value` instance.
         - Returns: An updated instance of the value.
         */
        public func updated(closure: ((_ currentValue: inout T) -> Void)?) -> T? {
            var newValue: T?
            _perform {
                closure?(&$0)
                newValue = $0
            }
            return newValue
        }
        
        /**
         Thread-safe value manipulating. Can be used
         - Important: Locks the current queue at runtime.
         - Parameter closure: A block that updates the original `value` instance.
         - Returns: An updated instance of the value.
         */
        public func perform(closure: ((T) -> Void)?) { _perform { closure?($0) } }
        
        /**
         Thread-safe value transforming.
         - Important: Locks the current queue at runtime.
         - Parameter closure: A block that transform the original `value` instance
         - Returns: An updated instance of the value.
         */
        public func transform<Output>(closure: ((_ currentValue: T) -> Output)?) -> Output? {
            var newValue: Output?
            _perform { newValue = closure?($0) }
            return newValue
        }
    }
}
