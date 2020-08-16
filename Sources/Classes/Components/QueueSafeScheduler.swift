//
//  QueueSafeScheduler.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/8/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Describes how access to the  `value` wrapped in `ValueContainer` object will be granted (synchronously or asynchronously) .
public class QueueSafeScheduler<Value> {
    
    /// Retains the original instance of the `value` and provides thread-safe access to it.
    private weak var valueContainer: ValueContainer<Value>?
    
    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original value instance and provides thread-safe access to it.
     - Returns: An object that describes when (in what order) the value enclosed in the ValueContainer will be accessed.
     */
    init(valueContainer: ValueContainer<Value>) { self.valueContainer = valueContainer }
    
    /// Performs functions in `built-in run queue` (that is integrated in `ValueContainer` object).
    /// `lowPriority` means that every available function (which manipulates the value) will be added to the end of the `built-in run queue`.
    /// The function with `lowPriority` will wait for all other higher priority functions to complete.
    /// The function with `lowPriority` will execute sequentially, blocking the current queue in which it is executing.
    public var lowPriority: QueueSafeAction.LowPriorityActions<Value> { .init(valueContainer: valueContainer) }
}
