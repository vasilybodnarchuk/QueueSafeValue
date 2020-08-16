//
//  QueueSafeScheduler.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/8/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Describes when (in what order) access to the `ValueContainer` object will be granted.
public class QueueSafeScheduler<Value> {
    
    /// Retains the original instance of the value and provides thread-safe access to it.
    private weak var valueContainer: ValueContainer<Value>?
    
    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original value instance and provides thread-safe access to it
     - Returns: An object that describes when (in what order) the value enclosed in the ValueContainer will be accessed.
     */
    init(valueContainer: ValueContainer<Value>) { self.valueContainer = valueContainer }
    
    /// Queues available functions and executes them in the correct order.
    public var performLast: QueueSafeAction.WaitAction<Value> { .init(valueContainer: valueContainer) }
}
