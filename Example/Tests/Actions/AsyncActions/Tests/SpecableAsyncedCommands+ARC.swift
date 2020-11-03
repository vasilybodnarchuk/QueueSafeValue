//
//  SpecableAsyncedCommands+ARC.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 10/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

// MARK: Make sure the closures of the commands don't retain objects.

extension SpecableAsyncedCommands {

    func testReferenceCounters() {
        describe("ARC") {
            var object: Value!
            var queueSafeValue: QueueSafeValueType!
            var commands: Commands!
            beforeEach {
                object = self.createDefultInstance()
                expect(2) == CFGetRetainCount(object)
                queueSafeValue = self.createQueueSafeValue(value: object)
                expect(3) == CFGetRetainCount(object)
                commands = self.commands(from: queueSafeValue)
                expect(3) == CFGetRetainCount(object)
            }

            // MARK: Get funcs

            describe("get funcs") {
                afterEach {
                    let expectedReferenceCount = queueSafeValue == nil ? 2 : 3
                    expect(expectedReferenceCount) == CFGetRetainCount(object)
                }
                describe("with auto-completion") {
                    it("successful result") {
                        waitUntil(timeout: 1) { done in
                            commands.get { result in
                                self.expectEqualReferencesToTheSameObject(reference1: try? result.get(),
                                                                          reference2: object,
                                                                          expectedReferenceCount: 6)
                                done()
                            }
                        }
                    }
                    
                    it("valueContainerDeinited error") {
                        queueSafeValue = nil
                        let expectedRetainCount = 2
                        expect(expectedRetainCount) == CFGetRetainCount(object)
                        waitUntil(timeout: 1) { done in
                            commands.get { result in
                                expect(expectedRetainCount) == CFGetRetainCount(object)
                                done()
                            }
                        }
                    }
                }
                
                describe("with manual completion") {
                    it("successful result") {
                        waitUntil(timeout: 1) { done in
                            commands.get { result, finishCommand in
                                self.expectEqualReferencesToTheSameObject(reference1: try? result.get(),
                                                                          reference2: object,
                                                                          expectedReferenceCount: 6)
                                finishCommand()
                                done()
                            }
                        }
                    }

                    it("valueContainerDeinited error") {
                        queueSafeValue = nil
                        let expectedRetainCount = 2
                        expect(expectedRetainCount) == CFGetRetainCount(object)
                        waitUntil(timeout: 1) { done in
                            commands.get { result, finishCommand in
                                expect(expectedRetainCount) == CFGetRetainCount(object)
                                finishCommand()
                                done()
                            }
                        }
                    }
                }
            }
            
            // MARK: Set funcs

            describe("set funcs") {
                var newObject: Value!
                beforeEach {
                    newObject = self.createInstance(value: (0...100_000).randomElement() ?? 1)
                    expect(2) == CFGetRetainCount(newObject)
                }
                
                afterEach {
                    let expectedReferenceCount = queueSafeValue == nil ? 2 : 3
                    expect(expectedReferenceCount) == CFGetRetainCount(newObject)
                    expect(2) == CFGetRetainCount(object)
                }
  
                describe("with auto-completion") {
                    describe("one line setting") {
                        it("successful result") {
                            waitUntil(timeout: 1) { done in
                                commands.set(newValue: newObject) { result in
                                    self.expectEqualReferencesToTheSameObject(reference1: try? result.get(),
                                                                              reference2: newObject,
                                                                              expectedReferenceCount: 7)
                                    done()
                                }
                            }
                        }
                        
                        it("valueContainerDeinited error") {
                            queueSafeValue = nil
                            let expectedRetainCount = 2
                            expect(expectedRetainCount) == CFGetRetainCount(object)
                            waitUntil(timeout: 1) { done in
                                commands.set(newValue: newObject) { result in
                                    expect(expectedRetainCount) == CFGetRetainCount(object)
                                    done()
                                }
                            }
                        }
                    }
                    describe("multiline setting") {
                        it("successful result") {
                            waitUntil(timeout: 1) { done in
                                commands.set { currentValue in
                                    currentValue = newObject
                                    self.expectEqualReferencesToTheSameObject(reference1: currentValue,
                                                                              reference2: newObject,
                                                                              expectedReferenceCount: 4)
                                    done()
                                }
                            }
                        }
                        
                        it("successful result 2") {
                            waitUntil(timeout: 1) { done in
                                commands.set { curentValue in
                                    curentValue = newObject
                                    expect(3) == CFGetRetainCount(curentValue)
                                } completion: { result in
                                    self.expectEqualReferencesToTheSameObject(reference1: try? result.get(),
                                                                              reference2: newObject,
                                                                              expectedReferenceCount: 6)
                                    done()
                                }
                            }
                        }
                        
                        it("valueContainerDeinited error") {
                            queueSafeValue = nil
                            let expectedRetainCount = 2
                            expect(expectedRetainCount) == CFGetRetainCount(object)
                            waitUntil(timeout: 1) { done in
                                commands.set { currentValue in
                                    // MARK: Will not be executed in any error
                                    currentValue = newObject
                                } completion: { result in
                                    expect(expectedRetainCount) == CFGetRetainCount(object)
                                    expect(expectedRetainCount) == CFGetRetainCount(newObject)
                                    done()
                                }
                            }
                        }
                    }
                }
                
                describe("with manual completion") {
                    it("successful result") {
                        waitUntil(timeout: 1) { done in
                            commands.set { (currentValue, finishCommand) in
                                currentValue = newObject
                                self.expectEqualReferencesToTheSameObject(reference1: currentValue,
                                                                          reference2: newObject,
                                                                          expectedReferenceCount: 4)
                                finishCommand()
                                done()
                            }
                        }
                    }
                    
                    it("successful result") {
                        waitUntil(timeout: 1) { done in
                            commands.set { (currentValue, finishCommand) in
                                currentValue = newObject
                                self.expectEqualReferencesToTheSameObject(reference1: currentValue,
                                                                          reference2: newObject,
                                                                          expectedReferenceCount: 4)
                                finishCommand()
                            } completion: { result in
                                expect(2) == CFGetRetainCount(object)
                                self.expectEqualReferencesToTheSameObject(reference1: try? result.get(),
                                                                          reference2: newObject,
                                                                          expectedReferenceCount: 6)
                                done()
                            }
                        }
                    }
                    
                    it("valueContainerDeinited error") {
                        queueSafeValue = nil
                        let expectedRetainCount = 2
                        expect(expectedRetainCount) == CFGetRetainCount(object)
                        waitUntil(timeout: 1) { done in
                            commands.set { (currentValue, finishCommand) in
                                // MARK: Will not be executed in any error
                                currentValue = newObject
                            } completion: { (result) in
                                expect(expectedRetainCount) == CFGetRetainCount(object)
                                expect(expectedRetainCount) == CFGetRetainCount(newObject)
                                done()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: Helpers

extension SpecableAsyncedCommands {
    private func expectEqualReferencesToTheSameObject(reference1: AnyObject?,
                                                      reference2: AnyObject?,
                                                      expectedReferenceCount: Int) {
        let counter1 = CFGetRetainCount(reference1)
        let counter2 = CFGetRetainCount(reference2)
        expect(counter1) == counter2
        expect(Int(counter1)) == expectedReferenceCount
        expect(reference1) === reference2
    }
}
