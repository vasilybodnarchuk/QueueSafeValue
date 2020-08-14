//
//  QueueSafeAction.swift
//  QueueSafeValue
//
//  Created by Vasily on 8/8/20.
//

import Foundation

public class QueueSafeAction {
    
    public class When<Value> {

        private weak var valueContainer: ValueContainer<Value>?
        init(valueContainer: ValueContainer<Value>) {
            self.valueContainer = valueContainer
        }
        
        public var performLast: QueueSafeAction.WaitAction<Value> {
            .init(valueContainer: valueContainer)
        }
    }
}
