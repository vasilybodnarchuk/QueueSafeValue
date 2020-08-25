//// https://github.com/Quick/Quick
//
//import Quick
//import Nimble
//import QueueSafeValue
//
//class TableOfContentsSpec: QuickSpec {
//    override func spec() {
//        testWaitWhileActions()
//    }
//}
//
//// MARK: Tess sync actions
//
//extension TableOfContentsSpec {
//
//    private func testWaitWhileActions() {
//        describe("Queue Safe Value") {
//            context("test wait actions") {
//                executeSeriallyInsideOneQueue(value: 0,
//                                              result: "expected that basic functionality works") { step, queueSafeValue in
//                                                queueSafeValue.wait.lowPriority.set(value: step)
//                                                var value = queueSafeValue.wait.lowPriority.get()
//                                                expect(value) == .success(step)
//
//                                                let string = queueSafeValue.wait.lowPriority.transform { "\($0)" }
//                                                expect(string) == .success("\(step)")
//
//                                                value = queueSafeValue.wait.lowPriority.update { $0 += 1 }
//                                                expect(value) == .success(step + 1)
//
//                                                queueSafeValue.wait.lowPriority.update { $0 += 1 }
//                                                value = queueSafeValue.wait.lowPriority.get()
//                                                expect(value) == .success(step + 1)
//
//                                                value = nil
//                                                queueSafeValue.wait.lowPriority.perform { value = $0 }
//                                                expect(value) == step + 2
//                }
//
//                executeAsynchronouslyInsideOneQueue(value: 0,
//                                                    result: "not expected to get deadlock") { step, queueSafeValue in
//                                                        var value1 = queueSafeValue.wait.lowPriority.get()
//                                                        expect(value1).notTo(beNil())
//
//                                                        queueSafeValue.wait.lowPriority.set(value: step)
//                                                        var value2 = queueSafeValue.wait.lowPriority.get()
//                                                        expect(value1).notTo(beNil())
//
//                                                        var string1: String!
//                                                        let string2 = queueSafeValue.wait.lowPriority.transform { value -> String in
//                                                            string1 = "\(value)"
//                                                            return "\(value)"
//                                                        }
//                                                        expect(string1) == string2
//
//                                                        value1 = nil
//                                                        value2 = queueSafeValue.wait.lowPriority.updated { value in
//                                                            value1 = value + 1
//                                                            value += 1
//                                                        }
//                                                        expect(value1) == value2
//
//                                                        value1 = nil
//                                                        queueSafeValue.wait.lowPriority.update {
//                                                            $0 += 1
//                                                            value1 = $0
//                                                        }
//                                                        expect(value1).notTo(beNil())
//
//                                                        value1 = nil
//                                                        queueSafeValue.wait.lowPriority.perform { value1 = $0 }
//                                                        expect(value1).notTo(beNil())
//                }
//
//                executeSeriallyInsideOneQueue(value: SimpleClass(),
//                                              result: "expected that basic functionality works") { step, queueSafeValue in
//                                                queueSafeValue.wait.lowPriority.update { $0.value = step }
//                                                expect(queueSafeValue.countObjectReferences()) == 4
//
//                                                var value = queueSafeValue.wait.lowPriority.get()!.value
//                                                expect(value) == step
//                                                expect(queueSafeValue.countObjectReferences()) == 4
//
//                                                let string = queueSafeValue.wait.lowPriority.transform { "\($0.value)" }
//                                                expect(string) == "\(step)"
//                                                expect(queueSafeValue.countObjectReferences()) == 4
//
//                                                var object = queueSafeValue.wait.lowPriority.updated { $0.value += 1 }
//                                                expect(object!.value) == step + 1
//                                                expect(queueSafeValue.countObjectReferences()) == 5
//                                                object = nil
//
//                                                value = step
//                                                queueSafeValue.wait.lowPriority.perform { value = $0.value }
//                                                expect(value) == step + 1
//                                                expect(queueSafeValue.countObjectReferences()) == 4
//                }
//
//                executeAsynchronouslyInsideOneQueue(value: SimpleClass(),
//                                                    result: "not expected to get deadlock") { _, queueSafeValue in
//                                                        var value1 = queueSafeValue.wait.lowPriority.get()?.value
//                                                        expect(value1).notTo(beNil())
//
//                                                        var string1: String!
//                                                        let string2 = queueSafeValue.wait.lowPriority.transform { object -> String in
//                                                            string1 = "\(object.value)"
//                                                            return "\(object.value)"
//                                                        }
//                                                        expect(string1) == string2
//
//                                                        value1 = nil
//                                                        let value2 = queueSafeValue.wait.lowPriority.updated { object in
//                                                            value1 = object.value + 1
//                                                            object.value += 1
//                                                            }?.value
//                                                        expect(value1).notTo(beNil())
//                                                        expect(value2).notTo(beNil())
//
//                                                        value1 = nil
//                                                        queueSafeValue.wait.lowPriority.update { value1 = $0.value }
//                                                        expect(value1).notTo(beNil())
//
//                                                        value1 = nil
//                                                        queueSafeValue.wait.lowPriority.perform { value1 = $0.value }
//                                                        expect(value1).notTo(beNil())
//                }
//            }
//        }
//    }
//
//    func executeAsynchronouslyInsideOneQueue<T>(value: T, result: String, iterations: Int = 10_000,
//                                                iterationClosure: @escaping (Int, QueueSafeValue<T>) -> Void) {
//        let description = "executed asynchronously inside one queue with wrapped value type \(type(of: value))"
//        Test(value: value, description: description,
//             queues: [.global()],
//             iterationsCountPerQueue: iterations) { _ in
//                it(result) { }
//        }.run { iteration, queueSafeValue, _, endTime in
//            iterationClosure(iteration, queueSafeValue)
//            endTime = Date()
//        }
//    }
//
//    func executeSeriallyInsideOneQueue<T>(value: T, result: String, iterations: Int = 10_000,
//                                          iterationClosure: @escaping (Int, QueueSafeValue<T>) -> Void) {
//        let description = "executed serially inside one queue with wrapped value type \(type(of: value))"
//        Test(value: value, description: description,
//             queues: [.global()],
//             iterationsCountPerQueue: 1) { _ in
//                it(result) { }
//        }.run { _, queueSafeValue, _, endTime in
//            for step in 0..<iterations { iterationClosure(step, queueSafeValue) }
//            endTime = Date()
//        }
//    }
//}
