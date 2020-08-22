//
//  LowPrioritySerialActionsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class LowPrioritySerialActionsSpec: QuickSpec {
    
    private let value = 100
    
    override func spec() {
        describe("Low Priority Serial Actions") {
            context("test weak reference") {
                it("get func") {
                    self.testWeakReference(before: {
                        expect($0.get()) == self.value
                    }, after: {
                        expect($0.get()).to(beNil())
                    })
                }
                
                it("set func") {
                    let newValue = self.value + 1
                    self.testWeakReference(before: {
                        $0.set(value: newValue)
                        expect($0.get()) == newValue
                    }, after: {
                        $0.set(value: newValue)
                        expect($0.get()).to(beNil())
                    })
                }
                
                it("update func") {
                    let newValue = self.value + 2
                    self.testWeakReference(before: {
                        $0.update { $0 = newValue }
                        expect($0.get()) == newValue
                    }, after: {
                        var wasExecuted = false
                        $0.update { _ in wasExecuted = true }
                        expect($0.get()).to(beNil())
                        expect(wasExecuted) == false
                    })
                }
                
                it("updated func") {
                    let newValue = self.value + 3
                    self.testWeakReference(before: {
                        let result = $0.updated { $0 = newValue }
                        expect($0.get()) == result
                    }, after: {
                        var wasExecuted = false
                        let result = $0.updated { _ in wasExecuted = true }
                        expect($0.get()).to(beNil())
                        expect(result).to(beNil())
                        expect(wasExecuted) == false
                    })
                }
                
                it("perform func") {
                    self.testWeakReference(before: {
                        var wasExecuted = false
                        $0.perform { _ in wasExecuted = true  }
                        expect($0.get()) == self.value
                        expect(wasExecuted) == true
                    }, after: {
                        var wasExecuted = false
                        $0.perform { _ in wasExecuted = true }
                        expect($0.get()).to(beNil())
                        expect(wasExecuted) == false
                    })
                }
                
                it("transform func") {
                    self.testWeakReference(before: {
                        let result = $0.transform { "\($0)" }
                        expect($0.get()) == self.value
                        expect(result) == "\(self.value)"
                    }, after: {
                        let result = $0.transform { "\($0)" }
                        expect($0.get()).to(beNil())
                        expect(result).to(beNil())
                    })
                }
            }
        }
    }
    
    private func testWeakReference(before: (QueueSafeAction.LowPrioritySerialActions<Int>) -> Void,
                                   after: @escaping (QueueSafeAction.LowPrioritySerialActions<Int>) -> Void) {
        var queueSafeValue: QueueSafeValue<Int>! = .init(value: value)
        let lowPriorityAction = queueSafeValue.wait.lowPriority
        expect(CFGetRetainCount(lowPriorityAction)) == 3
        let closure: () -> Void = {
            expect(CFGetRetainCount(lowPriorityAction)) == 4
            after(lowPriorityAction)
            expect(CFGetRetainCount(lowPriorityAction)) == 4
        }
        before(lowPriorityAction)
        queueSafeValue = nil
        closure()
    }
}
