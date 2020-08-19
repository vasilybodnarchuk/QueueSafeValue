//
//  Test.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 8/9/20.
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
        let retainCount = (queueSafeValue as? QueueSafeValue<SimpleClass>)?.countObjectReferences()
        describe(description) {
            waitUntil(timeout: 100) { done in
                DispatchQueue.global(qos: .unspecified).async {
                    var count = 0
                    for iteration in 0..<self.iterationsCountPerQueue {
                        self.queues.enumerated().forEach { (index, queue) in
                            let iteration = iteration*self.queues.count + index
                            self.dispatchGroup.enter()
                            queue.async {
                                let startTime = Date()
                                var endDate = startTime
                                closure(iteration, self.queueSafeValue, startTime, &endDate)
                                expect(endDate) >= startTime
                                self.dispatchGroup.leave()
                            }
                            count = iteration
                        }
                    }

                    self.dispatchGroup.notify(queue: .global(qos: .unspecified)) {
                        self.resultClosure(self)
                        if let retainCount2 = (self.queueSafeValue as? QueueSafeValue<SimpleClass>)?.countObjectReferences() {
                            it("expected to have the same retain count") {
                                expect(retainCount) == retainCount2
                            }
                        }
                        it("expected to execute all iterations") {
                            expect(count) == self.expectedMeasurementsCount - 1
                        }
                        done()
                    }
                    self.dispatchGroup.wait()
                }
            }
        }
    }
}
