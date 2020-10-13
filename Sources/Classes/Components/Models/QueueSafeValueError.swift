//
//  QueueSafeValueError.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

/// Defines all possible errors
public enum QueueSafeValueError: Error {
    case valueContainerDeinited
    case unexpected(error: Error)
    case commandClosureDeallocated
}

// MARK: Equatable
extension QueueSafeValueError: Equatable {}
