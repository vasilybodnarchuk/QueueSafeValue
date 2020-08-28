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
            var serialQueue: CommandQueue!
            beforeEach { serialQueue = CommandQueue() }

            it("first waits for all closures to be added and then executes them in the correct order") {
                var array1 = [Int]()
                var array2 = [Int]()
                for _ in 0..<10_000 {
                    array1.append(array1.count)
                    serialQueue.append { array2.append(array2.count) }
                }
                serialQueue.perform()
                expect(array1) == array2
            }

            it("adds closures to the queue and immediately executes them in the correct order") {
                var array1 = [Int]()
                var array2 = [Int]()
                for _ in 0..<10_000 {
                    array1.append(array1.count)
                    serialQueue.append { array2.append(array2.count) }
                    serialQueue.perform()
                }
                expect(array1) == array2
            }
        }
    }
}