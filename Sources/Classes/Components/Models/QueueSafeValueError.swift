//
//  QueueSafeValueError.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import Foundation

public enum QueueSafeValueError: Error {
    case valueContainerDeinited
    case unexpected(error: Error)
}

extension QueueSafeValueError: Equatable {}
