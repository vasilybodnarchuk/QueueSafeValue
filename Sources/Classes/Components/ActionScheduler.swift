//
//  ActionScheduler.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/16/20.
//

import Foundation

/// Describes how access to the  `value` wrapped in `ValueContainer` object will be granted (synchronously or asynchronously) .
public class ActionScheduler<Value> {
    
    /// Retains the original instance of the `value` and provides thread-safe access to it.
    private(set) weak var valueContainer: ValueContainer<Value>?
    
    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original value instance and provides thread-safe access to it.
     - Returns: An object that describes when (in what order) the value enclosed in the ValueContainer will be accessed.
     */
    init(valueContainer: ValueContainer<Value>) { self.valueContainer = valueContainer }
}
