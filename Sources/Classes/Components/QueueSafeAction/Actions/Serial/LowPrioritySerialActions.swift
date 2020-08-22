//
//  LowPrioritySerialActions.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/16/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

extension QueueSafeAction {
    public class LowPrioritySerialActions<Value>: SerialActionsWithPriority<Value> {
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
}
