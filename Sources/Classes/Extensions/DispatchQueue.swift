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

// Detect currrent queue

extension DispatchQueue {

    private struct QueueReference { weak var queue: DispatchQueue? }

    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        setupSystemQueuesDetection(key: key)
        return key
    }()

    private static func _registerDetection(of queues: [DispatchQueue], key: DispatchSpecificKey<QueueReference>) {
        queues.forEach { $0.setSpecific(key: key, value: QueueReference(queue: $0)) }
    }

    private static func setupSystemQueuesDetection(key: DispatchSpecificKey<QueueReference>) {
        let queues: [DispatchQueue] = [
                                        .main,
                                        .global(qos: .background),
                                        .global(qos: .default),
                                        .global(qos: .unspecified),
                                        .global(qos: .userInitiated),
                                        .global(qos: .userInteractive),
                                        .global(qos: .utility)
                                    ]
        _registerDetection(of: queues, key: key)
    }
}

// MARK: public functionality

public
extension DispatchQueue {
    static var currentQueueLabel: String? { current?.label }
    static var current: DispatchQueue? { getSpecific(key: key)?.queue }
    static func registerDetection(of queue: DispatchQueue) { _registerDetection(of: [queue], key: key) }
}
