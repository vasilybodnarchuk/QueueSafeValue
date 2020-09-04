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

            it("get in closure func") {
                self.testWeakReference(before: {
                    var wasExecuted = false
                    $0.get { _ in wasExecuted = true  }
                    expect($0.get()) == .success(self.createDefultInstance())
                    expect(wasExecuted) == true
                }, after: {
                    var wasExecuted = false
                    $0.get { _ in wasExecuted = true }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(wasExecuted) == true
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
    
    private func testWeakReference(before: (Commands) -> Void,
                                   after: @escaping (Commands) -> Void) {
        let object = createDefultInstance()
        expect(2) == CFGetRetainCount(object)
        var queueSafeValue: QueueSafeValue<Value>! = .init(value: object)
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
        it("check that closure of \(funcName) function is being executed on the correct queue") {
            let queue = Queues.random
            let queueSafeValue = QueueSafeValue(value: self.createDefultInstance())
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
