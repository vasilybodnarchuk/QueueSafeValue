//
//  SpecableSyncActions.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

protocol SpecableSyncActions: SpecableActions where Actions == SyncActionsWithPriority<Value>,
                                                    Value == SimpleClass {
}

extension SpecableSyncActions {
    func runTests() {
        describe(testedObjectName) {
            testBasicFunctionality()
            checkQueueWhereActionIsRunning()
        }
    }
}
    
/**
 Test basic functionality:
 - checks basic functionality, for example: `func set` sets a value,` func get` returns a value ...
 - verifies that `actions` are performed synchronously
 - checks that the number of references to wrapped `value` ​​does not increase
 */
extension SpecableSyncActions {
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
    
    private func testWeakReference(before: (Actions) -> Void,
                           after: @escaping (Actions) -> Void) {
        let object = createDefultInstance()
        expect(2) == CFGetRetainCount(object)
        var queueSafeValue: QueueSafeValue<Value>! = .init(value: object)
        expect(3) == CFGetRetainCount(object)
        let lowPriorityAction = actions(from: queueSafeValue)
        var closure: (() -> Void)? = {
            expect(3) == CFGetRetainCount(object)
            after(lowPriorityAction)
            expect(3) == CFGetRetainCount(object)
        }
        before(lowPriorityAction)
        queueSafeValue = nil
        closure?()
        closure = nil
        expect(2) == CFGetRetainCount(object)
    }
}

/// Check that actions are running on the correct DispatchQueues.

extension SpecableSyncActions {

    private func checkQueueWhereActionIsRunning() {
        queueCheckingWhereClosureIsRuning(funcName: "get with completion") { actions, done in
            actions.get { _ in done() }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "update") { actions, done in
            actions.update { result in done() }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "transform") { actions, done in
            _ = actions.transform { value -> Value in
                done()
                return value
            }
        }
    }
    
    private func queueCheckingWhereClosureIsRuning(funcName: String,
                                           closure: @escaping (Actions, _ done: @escaping () -> Void) -> Void) {
        it("check that closure of \(funcName) function is being executed on the correct queue") {
            let queue = Queues.random
            let queueSafeValue = QueueSafeValue(value: self.createDefultInstance())
            let actions = self.actions(from: queueSafeValue)
            waitUntil(timeout: 1) { done in
                queue.async {
                    expect(DispatchQueue.current) == queue
                    closure(actions) {
                        expect(DispatchQueue.current) == queue
                        done()
                    }
                }
            }
        }
    }
}
