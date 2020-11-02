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
            //checkQueueWhereCommandIsRunning()
            testReferenceCounters()
        }
    }
}

extension SpecableAsyncedCommands {
    
    private func testBasicFunctionality() {
        context("test basic functionality") {
            testValueReturningFunctionality()
            testValueSettingFunctionality()
        }
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
