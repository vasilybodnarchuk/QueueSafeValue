//
//  LowPriorityAsyncActions.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/22/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available async functions that can manipulate a `value` enclosed in a `ValueContainer` and executes them in `low priority` order.
public class LowPriorityAsyncActions<Value>: AsyncActionsWithPriority<Value> {
    override func executeCommand(closure: @escaping ValueContainer<Value>.Closure) throws {
        guard let valueContainer = valueContainer else { throw QueueSafeValueError.valueContainerDeinited }
        queue.async {
            valueContainer.appendAndPerform { current in
                closure(&current)
            }
        }
    }
}
