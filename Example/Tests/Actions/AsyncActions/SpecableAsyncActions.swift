//
//  SpecableAsyncActions.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

protocol SpecableAsyncActions: SpecableActions where Actions == AsyncedCommandsWithPriority<Value>,
                                                     Value == SimpleClass  {
}

extension SpecableAsyncActions {
    func runTests() {
        describe(testedObjectName) {
            testBasicFunctionality()
            checkQueueWhereActionIsRunning()
        }
    }

    func actions(from queueSafeValue: QueueSafeValue<Value>, queue: DispatchQueue) -> Actions {
        queueSafeValue.async(performIn: queue).lowPriority
    }
}

/**
 Test basic functionality:
 - checks basic functionality, for example: `func set` sets a value,` func get` returns a value ...
 - verifies that `actions` are performed asynchronously
 - checks that the number of references to wrapped `value` ​​does not increase
 */

extension SpecableAsyncActions {
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
    
    private func testWeakReference(before: @escaping (Actions, DispatchGroup) -> Void,
                                   after: @escaping (Actions, DispatchGroup) -> Void) {
         let object = createDefultInstance()
         expect(2) == CFGetRetainCount(object)
         var queueSafeValue: QueueSafeValue<Value>! = .init(value: object)
         expect(3) == CFGetRetainCount(object)
         let lowPriorityAction = actions(from: queueSafeValue)

         var closure: (() -> Void)? = {
             var wasCompleted = false
             let dispatchGroup = DispatchGroup()
             dispatchGroup.enter()
             waitUntil(timeout: 1) { done in
                 dispatchGroup.notify(queue: .main) {
                     wasCompleted = true
                     done()
                 }
                 after(lowPriorityAction, dispatchGroup)
                 dispatchGroup.leave()
                 expect(wasCompleted) == false
             }
             dispatchGroup.wait()
             expect(wasCompleted) == true
         }

         var wasCompleted = false
         waitUntil(timeout: 1) { done in
             let dispatchGroup = DispatchGroup()
             dispatchGroup.enter()
             dispatchGroup.notify(queue: .main) {
                 wasCompleted = true
                 done()
             }
             before(lowPriorityAction, dispatchGroup)
             dispatchGroup.leave()
             expect(wasCompleted) == false
         }
         expect(wasCompleted) == true
         queueSafeValue = nil
         closure?()
         closure = nil
         expect(2) == CFGetRetainCount(object)
     }
    
    private func expectResult(_ result: Result<Value, QueueSafeValueError>,
                              action: Actions,
                              dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        action.get { result in
            expect(result) == result
            dispatchGroup.leave()
        }
    }
}

/// Check that actions are running on the correct queues.

extension SpecableAsyncActions {

    private func checkQueueWhereActionIsRunning() {
        queueCheckingWhereClosureIsRuning(funcName: "successful set") { actions, done in
            actions.set(newValue: self.createDefultInstance()) { result in
                expect(result) == .success(self.createDefultInstance())
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "failed set", deinitQueueSafeValueBeforeRunClosure: true) { actions, done in
            actions.set(newValue: self.createDefultInstance()) { result in
                expect(result) == .failure(.valueContainerDeinited)
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "successful get") { actions, done in
            actions.get { result in
                expect(result) == .success(self.createDefultInstance())
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "failed get", deinitQueueSafeValueBeforeRunClosure: true) { actions, done in
            actions.get { result in
                expect(result) == .failure(.valueContainerDeinited)
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "update") { actions, done in
            actions.update(closure: { _ in done() })
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "successful update completion") { actions, done in
            actions.update(closure: { _ in
                
            }, completion: { result in
                expect(result) == .success(self.createDefultInstance())
                done()
            })
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "failed update completion", deinitQueueSafeValueBeforeRunClosure: true) { actions, done in
            actions.update(closure: { _ in
                
            }, completion: { result in
                expect(result) == .failure(.valueContainerDeinited)
                done()
            })
        }
    }
    
    private func queueCheckingWhereClosureIsRuning(funcName: String,
                                                   deinitQueueSafeValueBeforeRunClosure: Bool = false,
                                                   closure: @escaping (Actions, _ done: @escaping () -> Void) -> Void) {
        it("check that closure of \(funcName) function is being executed on the correct queue") {
            let queues = Queues.getUniqueRandomQueues(count: 2)
            expect(queues[0]) != queues[1]
            var queueSafeValue: QueueSafeValue! = QueueSafeValue(value: self.createDefultInstance())
            let actions = self.actions(from: queueSafeValue, queue: queues[1])
            if deinitQueueSafeValueBeforeRunClosure { queueSafeValue = nil }
            waitUntil(timeout: 1) { done in
                queues[0].async {
                    expect(DispatchQueue.current) == queues[0]
                    closure(actions) {
                        let queue = DispatchQueue.current
                        expect(queue) == queues[1]
                        done()
                    }
                }
            }
        }
    }
}

