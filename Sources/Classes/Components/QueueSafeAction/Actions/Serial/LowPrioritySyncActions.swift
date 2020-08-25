//
//  LowPrioritySyncActions.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/16/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines the available sync functions that can manipulate a `value` enclosed in a `ValueContainer` and executes them in `low priority` order.
public class LowPrioritySyncActions<Value>: SyncActionsWithPriority<Value> {
    override func executeCommand(closure: @escaping Closure) {
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
