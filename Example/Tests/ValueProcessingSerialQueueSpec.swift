//
//  ValueProcessingSerialQueueSpec.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class ValueProcessingSerialQueueSpec: QuickSpec {
    override func spec() {
        
        describe("Value Processing Serial Queue") {
            
            var serialQueue: ValueProcessingSerialQueue!
            beforeEach { serialQueue = ValueProcessingSerialQueue() }
            
            it("expects append") {
                print(serialQueue)
                var array1 = [Int]()
                var array2 = [Int]()
                for _ in 0..<10 {
                    array1.append(array1.count)
                    serialQueue.append { array2.append(array2.count) }
                }
                serialQueue.perform()
                expect(array1) == array2
            }
        }
    }
}

