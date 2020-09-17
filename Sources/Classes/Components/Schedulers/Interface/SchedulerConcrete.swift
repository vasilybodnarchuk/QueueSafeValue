//
//  SchedulerConcrete.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/16/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation


/// Class for inheritance that provides common `Scheduler` functionality.
public class SchedulerConcrete<Value>: SchedulerInterface {

    /// Retains the original instance of the `value` and provides thread-safe access to it.
    weak var valueContainerReference: ValueContainer<Value>?

    /**
     Initialize object with properties.
     - Parameter valueContainer: an object that stores the original `value` instance and provides  queue-safe (thread-safe) access to it.
     - Returns: An object that describes when (in what order) the `value` enclosed in the `value container` will be accessed.
     */
    init(valueContainer: ValueContainer<Value>) { self.valueContainerReference = valueContainer }
}
