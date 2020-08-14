//
//  QueueSafeAction.swift
//  QueueSafeValue
//
//  Created by Vasily on 8/8/20.
//

import Foundation

/// Provides syntax sugar to access to  weak reference to `ValueContainer` object and restricts its functionality.

public class QueueSafeAction {
    
    /// Describes when (in what order) access to the `ValueContainer` object will be granted.
    
    public class When<Value> {
        
        /// Retains the original instance of the value and provides thread-safe access to it.
        private weak var valueContainer: ValueContainer<Value>?
        
        /**
         Initialize value container with properties.
         
         - Parameters:
            - valueContainer: an object that stores the original value instance and provides thread-safe access to it
         
         - Returns: object that describes when (in what order) access to the `ValueContainer` object will be granted.
         */
        init(valueContainer: ValueContainer<Value>) {
            self.valueContainer = valueContainer
        }
        
        /// Queues available functions and executes them in the correct order.

        public var performLast: QueueSafeAction.WaitAction<Value> {
            .init(valueContainer: valueContainer)
        }
    }
}
