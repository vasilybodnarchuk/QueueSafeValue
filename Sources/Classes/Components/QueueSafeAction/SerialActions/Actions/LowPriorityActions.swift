//
//  LowPriorityActions.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/16/20.
//

import Foundation

extension QueueSafeAction {
    public class LowPriorityActions<Value>: SerialActionsWithPriority<Value> {
        override func perform(closure: @escaping Closure) {
            guard let valueContainer = valueContainer else { return }
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            valueContainer.appendAndPerform { current in
                closure(&current)
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
    }
}
