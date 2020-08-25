//
//  LowPriorityAsyncActionsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class LowPriorityAsyncActionsSpec: QuickSpec, SpecableActions {
    typealias Value = Int
    var value = 100
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> LowPriorityAsyncActions<Value> {
        queueSafeValue.async(performIn: .default).lowPriority
    }

    override func spec() {
        describe("Low Priority Async Actions") {
            //testWeakReferenceAndCoreFunctionality()
        }
    }
}

// MARK: Test weak reference and core functionality
//
extension LowPriorityAsyncActionsSpec {
//    private func testWeakReferenceAndCoreFunctionality() {
//        context("test weak reference and core functionality") {
//            it("get func") {
//                self.testWeakReference(before: { action, done in
//                    print("!!!!!!!!!!! 1")
//
//                    action.get { value in
//                        print("!!!!!!!!!!! 2")
//                        expect(value) == self.value
//                        done()
//                    }
//                }) { action, done in
//                    print("!!!!!!!!!!! 3")
//                    action.get { value in
//                        print("!!!!!!!!!!! 4")
//                        expect(value).to(beNil())
//                        done()
//                    }
//                }
//            }
//
//            it("set func") {
//                let newValue = self.value + 1
//                self.testWeakReference(before: {
//                    $0.set(value: newValue)
//                    expect($0.get()) == newValue
//                }, after: {
//                    $0.set(value: newValue)
//                    expect($0.get()).to(beNil())
//                })
//            }
//
//            it("update func") {
//                let newValue = self.value + 2
//                self.testWeakReference(before: {
//                    $0.update { $0 = newValue }
//                    expect($0.get()) == newValue
//                }, after: {
//                    var wasExecuted = false
//                    $0.update { _ in wasExecuted = true }
//                    expect($0.get()).to(beNil())
//                    expect(wasExecuted) == false
//                })
//            }
//
//            it("updated func") {
//                let newValue = self.value + 3
//                self.testWeakReference(before: {
//                    let result = $0.updated { $0 = newValue }
//                    expect($0.get()) == result
//                }, after: {
//                    var wasExecuted = false
//                    let result = $0.updated { _ in wasExecuted = true }
//                    expect($0.get()).to(beNil())
//                    expect(result).to(beNil())
//                    expect(wasExecuted) == false
//                })
//            }
//
//            it("perform func") {
//                self.testWeakReference(before: {
//                    var wasExecuted = false
//                    $0.perform { _ in wasExecuted = true  }
//                    expect($0.get()) == self.value
//                    expect(wasExecuted) == true
//                }, after: {
//                    var wasExecuted = false
//                    $0.perform { _ in wasExecuted = true }
//                    expect($0.get()).to(beNil())
//                    expect(wasExecuted) == false
//                })
//            }
//
//            it("transform func") {
//                self.testWeakReference(before: {
//                    let result = $0.transform { "\($0)" }
//                    expect($0.get()) == self.value
//                    expect(result) == "\(self.value)"
//                }, after: {
//                    let result = $0.transform { "\($0)" }
//                    expect($0.get()).to(beNil())
//                    expect(result).to(beNil())
//                })
//            }
//        }
//    }
}
