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
        describe("Command Queue") {
            testOfSynchronousInsertingAndPerforming(expectedElementsCounts: [0,1,2,5,100])
        }
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

    private func synchronouslyInsertClosuresWithDifferentPrioritiesAndExecuteImmediately(expectedElementsCount: Int,
                                                                                         priorityForElement: @escaping (_ index: Int) -> CommandQueue.Priority) {
        let array = createExpectedArray(count: expectedElementsCount,
                                        priorityForElement: priorityForElement)
        synchronouslyInsertClosureAndExecuteImmediately(expectedArray: array, priorityForElement: priorityForElement)
    }

    
    private func testOfSynchronousInsertingAndPerforming(expectedElementsCounts: [Int]) {
        expectedElementsCounts.forEach { count in
            context("synchronously insert \(count) closures") {
                let increasingArray = [Int](0..<count)
                context("insert all closures first and execute them after") {
                    it("closures with lowest priority") {
                        self.synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: increasingArray,
                                                                               priorityForElement: { _ in .lowest })
                    }
                    
                    it("closures with highest priority") {
                        self.synchronouslyInsertAllClosuresAndExecuteThemAfter(expectedArray: (0..<count).reversed(),
                                                                               priorityForElement: {  _ in .highest })
                    }
                    
                    context("with mixed priorities") {
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
                
                context("immediately execute closures during inserting") {
                    it("closures with lowest priority") {
                        self.synchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                             priorityForElement: { _ in .lowest })
                    }
    
                    it("closures with highest priority") {
                        self.synchronouslyInsertClosureAndExecuteImmediately(expectedArray: increasingArray,
                                                                             priorityForElement: { _ in .highest })
                    }
                }
            }
        }
    }
}

// MARK: Test Of asynchronous commands inserting and performing
extension CommandQueueSpec {
    private func test() {

            
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
    
    
//    private func testInLoop(asyncedIteration: @escaping (CommandQueue, DispatchGroup, _ command: @escaping () -> Void) -> Void,
//                            completion: ((CommandQueue) -> Void)? = nil) {
//        let commandQueue = CommandQueue()
//        waitUntil(timeout: 1) { done in
//            var array1 = [Int]()
//            var array2 = [Int]()
//            let dispatchGroup = DispatchGroup()
//
//            for i in 0..<self.elementsCount {
//                array1.append(i)
//                dispatchGroup.enter()
//                Queues.random.async {
//                    asyncedIteration(commandQueue, dispatchGroup) { array2.append(i) }
//                }
//            }
//            dispatchGroup.notify(queue: .main) {
//                completion?(commandQueue)
//                expect(array1) != array2
//                expect(array1) == array2.sorted()
//                expect(array2.count) == self.elementsCount
//                done()
//            }
//            dispatchGroup.wait()
//        }
//    }
}
