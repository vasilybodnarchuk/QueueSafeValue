// https://github.com/Quick/Quick

import Quick
import Nimble
import QueueSafeValue
//
//class Measurements {
//
//    private var delay: useconds_t = 0
//    private lazy var delayInSec = Double(delay)/1_000_000
//    let expectRetainCountRange: ClosedRange<Int>
//    var results = [Measurement]()
//
//    init(expectRetainCountRange: ClosedRange<Int> = 3...3) {
//        self.expectRetainCountRange = expectRetainCountRange
//    }
//
//    func measure(startTime: Date) {
//        results.append(Measurement(tag: results.count,
//                                   startTime: startTime,
//                                   delay: delay,
//                                   retainCount: CFGetRetainCount(self)))
//    }
//
//    func checkResult(expectedRecordsCount: Int) {
//        it("expect the object's reference count does not increase") {
//            var retainCounts = Set<Int>()
//            for measurement in self.results {
//                retainCounts.insert(measurement.retainCount)
//            }
//            expect(self.expectRetainCountRange.min()) <= retainCounts.min()!
//            expect(self.expectRetainCountRange.max()) >= retainCounts.max()!
//        }
//
//        it("expect measurements added to array consistently") {
//            for index in 1..<self.results.count {
//                expect(self.results[index].endTime.timeIntervalSince1970 - self.results[index-1].endTime.timeIntervalSince1970) >= self.delayInSec
//            }
//        }
//        it("expect \(expectedRecordsCount) measurements") {
//            expect(self.results.count) == expectedRecordsCount
//        }
//    }
//}
//
//extension Measurements: Equatable {
//    static func == (lhs: Measurements, rhs: Measurements) -> Bool {
//        lhs.results == rhs.results
//    }
//}
//
//extension Measurements {
//    struct Measurement {
//        let tag: Int
//        let startTime: Date
//        let endTime: Date
//        let retainCount: Int
//        init(tag: Int, startTime: Date, delay: useconds_t, retainCount: Int) {
//            self.tag = tag
//            self.retainCount = retainCount
//            self.startTime = startTime
//            if delay > 0 { usleep(delay) }
//            endTime = Date()
//        }
//
//        var executingTime: TimeInterval {
//            endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
//        }
//    }
//}

class SimpleClass { var value = 0 }

//extension Measurements.Measurement: Equatable { }

class TableOfContentsSpec: QuickSpec {
    
    override func spec() {
        testWaitWhileActions()
    }
}

// MARK: Tess sync actions

extension TableOfContentsSpec {
    
    private func testWaitWhileActions() {
        describe("Queue Safe Value") {
            context("test wait actions") {
                

                executeSeriallyInsideOneQueue(value: 0,
                                              result: "expected to be executed one buy one in one queue") { i, queueSafeValue in
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
                
                executeAsynchronouslyInsideOneQueue(value: 0,
                                                    result: "not expected to get deadlock") { i, queueSafeValue in
                                                var value1 = queueSafeValue.wait.performLast!.get()
                                                expect(value1).notTo(beNil())
                                                
                                                queueSafeValue.wait.performLast!.set(value: i)
                                                var value2 = queueSafeValue.wait.performLast!.get()
                                                expect(value1).notTo(beNil())
                                                
                                                var string1: String!
                                                let string2 = queueSafeValue.wait.performLast!.transform { value -> String in
                                                    string1 = "\(value)"
                                                    return "\(value)"
                                                }
                                                expect(string1) == string2
                                                
                                                value1 = nil
                                                value2 = queueSafeValue.wait.performLast!.updated { value in
                                                    value1 = value + 1
                                                    value += 1
                                                }
                                                expect(value1) == value2
                                                        
                                                value1 = nil
                                                queueSafeValue.wait.performLast!.update {
                                                    $0 += 1
                                                    value1 = $0
                                                }
                                                expect(value1).notTo(beNil())

                                                value1 = nil
                                                queueSafeValue.wait.performLast!.perform { value1 = $0 }
                                                expect(value1).notTo(beNil())
                }
                
                executeSeriallyInsideOneQueue(value: SimpleClass(),
                                              result: "expected to be executed one buy one in one queue") { i, queueSafeValue in
                                                queueSafeValue.wait.performLast!.update { $0.value = i }
                                                var value = queueSafeValue.wait.performLast!.get()!.value
                                                expect(value) == i
                                                let string = queueSafeValue.wait.performLast!.transform { "\($0.value)" }
                                                expect(string) == "\(i)"
                                                value = queueSafeValue.wait.performLast!.updated(closure: { $0.value += 1 })!.value
                                                expect(value) == i + 1
                                                value = i
                                                queueSafeValue.wait.performLast!.perform { value = $0.value }
                                                expect(value) == i + 1
                }
            }
        }
    }

//    private func singleQueueTest<T>(value: T, result: String, iterations: Int = 1,
//                                    iterationClosure: @escaping (Int, QueueSafeValue<T>) -> Void) {
//        let description = "in single queue"
//        Test(value: value, description: description,
//             queues: [.global(qos: .unspecified)],
//             iterationsCountPerQueue: iterations) { _ in
//                it(result) { }
//        }.run { iteration, queueSafeValue, startTime, endTime in
//            iterationClosure(iteration, queueSafeValue)
//            endTime = Date()
//        }
//    }
//
//    private func singleQueueTest<T: AnyObject>(value: T, result: String, iterations: Int = 1,
//                                               iterationClosure: @escaping (Int, QueueSafeValue<T>) -> Void) {
//        let description = "in single queue"
//        Test(value: value, description: description,
//             queues: [.global(qos: .unspecified)],
//             iterationsCountPerQueue: iterations) { _ in
//                it(result) { }
//        }.run { iteration, queueSafeValue, startTime, endTime in
//            iterationClosure(iteration, queueSafeValue)
//            endTime = Date()
//        }
//    }
    
    func executeAsynchronouslyInsideOneQueue<T>(value: T, result: String, iterations: Int = 10_000,
                                                iterationClosure: @escaping (Int, QueueSafeValue<T>) -> Void) {
        let description = "executed asynchronously inside one queue"
        Test(value: value, description: description,
             queues: [.global(qos: .unspecified)],
             iterationsCountPerQueue: iterations) { _ in
                it(result) { }
        }.run { iteration, queueSafeValue, startTime, endTime in
            iterationClosure(iteration, queueSafeValue)
            endTime = Date()
        }
    }
    
    func executeSeriallyInsideOneQueue<T>(value: T, result: String, iterations: Int = 10_000,
                                          iterationClosure: @escaping (Int, QueueSafeValue<T>) -> Void) {
        let description = "executed serially inside one queue"
        Test(value: value, description: description,
             queues: [.global(qos: .unspecified)],
             iterationsCountPerQueue: 1) { _ in
                it(result) { }
        }.run { _, queueSafeValue, startTime, endTime in
            for i in 0..<iterations { iterationClosure(i, queueSafeValue) }
            endTime = Date()
        }
    }
}
