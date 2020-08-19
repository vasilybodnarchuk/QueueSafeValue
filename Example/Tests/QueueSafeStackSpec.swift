//
//  QueueSafeStackSpec.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 8/18/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class QueueSafeStackSpec: QuickSpec {
    override func spec() {

        describe("Queue Safe Stack") {

            var stack: QueueSafeStack<Int>!
            beforeEach { stack = .init() }

            it("test isEmpty property") {
                expect(stack.isEmpty) == true
                stack.push(0)
                expect(stack.isEmpty) == false
            }

            it("test peek and push funcs") {
                expect(stack.peek()).to(beNil())
                stack.push(0)
                expect(stack.peek()) == 0
            }

            it("test pop and push funcs") {
                expect(stack.pop()).to(beNil())
                stack.push(0)
                expect(stack.pop()) == 0
                expect(stack.pop()).to(beNil())
            }
        }
    }
}
