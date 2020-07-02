// https://github.com/Quick/Quick

import Quick
import Nimble
import QueueSafeValue

class TableOfContentsSpec: QuickSpec {
    
    override func spec() {
        describe("Queue Safe Value") {
            var queueSafeValue: QueueSafeValue<Int>!
            var queue: DispatchQueue!
            
            beforeEach {
                queueSafeValue = QueueSafeValue(value: 0)
                queue = self.createQueue()
            }
            
            context("secure simultaneous value access from different queues") {
                
                let iterationsCountPerQueue = 10000
                let queues: [DispatchQueue] = [.global(qos: .userInitiated),
                                               .global(qos: .userInteractive),
                                               .global(qos: .utility),
                                               .global(qos: .utility),
                                               .global(qos: .utility),
                                               .global(qos: .utility),
                                               .global(qos: .default),
                                               .global(qos: .unspecified),
                                               .global(qos: .background)]
                
                testMultiQueueValueAsyncAccess(description: "update",
                                               iterationsCountPerQueue: iterationsCountPerQueue,
                                               queues: queues,
                                               closure: { _ in
                                                    queueSafeValue.syncInCurrentQueue.update { $0 += 1 }
                                               },
                                               completion: {
                                                    expect(iterationsCountPerQueue * queues.count) == queueSafeValue.syncInCurrentQueue.get()!
                                               })
                
                testMultiQueueValueAsyncAccess(description: "set and get",
                                               iterationsCountPerQueue: iterationsCountPerQueue,
                                               queues: queues,
                                               closure: { step in
                                                    queueSafeValue.syncInCurrentQueue.set(value: step)
                                                    let valueInRange = 0...(iterationsCountPerQueue*queues.count) ~= queueSafeValue.syncInCurrentQueue.get()!
                                                    expect(valueInRange).to(beTrue())

                                               },
                                               completion: {
                                                    expect(iterationsCountPerQueue * queues.count) == queueSafeValue.syncInCurrentQueue.get()!
                                               })
                
                testMultiQueueValueAsyncAccess(description: "set new value and return old",
                                               iterationsCountPerQueue: iterationsCountPerQueue,
                                               queues: queues,
                                               closure: { step in
                                                    let previousValue = queueSafeValue.syncInCurrentQueue.setNewValueAndReturnOld(new: step)!
                                                    expect(previousValue) != step
                                               },
                                               completion: {
                                                    expect(iterationsCountPerQueue * queues.count) == queueSafeValue.syncInCurrentQueue.get()!
                                               })
                
                testMultiQueueValueAsyncAccess(description: "all funcs",
                                               iterationsCountPerQueue: iterationsCountPerQueue,
                                               queues: queues,
                                               closure: { _ in
                                                    let value = queueSafeValue.syncInCurrentQueue.get()!
                                                    queueSafeValue.syncInCurrentQueue.set(value: value + 1)
                                                    expect(queueSafeValue.syncInCurrentQueue.get()!) != value
                                                    _ = queueSafeValue.syncInCurrentQueue.map { "\($0)" }
                                                    queueSafeValue.syncInCurrentQueue.update { expect(value) != $0 }
                                               },
                                               completion: {
                                                   expect(iterationsCountPerQueue * queues.count) == queueSafeValue.syncInCurrentQueue.get()!
                                               })
                
            }
            
            context("secure value access from single queue") {
                
                it("locks current queue while setting value") {
                    waitUntil(timeout: 10) { completionClosure in
                        queue.async {
                            var date1 = Date()
                            for i in 0...100 {
                                var date2 = Date()
                                expect(date2) > date1
                                date1 = date2
                                queueSafeValue.syncInCurrentQueue.update { currentValue in
                                    expect(i) == currentValue
                                    currentValue += 1
                                    usleep(50_000)
                                }
                                date2 = Date()
                                expect(date2) > date1
                                date1 = date2
                            }
                            completionClosure()
                        }
                    }
                }
            }
        }
    }
    
    func testMultiQueueValueAsyncAccess(description: String,
                                        iterationsCountPerQueue: Int,
                                        queues: [DispatchQueue],
                                        closure: @escaping (Int) -> Void,
                                        completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        var count = 0
        it(description) {
            waitUntil(timeout: 100) { done in
                dispatchGroup.notify(queue: .main) {
                    completion()
                    done()
                }
                
                for _ in 0..<iterationsCountPerQueue {
                    queues.forEach { queue in
                        dispatchGroup.enter()
                        queue.async {
                            var value: Int!
                            semaphore.wait()
                            count += 1
                            value = count
                            semaphore.signal()
                            
                            closure(value)
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.wait()
            }
        }
    }
    
    func createQueue(qos: DispatchQoS = .default) -> DispatchQueue {
        DispatchQueue(label: "\(Date())", qos: qos, attributes: .concurrent)
    }
}
