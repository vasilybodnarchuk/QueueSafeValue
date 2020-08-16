//
//  Queues.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class Queues {
    private static var queues : [DispatchQueue] = {
        return [
            .global(qos: .background),
            .global(qos: .default),
            .global(qos: .unspecified),
            .global(qos: .userInitiated),
            .global(qos: .userInteractive),
            .global(qos: .utility)
        ]
    }()
    
    class func getRandomArray() -> [DispatchQueue] {
        let count = (10..<20).randomElement()!
        return (0...count).map { _ in queues.randomElement()! }
    }
}
