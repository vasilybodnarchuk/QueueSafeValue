//
//  LowPriorityAsyncActionsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class LowPriorityAsyncActionsSpec: QuickSpec, SpecableActions {
    typealias Value = SimpleClass
    func createInstance(value: Int) -> SimpleClass { .init(value: value) }
   
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> LowPriorityAsyncActions<Value> {
        queueSafeValue.async(performIn: .default).lowPriority
    }
    
//    func actions(from queueSafeValue: QueueSafeValue<Value>) -> LowPriorityAsyncActions<Value> {
//        queueSafeValue.async(performIn: .default).lowPriority
//    }
    
    override func spec() {
        describe("Low Priority Async Actions") {
            testBasicFunctionality()
            checkQueueWhereActionIsRunning()
        }
    }
    
    private func delay() { usleep(10_000) }
}


/**
 Test basic functionality:
 - checks basic functionality, for example: `func set` sets a value,` func get` returns a value ...
 - verifies that `actions` are performed asynchronously
 - checks that the number of references to wrapped `value` ​​does not increase
 */

extension LowPriorityAsyncActionsSpec {
    private func testBasicFunctionality() {
        context("test basic functionality") {
            it("get func") {
                self.testWeakReference(before: { action, dispatchGroup in
                    self.expectResult(.success(self.createDefultInstance()),
                                      action: action, dispatchGroup: dispatchGroup)

                }) { action, dispatchGroup in
                    self.expectResult(.failure(.valueContainerDeinited),
                                       action: action, dispatchGroup: dispatchGroup)
                }
            }

            it("set func") {
                let resultInstance = self.createInstance(value: 3)
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }
                    self.expectResult(.success(resultInstance),
                                      action: action, dispatchGroup: dispatchGroup)

                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }
                    self.expectResult(.failure(.valueContainerDeinited),
                                      action: action, dispatchGroup: dispatchGroup)
                }
            }
            
            it("update func") {
                let newValue = 4
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    let resultInstance = self.createInstance(value: newValue)
                    var valueUpdated = false
                    action.update(closure: { instance in
                        valueUpdated = true
                        expect(self.createDefultInstance().value) == instance.value
                        instance.value = newValue
                    }) { result in
                        expect(result) == .success(resultInstance)
                        expect(valueUpdated) == true
                        dispatchGroup.leave()
                    }

                    self.expectResult(.success(resultInstance),
                                      action: action, dispatchGroup: dispatchGroup)


                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    var valueUpdated = false
                    action.update(closure: { instance in
                        valueUpdated = true
                        instance.value = newValue
                    }) { result in
                        expect(result) == .failure(.valueContainerDeinited)
                        expect(valueUpdated) == false
                        dispatchGroup.leave()
                    }
                    self.expectResult(.failure(.valueContainerDeinited),
                                      action: action, dispatchGroup: dispatchGroup)
                }
            }
        }
    }
    
    private func expectResult(_ result: Result<LowPriorityAsyncActionsSpec.Value, QueueSafeValueError>,
                              action: LowPriorityAsyncActions<LowPriorityAsyncActionsSpec.Value>,
                              dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        action.get { result in
            expect(result) == result
            dispatchGroup.leave()
        }
    }
}

/// Check that asynchronous actions are running on the correct queues.

extension LowPriorityAsyncActionsSpec {

    func checkQueueWhereActionIsRunning() {
        testActionIsRunningOnCorrectQueue(funcName: "set") { actions, done in
            actions.set(newValue: self.createDefultInstance()) { _ in done() }
        }
        
        testActionIsRunningOnCorrectQueue(funcName: "get") { actions, done in
            actions.get { _ in done() }
        }
        
        testActionIsRunningOnCorrectQueue(funcName: "update") { actions, done in
            actions.update(closure: { _ in done() })
        }
        
        testActionIsRunningOnCorrectQueue(funcName: "update completion") { actions, done in
            actions.update(closure: { _ in
                
            }, completion: { result in
                expect(result) == .success(self.createDefultInstance())
                done()
            })
        }
        
        testActionIsRunningOnCorrectQueue(funcName: "update failed completion", deinitQueueSafeValueBeforeRunClosure: true) { actions, done in
            actions.update(closure: { _ in
                
            }, completion: { result in
                expect(result) == .failure(.valueContainerDeinited)
                done()
            })
        }
    }
    
    private func testActionIsRunningOnCorrectQueue(funcName: String,
                                                   deinitQueueSafeValueBeforeRunClosure: Bool = false,
                                                   closure: @escaping (LowPriorityAsyncActions<Value>, _ done: @escaping () -> Void) -> Void) {
        it("checks \(funcName) function is being executed on the correct queue") {
            let queues = Queues.getUniqueRandomQueues(count: 2)
            expect(queues[0]) != queues[1]
            var queueSafeValue: QueueSafeValue! = QueueSafeValue(value: self.createDefultInstance())
            let actions = queueSafeValue.async(performIn: queues[1]).lowPriority
            if deinitQueueSafeValueBeforeRunClosure { queueSafeValue = nil }
            waitUntil(timeout: 1) { done in
                queues[0].async {
                    expect(DispatchQueue.current) == queues[0]
                    closure(actions) {
                        expect(DispatchQueue.current) == queues[1]
                        done()
                    }
                }
            }
        }
    }
}
