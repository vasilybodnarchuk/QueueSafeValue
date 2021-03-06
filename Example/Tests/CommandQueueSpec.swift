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
    override func spec() {
        let expectedElementsCounts = [0,1,2,1_000]
        describe("Command Queue") {
            testOfSynchronousInsertingAndPerforming(expectedElementsCounts: expectedElementsCounts)
            testOfAsynchronousInsertingAndPerforming(expectedElementsCounts: expectedElementsCounts)
        }
    }
}

extension CommandQueueSpec {
    private func createExpectedArray(count: Int, priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) -> [Int] {
        var array = [Int]()
        for i in 0..<count {
            switch priorityForElement(i) {
            case .highest: array.insert(i, at: 0)
            case .lowest: array.append(i)
            }
        }
        return array
    }
}

// MARK: Test Of synchronous commands inserting and performing
extension CommandQueueSpec {
    
    private func testInLoop(expectedArray: [Int],
                            syncedIteration: @escaping (_ step: Int, CommandQueue, _ command: @escaping () -> Void) -> Void,
                            completion: ((CommandQueue) -> Void)? = nil) {
        let commandQueue = CommandQueue()
        var array = [Int]()
        for i in 0..<expectedArray.count {
            syncedIteration(i, commandQueue) { array.append(i) }
        }
        completion?(commandQueue)
        expect(array) == expectedArray
    }
    
    
    private func synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: [Int],
                                                                   priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) {
        self.testInLoop(expectedArray: expectedArray,
                        syncedIteration: { index, commandQueue, command in
            commandQueue.append(priority: priorityForElement(index)) { command() }
        }, completion: { commandQueue in
            commandQueue.perform()
        })
    }
    
    private func synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteThemAfter(expectedElementsCount: Int,
                                                                                       priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) {
        let array = createExpectedArray(count: expectedElementsCount,
                                        priorityForElement: priorityForElement)
        synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: array,
                                                          priorityForElement: priorityForElement)
    }
        
    private func synchronouslyInsertClosureAndExecuteImmediately(expectedArray: [Int],
                                                                 priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) {
        self.testInLoop(expectedArray: expectedArray,
                        syncedIteration: { index, commandQueue, command in
            commandQueue.append(priority: priorityForElement(index)) { command() }
            commandQueue.perform()
        })
    }

    private func synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteImmediately(expectedArray: [Int],
                                                                                         priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) {
        synchronouslyInsertClosureAndExecuteImmediately(expectedArray: expectedArray, priorityForElement: priorityForElement)
    }

    
    private func testOfSynchronousInsertingAndPerforming(expectedElementsCounts: [Int]) {
        expectedElementsCounts.forEach { count in
            context("synchronously insert \(count) commands") {
                let increasingArray = [Int](0..<count)
                context("execute them all together after inserting") {
                    it("commands with lowest priority") {
                        self.synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: increasingArray,
                                                                               priorityForElement: { _ in .lowest })
                    }
                    
                    it("commands with highest priority") {
                        self.synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: (0..<count).reversed(),
                                                                               priorityForElement: {  _ in .highest })
                    }
                    
                    context("commands with mixed priorities") {
                        it("first half with the highest the rest with the lowest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteThemAfter(expectedElementsCount: count,
                                                                                                       priorityForElement: { index in
                                                                                                        return index < count/2 ? .highest : .lowest
                            })
                        }
                        
                        it("first half with the lowest the rest with the highest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteThemAfter(expectedElementsCount: count,
                                                                                                       priorityForElement: { index in
                                                                                                        return index < count/2 ? .lowest : .highest
                            })
                        }
                        
                        it("every first element with the lowest the rest with the highest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteThemAfter(expectedElementsCount: count,
                                                                                                       priorityForElement: { index in
                                                                                                        return index%2 == 0 ? .lowest : .highest
                            })
                        }
                        
                        it("every first element with the highest the rest with the lowest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteThemAfter(expectedElementsCount: count,
                                                                                                       priorityForElement: { index in
                                                                                                        return index%2 == 0 ? .highest : .lowest
                            })
                        }
                    }
                }
                
                context("and immediately execute each during inserting") {
                    it("commands with lowest priority") {
                        self.synchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                             priorityForElement: { _ in .lowest })
                    }
    
                    it("commands with highest priority") {
                        self.synchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                             priorityForElement: { _ in .highest })
                    }
                    
                    context("commands with mixed priorities") {
                        it("first half with the highest the rest with the lowest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteImmediately(expectedArray: increasingArray,
                                                                                                         priorityForElement: { index in
                                                                                                            return index < count/2 ? .highest : .lowest
                            })
                        }
                        
                        it("first half with the lowest the rest with the highest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteImmediately(expectedArray: increasingArray,
                                                                                                         priorityForElement: { index in
                                                                                                            return index < count/2 ? .lowest : .highest
                            })
                        }
                        
                        it("every first element with the lowest the rest with the highest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteImmediately(expectedArray: increasingArray,
                                                                                                         priorityForElement: { index in
                                                                                                            return index%2 == 0 ? .lowest : .highest
                            })
                        }
                        
                        it("every first element with the highest the rest with the lowest") {
                            self.synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteImmediately(expectedArray: increasingArray,
                                                                                                         priorityForElement: { index in
                                                                                                            return index%2 == 0 ? .highest : .lowest
                            })
                        }
                    }
                }
            }
        }
    }
}

// MARK: Test Of asynchronous commands inserting and performing
extension CommandQueueSpec {
    private func testOfAsynchronousInsertingAndPerforming(expectedElementsCounts: [Int]) {

        expectedElementsCounts.forEach { count in
            context("asynchronously insert \(count) commands") {
                context("execute them all together after inserting") {
                    it("commands with lowest priority") {
                        self.asynchronouslyInsertAllClosuresAndExecuteThemAfter(expectedElementsCount: count,
                                                                                priorityForElement: { _ in .lowest })
                    }
                    
                    it("commands with highest priority") {
                        self.asynchronouslyInsertAllClosuresAndExecuteThemAfter(expectedElementsCount: count,
                                                                               priorityForElement: {  _ in .highest })
                    }
                }
                
                context("and immediately execute each during inserting") {
                    let increasingArray = [Int](0..<count)
                    it("commands with lowest priority") {
                        self.asynchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                             priorityForElement: { _ in .lowest })
                    }
    
                    it("commands with highest priority") {
                        self.asynchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                             priorityForElement: { _ in .highest })
                    }
                }
            }
        }
    }
    
    private func asynchronouslyInsertClosureAndExecuteImmediately(expectedArray: [Int],
                                                                  priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) {
        self.testInLoop(expectedArray: expectedArray,
                        asyncedIteration: { index, commandQueue, dispatchGroup, command in
            commandQueue.append(priority: priorityForElement(index)) { command() }
            commandQueue.perform()
            dispatchGroup.leave()
        }, completion: { commandQueue in
        })
    }
    
    private func asynchronouslyInsertAllClosuresAndExecuteThemAfter(expectedElementsCount: Int,
                                                                    priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) {
        let array = (0..<expectedElementsCount).map { $0 }
        self.testInLoop(expectedArray: array,
                        asyncedIteration: { index, commandQueue, dispatchGroup, command in
            commandQueue.append(priority: priorityForElement(index)) { command() }
            dispatchGroup.leave()
        }, completion: { commandQueue in
            commandQueue.perform()
        })
    }
    
    private func testInLoop(expectedArray: [Int],
                            asyncedIteration: @escaping (_ step: Int, CommandQueue, DispatchGroup, _ command: @escaping () -> Void) -> Void,
                            completion: ((CommandQueue) -> Void)? = nil) {
        let commandQueue = CommandQueue()
        waitUntil(timeout: .seconds(10)) { done in
            var array = [Int]()
            array.reserveCapacity(expectedArray.count)
            let dispatchGroup = DispatchGroup()

            for i in 0..<expectedArray.count {
                dispatchGroup.enter()
                Queues.random.async {
                    asyncedIteration(i, commandQueue, dispatchGroup) { array.append(i) }
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion?(commandQueue)
                expect(expectedArray) == array.sorted()
                done()
            }
            dispatchGroup.wait()
        }
    }
}
