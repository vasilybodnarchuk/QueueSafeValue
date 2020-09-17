//
//  SchedulerInterface.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/17/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

protocol SchedulerInterface {
    associatedtype Value
    var valueContainerReference: ValueContainer<Value>? { get }
}
