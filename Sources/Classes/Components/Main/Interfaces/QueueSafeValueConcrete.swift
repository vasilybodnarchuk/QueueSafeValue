//
//  QueueSafeValueConcrete.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/17/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Class for inheritance that provides common `QueueSafaValue` functionality
public class QueueSafeValueConcrete<Value> {

    /// Retains the original instance of the `value` and provides thread-safe (queue-safe) access to it.
    let valueContainer: ValueContainer<Value>

    /**
     Initialize object with properties.
     - Parameter value: Instance of the `value` that we are going to read/write from one or several DispatchQueues.
     - Returns: Container that provides limited and thread safe access to the `value`.
     */
    public init (value: Value) { valueContainer = ValueContainer(value: value) }
}

// MARK: QueueSafeValueInterface
extension QueueSafeValueConcrete: QueueSafeValueInterface { }
