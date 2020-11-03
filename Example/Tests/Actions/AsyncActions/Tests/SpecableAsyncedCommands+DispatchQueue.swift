//
//  SpecableAsyncedCommands+DispatchQueue.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 10/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

// MARK: Check that command completions are running on the correct DispatchQueues.

extension SpecableAsyncedCommands {

    func checkQueueWhereCommandIsRunning() {
        let expectedValue = createDefultInstance()
        var queueSafeValue: QueueSafeValueType!
        var commands: Commands!

        beforeEach {
            queueSafeValue = self.createQueueSafeValue(value: expectedValue)
            commands = self.commands(from: queueSafeValue)
        }

        // MARK: get funcs

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

        // MARK: set funcs

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
}

// MARK: Helpers

extension SpecableAsyncedCommands {
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
        waitUntil(timeout: .seconds(1)) { done in
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
