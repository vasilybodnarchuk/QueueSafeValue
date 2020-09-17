//
//  QueueSafeValueInterface.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/16/20.
//

import Foundation

protocol QueueSafeValueInterface: class {
    associatedtype Value
    var valueContainer: ValueContainer<Value> { get }
    init (value: Value)
}

extension QueueSafeValueInterface where Value: AnyObject {
    /**
     Get retain count of wrapped value
     - Note: only for objects
     - Returns:retain count of wrapped value
     */
    func countObjectReferences() -> CFIndex { valueContainer.countObjectReferences() }
}
