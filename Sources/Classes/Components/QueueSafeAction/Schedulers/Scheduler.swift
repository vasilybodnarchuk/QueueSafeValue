//
//  Scheduler.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/16/20.
//

import Foundation

/// Describes the order in which sync/async access to the `value` enclosed in the `ValueContainer `object will be granted.
public class Scheduler<Value> {

    /// Retains the original instance of the `value` and provides thread-safe access to it.
    private(set) weak var valueContainer: ValueContainer<Value>?

    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original `value` instance and provides thread-safe access to it.
     - Returns: An object that describes when (in what order) the `value` enclosed in the `ValueContainer` will be accessed.
     */
    init(valueContainer: ValueContainer<Value>) { self.valueContainer = valueContainer }
}
