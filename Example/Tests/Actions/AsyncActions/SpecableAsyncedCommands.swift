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
           // testBasicFunctionality()
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
            testValueReturningFunctionality()
            testValueSettingFunctionality()
//            it("get command inside closure with auto completion") {
//                self.testWeakReference(before: { commands, dispatchGroup in
//                    self.expectResult(.success(self.createDefultInstance()),
//                                      commands: commands, dispatchGroup: dispatchGroup)
//
//                }) { commands, dispatchGroup in
//                    self.expectResult(.failure(.valueContainerDeinited),
//                                       commands: commands, dispatchGroup: dispatchGroup)
//                }
//            }
//
//            it("get command inside closure with manual completion") {
//                self.testWeakReference(before: { commands, dispatchGroup in
//                    dispatchGroup.enter()
////                    commands.get { (result, done) in
////                        result
//////                    }
////                    self.expectResult(.success(resultInstance),
////                                      commands: commands, dispatchGroup: dispatchGroup)
//
//                }) { commands, dispatchGroup in
//
//                }
//            }
//
//            it("set func") {
//                let resultInstance = self.createInstance(value: 3)
//                self.testWeakReference(before: { commands, dispatchGroup in
//                    dispatchGroup.enter()
//                    commands.set(newValue: resultInstance) { _ in
//                        dispatchGroup.leave()
//                    }
//                    self.expectResult(.success(resultInstance),
//                                      commands: commands, dispatchGroup: dispatchGroup)
//
//                }) { commands, dispatchGroup in
//                    dispatchGroup.enter()
//                    commands.set(newValue: resultInstance) { _ in
//                        dispatchGroup.leave()
//                    }
//                    self.expectResult(.failure(.valueContainerDeinited),
//                                      commands: commands, dispatchGroup: dispatchGroup)
//                }
//            }
//
//            it("update func") {
//                let newValue = 4
//                self.testWeakReference(before: { commands, dispatchGroup in
//                    dispatchGroup.enter()
//                    let resultInstance = self.createInstance(value: newValue)
//                    var valueUpdated = false
//                    commands.set(accessClosure: { instance in
//                        valueUpdated = true
//                        expect(self.createDefultInstance().value) == instance.value
//                        instance.value = newValue
//                    }) { result in
//                        expect(result) == .success(resultInstance)
//                        expect(valueUpdated) == true
//                        dispatchGroup.leave()
//                    }
//
//                    self.expectResult(.success(resultInstance),
//                                      commands: commands, dispatchGroup: dispatchGroup)
//
//
//                }) { commands, dispatchGroup in
//                    dispatchGroup.enter()
//                    var valueUpdated = false
//                    commands.set(accessClosure: { instance in
//                        valueUpdated = true
//                        instance.value = newValue
//                    }) { result in
//                        expect(result) == .failure(.valueContainerDeinited)
//                        expect(valueUpdated) == false
//                        dispatchGroup.leave()
//                    }
//                    self.expectResult(.failure(.valueContainerDeinited),
//                                      commands: commands, dispatchGroup: dispatchGroup)
//                }
//            }
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

// MARK: Check that command completions are running on the correct DispatchQueues.

extension SpecableAsyncedCommands {

    private func checkQueueWhereCommandIsRunning() {
        let expectedValue = createDefultInstance()
        var queueSafeValue: QueueSafeValueType!
        var commands: Commands!
        beforeEach {
            queueSafeValue = self.createQueueSafeValue(value: expectedValue)
            commands = self.commands(from: queueSafeValue)
        }

        describe("get funcs") {
            describe("with auto-completion") {
                it("successful result") {
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.get { _ in done() }
                    }
                }
                it("valueContainerDeinited error") {
                    queueSafeValue = nil
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.get { _ in done() }
                    }
                }
            }
            
            describe("with manual completion") {
                it("successful result") {
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.get { (_, finishCommand) in
                            finishCommand()
                            done()
                        }
                    }
                }
                it("valueContainerDeinited error") {
                    queueSafeValue = nil
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.get { (_, finishCommand) in
                            finishCommand()
                            done()
                        }
                    }
                }
            }
        }
        describe("set funcs") {
            let newValue = self.createInstance(value: (0...100_000).randomElement() ?? 1)
            describe("with auto-completion") {
                it("successful result") {
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set(newValue: newValue) { _ in done() }
                    }
                    
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set { _ in done() }
                    }
                    
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set { _ in } completion: { _ in done() }
                    }
                }

                it("valueContainerDeinited error") {
                    queueSafeValue = nil
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set(newValue: newValue) { _ in done() }
                    }
                }
                
                it("valueContainerDeinited error 2") {
                    queueSafeValue = nil
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set { _ in } completion: { _ in done() }
                    }
                }
            }
            
            describe("with manual completion") {
                it("successful result") {
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set { (_, finishCommand) in
                            finishCommand()
                            done()
                        }
                    }
                    
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set { (_, finishCommand) in
                            finishCommand()
                        } completion: { _ in
                            done()
                        }
                    }
                }
                it("valueContainerDeinited error") {
                    queueSafeValue = nil
                    self.runCommandInOneQueueAndFinishInAnother { done in
                        commands.set { (_, finishCommand) in
                            finishCommand()
                        } completion: { _ in
                            done()
                        }
                    }
                }
            }
        }
    }
    
    private func runCommandInOneQueueAndFinishInAnother(closure: @escaping (@escaping () -> Void) -> Void) {
        var queue1: DispatchQueue!
        let queue2 = self.queueSafeValueDispatchQueue
        while (queue1 == nil) {
            let randomQueue = Queues.random
            if randomQueue != queue2 { queue1 = randomQueue }
        }
        
        expect(queue1) != queue2
        var visitedQueue1: Bool!
        var visitedQueue2: Bool!
        waitUntil(timeout: 1) { done in
            queue1.async {
                expect(queue1) == DispatchQueue.current
                visitedQueue1 = true
                closure {
                    expect(queue2) == DispatchQueue.current
                    visitedQueue2 = true
                    done()
                }
            }
        }
        expect(visitedQueue1) == true
        expect(visitedQueue2) == true
    }
}

// MARK: Checking the value getting functionality (make sure get funcs return correct values)

extension SpecableAsyncedCommands {

    private func expected(_ result: Result<SimpleClass, QueueSafeValueError>,
                          from commands: Commands) {
        waitUntil(timeout: 1) { done in
            commands.get { _result in
                expect(_result) == result
                done()
            }
        }
    }

    private func testValueReturningFunctionality() {
        describe("get funcs") {
            let expectedValue = createDefultInstance()
            var queueSafeValue: QueueSafeValueType!
            var commands: Commands!
            beforeEach {
                queueSafeValue = self.createQueueSafeValue(value: expectedValue)
                commands = self.commands(from: queueSafeValue)
            }

            context("with auto-completion") {
                it("successful result") {
                    self.expected(.success(expectedValue), from: commands)
                }
                
                it("valueContainerDeinited error") {
                    self.expected(.success(expectedValue), from: commands)
                    queueSafeValue = nil
                    self.expected(.failure(.valueContainerDeinited), from: commands)
                }
            }
            
            context("with manual completion") {
                it("successful result") {
                    waitUntil(timeout: 1) { done in
                        commands.get { result, finishCommand in
                            expect(result) == .success(expectedValue)
                            finishCommand()
                            done()
                        }
                    }
                }
                
                it("valueContainerDeinited error") {
                    self.expected(.success(expectedValue), from: commands)
                    queueSafeValue = nil
                    waitUntil(timeout: 1) { done in
                        commands.get { result, finishCommand in
                            expect(result) == .failure(.valueContainerDeinited)
                            finishCommand()
                            done()
                        }
                    }
                }
            }
        }
    }
}

// MARK: Checking the value setting functionality (make sure set funcs update values)

extension SpecableAsyncedCommands {
    
    private func testValueSettingFunctionality() {
        describe("set funcs") {
            let oldValue = createDefultInstance()
            let newValue = self.createInstance(value: (0...100_000).randomElement() ?? 1)
            var queueSafeValue: QueueSafeValueType!
            var commands: Commands!
            beforeEach {
                queueSafeValue = self.createQueueSafeValue(value: oldValue)
                commands = self.commands(from: queueSafeValue)
                self.expected(.success(oldValue), from: commands)
            }
            
            context("without callback") {
                it("successful result") {
                    commands.set(newValue: newValue)
                    self.expected(.success(newValue), from: commands)
                }
                
                it("valueContainerDeinited error") {
                    queueSafeValue = nil
                    commands.set(newValue: newValue)
                    self.expected(.failure(.valueContainerDeinited), from: commands)
                }
            }
            
            context("with auto-completion") {
                it("successful result") {
                    waitUntil(timeout: 1) { done in
                        commands.set(newValue: newValue) { result in
                            expect(result) == .success(newValue)
                            done()
                        }
                    }
                    self.expected(.success(newValue), from: commands)
                }
                
                it("valueContainerDeinited error") {
                    queueSafeValue = nil
                    waitUntil(timeout: 1) { done in
                        commands.set(newValue: newValue) { result in
                            expect(result) == .failure(.valueContainerDeinited)
                            done()
                        }
                    }
                    self.expected(.failure(.valueContainerDeinited), from: commands)
                }
            }
            
            context("with manual completion") {
                it("successful result") {
                    var visitedAccessClosure: Bool!
                    waitUntil(timeout: 2) { done in
                        commands.set { (currentValue, finishCommand) in
                            currentValue = newValue
                            visitedAccessClosure = true
                            finishCommand()
                        } completion: { result in
                            expect(result) == .success(newValue)
                            expect(visitedAccessClosure) == true
                            done()
                        }
                    }
                    expect(visitedAccessClosure) == true
                    self.expected(.success(newValue), from: commands)
                }
                
                it("valueContainerDeinited error") {
                    queueSafeValue = nil
                    var visitedAccessClosure: Bool!
                    waitUntil(timeout: 1) { done in
                        commands.set { (currentValue, finishCommand) in
                            currentValue = newValue
                            visitedAccessClosure = true
                            finishCommand()
                        } completion: { result in
                            expect(result) == .failure(.valueContainerDeinited)
                            expect(visitedAccessClosure).to(beNil())
                            done()
                        }
                    }
                    expect(visitedAccessClosure).to(beNil())
                    self.expected(.failure(.valueContainerDeinited), from: commands)
                }
            }
        }
    }
}
