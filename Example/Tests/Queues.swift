//
//  Queues.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class Queues {
    private static var queues : Set<DispatchQueue> = {
        [
            .global(qos: .background),
            .global(qos: .default),
            .global(qos: .unspecified),
            .global(qos: .userInitiated),
            .global(qos: .userInteractive),
            .global(qos: .utility)
        ]
    }()

    class func getUniqueRandomQueues(count: Int) -> [DispatchQueue]  {
        if count >= queues.count { fatalError() }
        var availableQueues = queues
        return (0..<count).map {_ in 
            let queue = availableQueues.randomElement()!
            availableQueues.remove(queue)
            return queue
        }
    }

    
    class var random: DispatchQueue { queues.randomElement()! }
    
    class func getRandomArray() -> [DispatchQueue] {
        let count = (10..<20).randomElement()!
        return (0...count).map { _ in random }
    }
}

