//
//  PriorityQueueSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/2/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class PriorityQueueSpec: QuickSpec {
    private let elementsCount = 10
    override func spec() {
        describe("Priority Queue") {
            testPriorityQueueOrder()
        }
    }
}

extension PriorityQueueSpec {
    private func testPriorityQueueOrder() {
        var array = (0..<elementsCount).map { $0 }
        testPriorityQueueOrder(priority: .parentsLessThanOrEqualChildren,
                               expectedArray: array,
                               expectedFirst: array[0],
                               expectedLast: array[elementsCount-1])
        
        array = array.reversed()
        testPriorityQueueOrder(priority: .parentsGreaterThanOrEqualChildren,
                               expectedArray: array,
                               expectedFirst: array[0],
                               expectedLast: array[elementsCount-1])
    }
    
    private func testPriorityQueueOrder(priority: PriorityQueue<Int>.Priority,
                                        expectedArray: [Int],
                                        expectedFirst: Int,
                                        expectedLast: Int) {
        var priorityQueue1 = PriorityQueue<Int>(priority: priority)
        var priorityQueue2 = PriorityQueue<Int>(priority: priority)
        expect(priorityQueue1.count) == 0
        expect(priorityQueue1.isEmpty) == true
        
        context("with priority \(priority)") {
            it("test inserting") {
                expectedArray.forEach {
                    priorityQueue1.insert($0)
                    priorityQueue2.insert($0)
                }
                expect(priorityQueue1.count) == self.elementsCount
                expect(priorityQueue1.peek()!) == expectedFirst
                expect(priorityQueue1.elements.last) == expectedLast
            }
            
            it("test removeElementWithHighestPriority") {
                var priorityQueueElements = [Int]()
                (0..<expectedArray.count).forEach { _ in
                    priorityQueueElements.append(priorityQueue1.removeElementWithHighestPriority()!)
                }
                print(priorityQueueElements)
                expect(expectedArray) == priorityQueueElements
                expect(priorityQueue1.count) == 0
                expect(priorityQueue1.isEmpty) == true
            }
            
            it("test removeElementWithLowestPriority") {
                var priorityQueueElements = [Int]()
                (0..<expectedArray.count).forEach { _ in
                    priorityQueueElements.insert(priorityQueue2.removeElementWithLowestPriority()!, at: 0)
                }
                expect(expectedArray) == priorityQueueElements
                expect(priorityQueue1.count) == 0
                expect(priorityQueue1.isEmpty) == true
            }
        }
    }
}
