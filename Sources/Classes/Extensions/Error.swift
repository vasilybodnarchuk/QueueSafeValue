//
//  Error.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/27/20.
//

import Foundation

extension Error {
    func toQueueSafeValueError() -> QueueSafeValueError {
        if let error = self as? QueueSafeValueError {
            return error
        } else {
            return .unexpected(error: self)
        }
    }
}

public func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}

extension Equatable where Self : Error {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
}
