//
//  SchedulerInterface.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/17/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Interface of `scheduler` based type
protocol SchedulerInterface: InterfaceWithEnclosedValue {

    /// Reference to `value container` that retains the original instance of the `value` and provides queue-safe (thread-safe) access to it.
    var valueContainerReference: ValueContainer<Value>? { get }
}
