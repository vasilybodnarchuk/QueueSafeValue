//
//  QueueSafeSyncedValue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/16/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

///// Main class that provides thread-safe (queue-safe) sync access to the `value`.
public class QueueSafeSyncedValue<Value>: SyncScheduler<Value> {

    /// Retains the original instance of the `value` and provides thread-safe (queue-safe) access to it.
    let valueContainer: ValueContainer<Value>

    /**
     Initialize object with properties.
     - Parameter value: Instance of the `value` that we are going to read/write from one or several DispatchQueues.
     - Returns: Container that provides limited and thread safe sync access to the `value`.
     */
    required public init(value: Value) {
        valueContainer = ValueContainer(value: value)
        super.init(valueContainer: valueContainer)
    }
}

extension QueueSafeSyncedValue: QueueSafeValueInterface { }
