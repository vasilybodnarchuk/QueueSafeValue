//
//  SpecableSyncedCommands.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

protocol SpecableSyncedCommands: SpecableCommands where Commands == SyncedCommandsWithPriority<Value>,
                                                        Value == SimpleClass {
}

extension SpecableSyncedCommands {
    func runTests() {
        describe(testedObjectName) {
            testBasicFunctionality()
            checkQueueWhereCommandIsRunning()
        }
    }
}
    
/**
 Test basic functionality:
 - checks basic functionality, for example: `func set` sets a value,` func get` returns a value ...
 - verifies that `commands` are performed synchronously
 - checks that the number of references to wrapped `value` ​​does not increase
 */
extension SpecableSyncedCommands {
    private func testBasicFunctionality() {
        context("test basic functionality") {
            it("get func") {
                self.testWeakReference(before: {
                    expect($0.get()) == .success(self.createInstance(value: 0))
                }, after: {
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }

            it("get func with closure with auto completion") {
                self.testWeakReference(before: {
                    var funcWasExecuted: Bool!
                    $0.get { _ in
                        usleep(500_000)
                        funcWasExecuted = true
                    }
                    expect(funcWasExecuted) == true
                    expect($0.get()) == .success(self.createDefultInstance())
                }, after: {
                    var funcWasExecuted: Bool!
                    $0.get { _ in
                        usleep(500_000)
                        funcWasExecuted = true
                    }
                    expect(funcWasExecuted) == true
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }
            
            it("get func with closure with manual completion") {
                self.testWeakReference(before: {
                    var funcWasExecuted: Bool!
                    $0.get { (_, done) in
                        usleep(500_000)
                        funcWasExecuted = true
                        done()
                    }
                    expect(funcWasExecuted) == true
                    expect($0.get()) == .success(self.createDefultInstance())
                }, after: {
                    var funcWasExecuted: Bool!
                    $0.get { (_, done) in
                        usleep(500_000)
                        funcWasExecuted = true
                        done()
                    }
                    expect(funcWasExecuted) == true
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }

            it("set func") {
                let newValue = SimpleClass(value: 2)
                self.testWeakReference(before: {
                    $0.set(newValue: newValue)
                    expect($0.get()) == .success(newValue)
                }, after: {
                    $0.set(newValue: newValue)
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }

            it("update func") {
                let newValue = self.createInstance(value: 2)
                self.testWeakReference(before: {
                    $0.update { $0 = newValue }
                    expect($0.get()) == .success(newValue)
                }, after: {
                    var wasExecuted = false
                    $0.update { _ in wasExecuted = true }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(wasExecuted) == false
                })
            }

            it("transform func") {
                self.testWeakReference(before: {
                    let result = $0.transform { "\($0)" }
                    expect($0.get()) == .success(self.createDefultInstance())
                    expect(result) == .success("\(self.createDefultInstance())")
                }, after: {
                    let result = $0.transform { "\($0)" }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(result) == .failure(.valueContainerDeinited)
                })
            }
        }
    }
    
    private func expectExecutionTime(timestamp1: Date, timestamp2: Date, expectedTimeRange: ClosedRange<Double>) {
        let timeDifference = timestamp2.timeIntervalSince1970 - timestamp1.timeIntervalSince1970
        expect(expectedTimeRange ~= timeDifference) == true
    }
    
    private func testWeakReference(before: (Commands) -> Void,
                                   after: @escaping (Commands) -> Void) {
        let object = createDefultInstance()
        expect(2) == CFGetRetainCount(object)
        var queueSafeValue: QueueSafeValueType! = createQueueSafeValue(value: object)
        expect(3) == CFGetRetainCount(object)
        let lowPriorityCommand = commands(from: queueSafeValue)
        var closure: (() -> Void)? = {
            expect(3) == CFGetRetainCount(object)
            after(lowPriorityCommand)
            expect(3) == CFGetRetainCount(object)
        }
        before(lowPriorityCommand)
        queueSafeValue = nil
        closure?()
        closure = nil
        expect(2) == CFGetRetainCount(object)
    }
}

/// Check that `commands` are running on the correct DispatchQueues.

extension SpecableSyncedCommands {

    private func checkQueueWhereCommandIsRunning() {
        queueCheckingWhereClosureIsRuning(funcName: "get with completion") { commands, done in
            commands.get { _ in done() }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "update") { commands, done in
            commands.update { result in done() }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "transform") { commands, done in
            _ = commands.transform { value -> Value in
                done()
                return value
            }
        }
    }
    
    private func queueCheckingWhereClosureIsRuning(funcName: String,
                                                   closure: @escaping (Commands, _ done: @escaping () -> Void) -> Void) {
        let queueSafeValue = createQueueSafeValue(value: createDefultInstance())
        it("check that closure of \(funcName) function is being executed on the correct queue") {
            let queue = Queues.random
            let commands = self.commands(from: queueSafeValue)
            waitUntil(timeout: 1) { done in
                queue.async {
                    expect(DispatchQueue.current) == queue
                    closure(commands) {
                        expect(DispatchQueue.current) == queue
                        done()
                    }
                }
            }
        }
    }
}
