//
//  LowPriorityAsyncActions.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//

import Foundation

/// Defines the available async functions that can manipulate a `value` enclosed in a `ValueContainer` and executes them in `low priority` order.
public class LowPriorityAsyncActions<Value>: AsyncActionsWithPriority<Value> {
    override func executeCommand(closure: @escaping Closure) {
        guard let valueContainer = valueContainer else { return }
        queue.async {
            valueContainer.appendAndPerform { current in
                closure(&current)
            }
        }
    }
}
