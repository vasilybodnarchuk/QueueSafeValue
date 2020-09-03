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
                               expectedArray: array, expectedFirst: array.min()!)
        
        array = array.reversed()
        testPriorityQueueOrder(priority: .parentsGreaterThanOrEqualChildren,
                               expectedArray: array, expectedFirst: array.max()!)
    }
    
    private func testPriorityQueueOrder(priority: PriorityQueue<Int>.Priority,
                                        expectedArray: [Int], expectedFirst: Int) {
        var priorityQueue = PriorityQueue<Int>(priority: priority)
        context("with priority \(priority)") {
            it("test inserting") {
                expectedArray.forEach { priorityQueue.insert($0) }
                expect(priorityQueue.count) == self.elementsCount
                expect(priorityQueue.peek()!) == expectedFirst
            }
            
            var priorityQueueElements = [Int]()
            it("test removing") {
                (0..<self.elementsCount).forEach { _ in
                    priorityQueueElements.append(priorityQueue.removeElementWithHighestPriority()!)
                }
                
                expect(expectedArray) == priorityQueueElements
                expect(priorityQueue.count) == 0
                expect(priorityQueue.isEmpty) == true
            }
        }
    }
}
