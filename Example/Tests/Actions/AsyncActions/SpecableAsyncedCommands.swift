//
//  SpecableAsyncedCommands.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

protocol SpecableAsyncedCommands: SpecableCommands where Commands == AsyncedCommandsWithPriority<Value>,
                                                         Value == SimpleClass {
    var queueSafeValueDispatchQueue: DispatchQueue { get }
}

extension SpecableAsyncedCommands {
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
 - verifies that `commands` are performed asynchronously
 - checks that the number of references to wrapped `value` ​​does not increase
 */

extension SpecableAsyncedCommands {
    private func testBasicFunctionality() {
        context("test basic functionality") {
            it("get func") {
                self.testWeakReference(before: { commands, dispatchGroup in
                    self.expectResult(.success(self.createDefultInstance()),
                                      commands: commands, dispatchGroup: dispatchGroup)

                }) { commands, dispatchGroup in
                    self.expectResult(.failure(.valueContainerDeinited),
                                       commands: commands, dispatchGroup: dispatchGroup)
                }
            }

            it("set func") {
                let resultInstance = self.createInstance(value: 3)
                self.testWeakReference(before: { commands, dispatchGroup in
                    dispatchGroup.enter()
                    commands.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }
                    self.expectResult(.success(resultInstance),
                                      commands: commands, dispatchGroup: dispatchGroup)

                }) { commands, dispatchGroup in
                    dispatchGroup.enter()
                    commands.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }
                    self.expectResult(.failure(.valueContainerDeinited),
                                      commands: commands, dispatchGroup: dispatchGroup)
                }
            }
            
            it("update func") {
                let newValue = 4
                self.testWeakReference(before: { commands, dispatchGroup in
                    dispatchGroup.enter()
                    let resultInstance = self.createInstance(value: newValue)
                    var valueUpdated = false
                    commands.update(closure: { instance in
                        valueUpdated = true
                        expect(self.createDefultInstance().value) == instance.value
                        instance.value = newValue
                    }) { result in
                        expect(result) == .success(resultInstance)
                        expect(valueUpdated) == true
                        dispatchGroup.leave()
                    }

                    self.expectResult(.success(resultInstance),
                                      commands: commands, dispatchGroup: dispatchGroup)


                }) { commands, dispatchGroup in
                    dispatchGroup.enter()
                    var valueUpdated = false
                    commands.update(closure: { instance in
                        valueUpdated = true
                        instance.value = newValue
                    }) { result in
                        expect(result) == .failure(.valueContainerDeinited)
                        expect(valueUpdated) == false
                        dispatchGroup.leave()
                    }
                    self.expectResult(.failure(.valueContainerDeinited),
                                      commands: commands, dispatchGroup: dispatchGroup)
                }
            }
        }
    }
    
    private func testWeakReference(before: @escaping (Commands, DispatchGroup) -> Void,
                                   after: @escaping (Commands, DispatchGroup) -> Void) {
         let object = createDefultInstance()
         expect(2) == CFGetRetainCount(object)
         var queueSafeValue: QueueSafeValueType! = createQueueSafeValue(value: object)
         expect(3) == CFGetRetainCount(object)
         let lowPriorityCommands = commands(from: queueSafeValue)

         var closure: (() -> Void)? = {
             var wasCompleted = false
             let dispatchGroup = DispatchGroup()
             dispatchGroup.enter()
             waitUntil(timeout: 1) { done in
                 dispatchGroup.notify(queue: .main) {
                     wasCompleted = true
                     done()
                 }
                 after(lowPriorityCommands, dispatchGroup)
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
             before(lowPriorityCommands, dispatchGroup)
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
                              commands: Commands,
                              dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        commands.get { result in
            expect(result) == result
            dispatchGroup.leave()
        }
    }
}

/// Check that `commands` are running on the correct queues.

extension SpecableAsyncedCommands {

    private func checkQueueWhereCommandIsRunning() {
        queueCheckingWhereClosureIsRuning(funcName: "successful set") { commands, done in
            commands.set(newValue: self.createDefultInstance()) { result in
                expect(result) == .success(self.createDefultInstance())
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "failed set", deinitQueueSafeValueBeforeRunClosure: true) { commands, done in
            commands.set(newValue: self.createDefultInstance()) { result in
                expect(result) == .failure(.valueContainerDeinited)
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "successful get") { commands, done in
            commands.get { result in
                expect(result) == .success(self.createDefultInstance())
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "failed get", deinitQueueSafeValueBeforeRunClosure: true) { commands, done in
            commands.get { result in
                expect(result) == .failure(.valueContainerDeinited)
                done()
            }
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "update") { commands, done in
            commands.update(closure: { _ in done() })
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "successful update completion") { commands, done in
            commands.update(closure: { _ in
                
            }, completion: { result in
                expect(result) == .success(self.createDefultInstance())
                done()
            })
        }
        
        queueCheckingWhereClosureIsRuning(funcName: "failed update completion", deinitQueueSafeValueBeforeRunClosure: true) { commands, done in
            commands.update(closure: { _ in
                
            }, completion: { result in
                expect(result) == .failure(.valueContainerDeinited)
                done()
            })
        }
    }
    
    private func queueCheckingWhereClosureIsRuning(funcName: String,
                                                   deinitQueueSafeValueBeforeRunClosure: Bool = false,
                                                   closure: @escaping (Commands, _ done: @escaping () -> Void) -> Void) {
        it("check that closure of \(funcName) function is being executed on the correct queue") {
            var queue1: DispatchQueue!
            let queue2 = self.queueSafeValueDispatchQueue
            while (queue1 == nil) {
                let randomQueue = Queues.random
                if randomQueue != queue2 { queue1 = randomQueue }
            }
            
            expect(queue1) != queue2
            var queueSafeValue: QueueSafeValueType! = self.createQueueSafeValue(value: self.createDefultInstance())
            let commands = self.commands(from: queueSafeValue)
            if deinitQueueSafeValueBeforeRunClosure { queueSafeValue = nil }
            waitUntil(timeout: 1) { done in
                queue1.async {
                    expect(queue1) == DispatchQueue.current
                    closure(commands) {
                        expect(queue2) == DispatchQueue.current
                        done()
                    }
                }
            }
        }
    }
}

