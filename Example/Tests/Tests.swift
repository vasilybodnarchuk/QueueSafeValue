// https://github.com/Quick/Quick

import Quick
import Nimble
import QueueSafeValue

class Measurements {
    
    private var delay: useconds_t = 0
    private lazy var delayInSec = Double(delay)/1_000_000
    let expectRetainCountRange: ClosedRange<Int>
    var results = [Measurement]()
    
    init(expectRetainCountRange: ClosedRange<Int> = 3...3) {
        self.expectRetainCountRange = expectRetainCountRange
    }
    
    func measure(startTime: Date) {
        results.append(Measurement(tag: results.count,
                                   startTime: startTime,
                                   delay: delay,
                                   retainCount: CFGetRetainCount(self)))
    }
    
    func checkResult(expectedRecordsCount: Int) {
        it("expect the object's reference count does not increase") {
            var retainCounts = Set<Int>()
            for measurement in self.results {
                retainCounts.insert(measurement.retainCount)
            }
            expect(self.expectRetainCountRange.min()) <= retainCounts.min()!
            expect(self.expectRetainCountRange.max()) >= retainCounts.max()!
        }
        
        it("expect measurements added to array consistently") {
            for index in 1..<self.results.count {
                expect(self.results[index].endTime.timeIntervalSince1970 - self.results[index-1].endTime.timeIntervalSince1970) >= self.delayInSec
            }
        }
        it("expect \(expectedRecordsCount) measurements") {
            expect(self.results.count) == expectedRecordsCount
        }
    }
}

extension Measurements: Equatable {
    static func == (lhs: Measurements, rhs: Measurements) -> Bool {
        lhs.results == rhs.results
    }
}

extension Measurements {
    struct Measurement {
        let tag: Int
        let startTime: Date
        let endTime: Date
        let retainCount: Int
        init(tag: Int, startTime: Date, delay: useconds_t, retainCount: Int) {
            self.tag = tag
            self.retainCount = retainCount
            self.startTime = startTime
            if delay > 0 { usleep(delay) }
            endTime = Date()
        }
        
        var executingTime: TimeInterval {
            endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
        }
    }
}

extension Measurements.Measurement: Equatable { }

class TableOfContentsSpec: QuickSpec {
    
    override func spec() {
        testWaitWhileActions()
    }
}

// MARK: Tess sync actions

extension TableOfContentsSpec {
    
    private func testWaitWhileActions() {
        describe("Queue Safe Value") {
            context("serial access to the value from different async queues") {
       
                singleQueueTest(funcName: "wait actions",
                                result: "expected to be executed one buy one in one queue") { _, queueSafeValue in
                    for i in 1..<100_000 {
                        queueSafeValue.wait.performLast!.set(value: i)
                        var value = queueSafeValue.wait.performLast!.get()
                        expect(value) == i
                        let string = queueSafeValue.wait.performLast!.transform { "\($0)" }
                        expect(string) == "\(i)"
                        value = queueSafeValue.wait.performLast!.updated { $0 += 1 }
                        expect(value) == i + 1
                        queueSafeValue.wait.performLast!.update { $0 += 1 }
                        value = queueSafeValue.wait.performLast!.get()
                        expect(value) == i + 2
                        value = nil
                        queueSafeValue.wait.performLast!.perform { value = $0 }
                        expect(value) == i + 2
                    }
                }
                
                multiQueueTest(value: 1, funcName: "wait actions",
                               result: "not expected to get deadlock",
                               iterations: 100_000) { step, queueSafeValue in
                    let action = queueSafeValue.wait.performLast!
                    let value1 = action.get()
                    action.set(value: step)
                    let value2 =  action.get()
                    expect(value1) != value2
                    let value3 = action.transform { 2*$0 }
                    expect(value3) != value2
                    action.perform { _ in usleep(1) }
                    var value4: Int!
                    let value5 = action.updated { value in
                        value4 = value
                        value += 1
                    }
                    expect(value4+1) == value5
                    action.update { $0 += 1 }
                }
                
                
                /// ready
                
//                testReplacingValueInUpdateFunc(funcName: "updated") { _, queueSafeValue, startTime, endTime in
//                    var _endTime: Date!
//                    queueSafeValue.waitWhile.update { value in
//                        value = value + 1
//                        _endTime = Date()
//                    }
//                    endTime = _endTime
//                }
//
//                TestAccessTo(value: Measurements(),
//                             description: "test update func")
//                    .run { _, queueSafeValue, startTime, endTime in
//                        var _endTime: Date!
//                        queueSafeValue.waitWhile.update { measurements in
//                            measurements.measure(startTime: startTime)
//                            _endTime = measurements.results.last!.endTime
//                        }
//                        endTime = _endTime
//                }
//
//                testReplacingValueInUpdateFunc(funcName: "updated") { _, queueSafeValue, startTime, endTime in
//                    var _endTime: Date!
//                    _ = queueSafeValue.waitWhile.updated { value in
//                        value = value + 1
//                        _endTime = Date()
//                    }
//                    endTime = _endTime
//                }
//
//                TestAccessTo(value: Measurements(expectRetainCountRange: 4...9),
//                             description: "test updated func")
//                    .run { _, queueSafeValue, startTime, endTime in
//                        var _endTime: Date!
//                        var countBeforeUpdate: Int!
//                        let countAfterUpdate = queueSafeValue.waitWhile.updated { measurements in
//                            countBeforeUpdate = measurements.results.count
//                            measurements.measure(startTime: startTime)
//                            _endTime = measurements.results.last!.endTime
//                            }!.results.count
//                        endTime = _endTime
//                        expect(countBeforeUpdate) < countAfterUpdate
//                }
                
            }
        }
    }
    
    private func testReplacingValueInUpdateFunc(funcName: String,
                                                closure: @escaping (Int, QueueSafeValue<Int>, Date, inout Date) -> Void) {
        let description = "test replacing value in \(funcName)"
        TestAccessTo<Int>(value: 0, description: description) { testObj in
            it("expect to be \(testObj.expectedMeasurementsCount)") {
                //expect(testObj.queueSafeValue.waitWhile.get()!) == testObj.expectedMeasurementsCount
            }
        }.run(closure: closure)
    }
    
    private func singleQueueTest(value: Int = 0, funcName: String,
                                 result: String, iterations: Int = 1,
                                 closure: @escaping (Int, QueueSafeValue<Int>) -> Void) {
        let description = "test \(funcName) func in single queue"
        TestAccessTo(value: value, description: description,
                     queues: [.global(qos: .unspecified)],
                     iterationsCountPerQueue: iterations) { _ in
            it(result) { }
        }.run { iteration, queueSafeValue, startTime, endTime in
            closure(iteration, queueSafeValue)
            endTime = Date()
        }
    }
    
    private func multiQueueTest(value: Int = 0, funcName: String,
                                result: String, iterations: Int = 1_000,
                                closure: @escaping (Int, QueueSafeValue<Int>) -> Void) {
        let description = "test \(funcName) func in several queues"
        TestAccessTo(value: value, description: description,
                     queues: [.global(qos: .unspecified)],
                     iterationsCountPerQueue: iterations) { _ in
            it(result) { }
        }.run { iteration, queueSafeValue, startTime, endTime in
            closure(iteration, queueSafeValue)
            endTime = Date()
        }
    }
}

class TestAccessTo<T> {
    let queueSafeValue: QueueSafeValue<T>
    let value: T
    private var queues: [DispatchQueue]
    private(set) var iterationsCountPerQueue: Int
    private(set) lazy var expectedMeasurementsCount = iterationsCountPerQueue*queues.count
    private let dispatchGroup: DispatchGroup
    private let description: String!
    private let resultClosure: ((TestAccessTo<T>) -> Void)
    
    init (value: T, description: String,
          queues: [DispatchQueue] = [],
          iterationsCountPerQueue: Int = 10_000,
          resultClosure: @escaping ((TestAccessTo<T>) -> Void)) {
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
    
    func run(closure: @escaping (Int, QueueSafeValue<T>, Date, inout Date) -> Void) {
        describe(description) {
            waitUntil(timeout: 100) { done in
                self.dispatchGroup.notify(queue: .global(qos: .unspecified)) {
                    self.resultClosure(self)
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

//extension TestAccessTo where T: Measurements {
//    convenience init(value: T, description: String) {
//        self.init(value: value, description: description) { testObj in
//            testObj.queueSafeValue.waitWhile.get()!.checkResult(expectedRecordsCount: testObj.expectedMeasurementsCount)
//        }
//    }
//}
