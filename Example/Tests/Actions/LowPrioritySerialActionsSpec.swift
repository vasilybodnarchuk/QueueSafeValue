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

class LowPrioritySerialActionsSpec: QuickSpec, SpecableActions {
    typealias Value = Int
    var value = 100
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> LowPrioritySyncActions<Value> {
        queueSafeValue.wait.lowPriority
    }
    
    override func spec() {
        describe("Low Priority Serial Actions") {
            testWeakReferenceAndCoreFunctionality()
        }
    }
}

// MARK: Test weak reference and core functionality

extension LowPrioritySerialActionsSpec {

    private func testWeakReferenceAndCoreFunctionality() {
        context("test weak reference and core functionality") {
            it("get func") {
                self.testWeakReference(before: {
                    expect($0.get()) == .success(self.value)
                }, after: {
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }
            
            it("set func") {
                let newValue = self.value + 1
                self.testWeakReference(before: {
                    $0.set(value: newValue)
                    expect($0.get()) == .success(newValue)
                }, after: {
                    $0.set(value: newValue)
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }

            it("update func") {
                let newValue = self.value + 2
                self.testWeakReference(before: {
                    $0.update { $0 = newValue }
                    expect($0.get()) == .success(newValue)
                }, after: {
                    var wasExecuted = false
                    $0.update { _ in wasExecuted = true }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(wasExecuted) == false
                })
            }

            it("perform func") {
                self.testWeakReference(before: {
                    var wasExecuted = false
                    $0.perform { _ in wasExecuted = true  }
                    expect($0.get()) == .success(self.value)
                    expect(wasExecuted) == true
                }, after: {
                    var wasExecuted = false
                    $0.perform { _ in wasExecuted = true }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(wasExecuted) == true
                })
            }

            it("transform func") {
                self.testWeakReference(before: {
                    let result = $0.transform { "\($0)" }
                    expect($0.get()) == .success(self.value)
                    expect(result) == .success("\(self.value)")
                }, after: {
                    let result = $0.transform { "\($0)" }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(result) == .failure(.valueContainerDeinited)
                })
            }
        }
    }
}
