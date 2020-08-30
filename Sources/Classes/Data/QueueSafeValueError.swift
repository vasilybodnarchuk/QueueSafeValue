//
//  QueueSafeValueError.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//

import Foundation

public enum QueueSafeValueError: Error {
    case valueContainerDeinited
    case valueAccessFuncWasNotPerformed
    case unexpected(error: Error)
}

extension QueueSafeValueError: Equatable {}
