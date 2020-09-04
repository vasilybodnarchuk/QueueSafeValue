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
    private let elementsCount = 10
    override func spec() {
        describe("Command Queue") {
            test()
        }
    }
}


extension CommandQueueSpec {
    
    private func synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: [Int],
                                                                   priority: CommandQueue.Priority) {
        self.testInLoop(expectedArray: expectedArray,
                        syncedIteration: { commandQueue, command in
            commandQueue.append(priority: priority) { command() }
        }, completion: { commandQueue in
            commandQueue.perform()
        })
    }
    
    private func synchronouslyInsertClosureAndExecuteImmediately(expectedArray: [Int],
                                                                 priority: CommandQueue.Priority) {
        self.testInLoop(expectedArray: expectedArray,
                        syncedIteration: { commandQueue, command in
            commandQueue.append(priority: priority) { command() }
            commandQueue.perform()
        })
    }
    
    private func test() {
            context("synchronously") {
                let increasingArray = [Int](0..<self.elementsCount)
                context("insert all closures and execute them after") {
                    it("closures with lowest priority") {
                        self.synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: increasingArray,
                                                                              priority: .lowest)
                    }

                    it("closures with highest priority") {
                        self.synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: (0..<self.elementsCount).reversed(),
                                                                              priority: .highest)
                    }

                }
                
                context("insert closures first and then execute them") {
                    it("closures with lowest priority") {
                        self.synchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                              priority: .lowest)
                    }

                    it("closures with highest priority") {
                        self.synchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                             priority: .highest)
                    }

                }
            }
            
//            context("performs closures immediately") {
//                it("synchronously") {
//                    self.testInLoop(syncedIteration: { commandQueue, command in
//                        commandQueue.performImmediately { command() }
//                    })
//                }
//
//                it("asynchronously") {
//                    self.testInLoop(asyncedIteration: { commandQueue, dispatchGroup, command in
//                        commandQueue.performImmediately { command() }
//                        dispatchGroup.leave()
//                    })
//                }
//            }
//
//            context("asynchronously adds closures to the command queue") {
//                it("executes closures afterwards") {
//                    self.testInLoop(asyncedIteration: { commandQueue, dispatchGroup, command in
//                        commandQueue.append { command() }
//                        dispatchGroup.leave()
//                    }, completion: { commandQueue in
//                        commandQueue.perform()
//                    })
//                }
//
//                it("immediately executes added closures") {
//                    self.testInLoop(asyncedIteration: { commandQueue, dispatchGroup, command in
//                        commandQueue.append {
//                            command()
//                            dispatchGroup.leave()
//                        }
//                        commandQueue.perform()
//                    })
//                }
//            }
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
    
    private func testInLoop(expectedArray: [Int],
                            syncedIteration: @escaping (CommandQueue, _ command: @escaping () -> Void) -> Void,
                            completion: ((CommandQueue) -> Void)? = nil) {
        let commandQueue = CommandQueue()
        var array = [Int]()
        for i in 0..<self.elementsCount {
            syncedIteration(commandQueue) { array.append(i) }
        }
        completion?(commandQueue)
        expect(array) == expectedArray
        expect(array.count) == self.elementsCount
    }
}
