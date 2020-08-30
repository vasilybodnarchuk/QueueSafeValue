//
//  DispatchQueue.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 8/18/20.
//

import Foundation

extension DispatchQueue {
    class func createSerialAccessQueue() -> DispatchQueue {
        let label = "accessQueue.\(type(of: self)).\(Date().timeIntervalSince1970)"
        return DispatchQueue(label: label,
                             qos: .default,
                             attributes: [],
                             autoreleaseFrequency: .inherit,
                             target: nil)
    }
}
