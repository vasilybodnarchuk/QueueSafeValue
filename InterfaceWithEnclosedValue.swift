//
//  InterfaceWithEnclosedValue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 9/17/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Interface a type that communicate with `value container`.
public protocol InterfaceWithEnclosedValue {

    /// The type of `value` that is stored in `value container` and has queue-safe (thread-safe) access to it.
    associatedtype Value
}
