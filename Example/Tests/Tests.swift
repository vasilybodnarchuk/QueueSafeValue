// https://github.com/Quick/Quick

import Quick
import Nimble
import QueueSafeValue

class SimpleClass { var value = 0 }

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        testWaitWhileActions()
        useCases()
    }
    
    private func useCases() {
        /// Create QueueSafeValue
        let queueSafeValue = QueueSafeValue(value: 0)
        
        /// Base structure of command
        //queueSafeValue.wait.lowPriority.
    }
}

// MARK: Tess sync actions

extension TableOfContentsSpec {
    
    private func testWaitWhileActions() {
        describe("Queue Safe Value") {
            context("test wait actions") {
                executeSeriallyInsideOneQueue(value: 0,
                                              result: "expected that basic functionality works") { i, queueSafeValue in
                                                queueSafeValue.wait.lowPriority.set(value: i)
                                                var value = queueSafeValue.wait.lowPriority.get()
                                                expect(value) == i
                                                
                                                let string = queueSafeValue.wait.lowPriority.transform { "\($0)" }
                                                expect(string) == "\(i)"
                                               
                                                value = queueSafeValue.wait.lowPriority.updated { $0 += 1 }
                                                expect(value) == i + 1
                                                
                                                queueSafeValue.wait.lowPriority.update { $0 += 1 }
                                                value = queueSafeValue.wait.lowPriority.get()
                                                expect(value) == i + 2
                                                
                                                value = nil
                                                queueSafeValue.wait.lowPriority.perform { value = $0 }
                                                expect(value) == i + 2
                }
                
                executeAsynchronouslyInsideOneQueue(value: 0,
                                                    result: "not expected to get deadlock") { i, queueSafeValue in
                                                        var value1 = queueSafeValue.wait.lowPriority.get()
                                                        expect(value1).notTo(beNil())
                                                        
                                                        queueSafeValue.wait.lowPriority.set(value: i)
                                                        var value2 = queueSafeValue.wait.lowPriority.get()
                                                        expect(value1).notTo(beNil())
                                                        
                                                        var string1: String!
                                                        let string2 = queueSafeValue.wait.lowPriority.transform { value -> String in
                                                            string1 = "\(value)"
                                                            return "\(value)"
                                                        }
                                                        expect(string1) == string2
                                                        
                                                        value1 = nil
                                                        value2 = queueSafeValue.wait.lowPriority.updated { value in
                                                            value1 = value + 1
                                                            value += 1
                                                        }
                                                        expect(value1) == value2
                                                        
                                                        value1 = nil
                                                        queueSafeValue.wait.lowPriority.update {
                                                            $0 += 1
                                                            value1 = $0
                                                        }
                                                        expect(value1).notTo(beNil())
                                                        
                                                        value1 = nil
                                                        queueSafeValue.wait.lowPriority.perform { value1 = $0 }
                                                        expect(value1).notTo(beNil())
                }
                
                executeSeriallyInsideOneQueue(value: SimpleClass(),
                                              result: "expected that basic functionality works") { i, queueSafeValue in
                                                queueSafeValue.wait.lowPriority.update { $0.value = i }
                                                expect(queueSafeValue.getRetainCount()) == 4
                                                
                                                var value = queueSafeValue.wait.lowPriority.get()!.value
                                                expect(value) == i
                                                expect(queueSafeValue.getRetainCount()) == 4
                                                
                                                let string = queueSafeValue.wait.lowPriority.transform { "\($0.value)" }
                                                expect(string) == "\(i)"
                                                expect(queueSafeValue.getRetainCount()) == 4
                                                
                                                var object = queueSafeValue.wait.lowPriority.updated(closure: { $0.value += 1 })
                                                expect(object!.value) == i + 1
                                                expect(queueSafeValue.getRetainCount()) == 5
                                                object = nil
                                                
                                                value = i
                                                queueSafeValue.wait.lowPriority.perform { value = $0.value }
                                                expect(value) == i + 1
                                                expect(queueSafeValue.getRetainCount()) == 4
                }
                
                executeAsynchronouslyInsideOneQueue(value: SimpleClass(),
                                                    result: "not expected to get deadlock") { i, queueSafeValue in
                                                        var value1 = queueSafeValue.wait.lowPriority.get()?.value
                                                        expect(value1).notTo(beNil())
                                                        //
                                                        //                                                 queueSafeValue.wait.performLast!.set(value: i)
                                                        //                                                 var value2 = queueSafeValue.wait.performLast!.get()
                                                        //                                                 expect(value1).notTo(beNil())
                                                        //
                                                        var string1: String!
                                                        let string2 = queueSafeValue.wait.lowPriority.transform { object -> String in
                                                            string1 = "\(object.value)"
                                                            return "\(object.value)"
                                                        }
                                                        expect(string1) == string2
                                                        
                                                        value1 = nil
                                                        let value2 = queueSafeValue.wait.lowPriority.updated { object in
                                                            value1 = object.value + 1
                                                            object.value += 1
                                                            }?.value
                                                        expect(value1).notTo(beNil())
                                                        expect(value2).notTo(beNil())
                                                        
                                                        value1 = nil
                                                        queueSafeValue.wait.lowPriority.update { value1 = $0.value }
                                                        expect(value1).notTo(beNil())
                                                        
                                                        value1 = nil
                                                        queueSafeValue.wait.lowPriority.perform { value1 = $0.value }
                                                        expect(value1).notTo(beNil())
                }
            }
        }
    }

    func executeAsynchronouslyInsideOneQueue<T>(value: T, result: String, iterations: Int = 10_000,
                                                iterationClosure: @escaping (Int, QueueSafeValue<T>) -> Void) {
        let description = "executed asynchronously inside one queue with wrapped value type \(type(of: value))"
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
        let description = "executed serially inside one queue with wrapped value type \(type(of: value))"
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
