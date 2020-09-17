//
//  QueueSafeValueInterface.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/16/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Interface of ` QueueSafeValue` based type
protocol QueueSafeValueInterface {

    /// The type of `value` that is stored in `valueContainer` and has thread-safe (queue-safe) access to it.
    associatedtype Value

    /// Retains the original instance of the `value` and provides thread-safe (queue-safe) access to it.
    var valueContainer: ValueContainer<Value> { get }
}

extension QueueSafeValueInterface where Value: AnyObject {
    /**
     Get retain count of wrapped value
     - Note: only for objects
     - Returns:retain count of wrapped value
     */
    func countObjectReferences() -> CFIndex { valueContainer.countObjectReferences() }
}
