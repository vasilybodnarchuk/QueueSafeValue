//
//  CommandQueueSpec.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class CommandQueueSpec: QuickSpec {
    private let elementsCount = 10_000
    override func spec() {
        describe("Command Queue") {
            context("synchronously adds closures to the command queue") {
                it("executes closures afterwards in the correct order") {
                    self.testInLoop(syncedIteration: { commandQueue, command in
                        commandQueue.append { command() }
                    }, completion: { commandQueue in
                        commandQueue.perform()
                    })
                }
                
                
                it("immediately executes the added closure in the correct order") {
                    self.testInLoop(syncedIteration: { commandQueue, command in
                        commandQueue.append { command() }
                        commandQueue.perform()
                    })
                }
            }
            
            context("performs closures immediately") {
                it("synchronously") {
                    self.testInLoop(syncedIteration: { commandQueue, command in
                        commandQueue.performImmediately { command() }
                    })
                }
                
                it("asynchronously") {
                    self.testInLoop(asyncedIteration: { commandQueue, dispatchGroup, command in
                        commandQueue.performImmediately { command() }
                        dispatchGroup.leave()
                    })
                }
            }
            
            context("asynchronously adds closures to the command queue") {
                it("executes closures afterwards") {
                    self.testInLoop(asyncedIteration: { commandQueue, dispatchGroup, command in
                        commandQueue.append { command() }
                        dispatchGroup.leave()
                    }, completion: { commandQueue in
                        commandQueue.perform()
                    })
                }

                it("immediately executes added closures") {
                    self.testInLoop(asyncedIteration: { commandQueue, dispatchGroup, command in
                        commandQueue.append {
                            command()
                            dispatchGroup.leave()
                        }
                        commandQueue.perform()
                    })
                }
            }
        }
    }
    
    private func testInLoop(asyncedIteration: @escaping (CommandQueue, DispatchGroup, _ command: @escaping () -> Void) -> Void,
                            completion: ((CommandQueue) -> Void)? = nil) {
        let commandQueue = CommandQueue()
        waitUntil(timeout: 1) { done in
            var array1 = [Int]()
            var array2 = [Int]()
            let dispatchGroup = DispatchGroup()

            for i in 0..<self.elementsCount {
                array1.append(i)
                dispatchGroup.enter()
                Queues.random.async {
                    asyncedIteration(commandQueue, dispatchGroup) { array2.append(i) }
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion?(commandQueue)
                expect(array1) != array2
                expect(array1) == array2.sorted()
                expect(array2.count) == self.elementsCount
                done()
            }
            dispatchGroup.wait()
        }
    }
    
    private func testInLoop(syncedIteration: @escaping (CommandQueue, _ command: @escaping () -> Void) -> Void,
                            completion: ((CommandQueue) -> Void)? = nil) {
        let commandQueue = CommandQueue()
        var array1 = [Int]()
        var array2 = [Int]()
        for i in 0..<self.elementsCount {
            array1.append(i)
            syncedIteration(commandQueue) { array2.append(i) }
        }
        completion?(commandQueue)
        expect(array1) == array2
        expect(array1.count) == self.elementsCount
    }
}
