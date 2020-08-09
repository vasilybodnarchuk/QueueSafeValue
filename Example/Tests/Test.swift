//
//  Test.swift
//  QueueSafeValue_Example
//
//  Created by Vasily on 8/9/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class Test<T> {
    let queueSafeValue: QueueSafeValue<T>
    let value: T
    private var queues: [DispatchQueue]
    private(set) var iterationsCountPerQueue: Int
    private(set) lazy var expectedMeasurementsCount = iterationsCountPerQueue*queues.count
    private let dispatchGroup: DispatchGroup
    private let description: String!
    private let resultClosure: ((Test<T>) -> Void)
    
    init (value: T, description: String,
          queues: [DispatchQueue] = [],
          iterationsCountPerQueue: Int = 10_000,
          resultClosure: @escaping ((Test<T>) -> Void)) {
        queueSafeValue = .init(value: value)
        dispatchGroup = DispatchGroup()
        self.value = value
        if queues.isEmpty {
            self.queues =  Queues.getRandomArray()
        } else {
            self.queues = queues
        }
        self.description = description
        self.resultClosure = resultClosure
        self.iterationsCountPerQueue = iterationsCountPerQueue
    }
}

extension Test {
    func run(closure: @escaping (Int, QueueSafeValue<T>, Date, inout Date) -> Void) {
        let retainCount = (queueSafeValue as? QueueSafeValue<SimpleClass>)?.getRetainCount()
        describe(description) {
            waitUntil(timeout: 100) { done in
                self.dispatchGroup.notify(queue: .global(qos: .unspecified)) {
                    self.resultClosure(self)
                    if let retainCount2 = (self.queueSafeValue as? QueueSafeValue<SimpleClass>)?.getRetainCount() {
                        it("expect to have the same retain count") {
                            expect(retainCount) == retainCount2
                        }
                    }
                    done()
                }
                DispatchQueue.global(qos: .unspecified).async {
                    for iteration in 0..<self.iterationsCountPerQueue {
                        self.queues.enumerated().forEach { (index, queue) in
                            self.dispatchGroup.enter()
                            queue.async {
                                let step = iteration*self.queues.count + index
                                let startTime = Date()
                                var endDate = startTime
                                closure(step, self.queueSafeValue, startTime, &endDate)
                                // expect closure not to run asynchronously
                                expect(endDate) > startTime
                                self.dispatchGroup.leave()
                            }
                        }
                    }
                    self.dispatchGroup.wait()
                }
            }
        }
    }
}
