//
//  QueueSafeWaitActions.swift
//  QueueSafeValue
//
//  Created by Vasily on 6/30/20.
//

import Foundation

extension QueueSafeAction {
    public class WaitAction<T> {
        typealias Closure = ValueContainer<T>.Closure
        private weak var valueContainer: ValueContainer<T>?

        init (valueContainer: ValueContainer<T>?) {
            self.valueContainer = valueContainer
        }
        
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
        
         // MARK: Get
        
        public func get() -> T? {
            var result: T?
            _perform { result = $0 }
            return result
        }

        // MARK: Set
        
        public func set(value: T) { _perform { $0 = value } }
        
        // MARK: Update
    
        public func update(closure: ((_ currentValue: inout T) -> Void)?) { _perform { closure?(&$0) } }
    
        public func updated(closure: ((_ currentValue: inout T) -> Void)?) -> T? {
            var newValue: T?
            _perform {
                closure?(&$0)
                newValue = $0
            }
            if newValue == nil {
                print("!!!!!1 nil")
            }
            return newValue
        }
    
        // MAKR: Other
    
        public func perform(closure: ((T) -> Void)?) { _perform { closure?($0) } }
    
        public func transform<V>(closure: ((_ currentValue: T) -> V)?) -> V? {
            var newValue: V?
            _perform { newValue = closure?($0) }
            return newValue
        }
    }
}
