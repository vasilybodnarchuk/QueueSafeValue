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
    typealias Value = SimpleClass
    func createInstance(value: Int) -> SimpleClass { .init(value: value) }
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> LowPrioritySyncActions<Value> {
        queueSafeValue.wait.lowPriority
    }
    
    override func spec() {
        describe("Low Priority Serial Actions") {
            testBasicFunctionality()
        }
    }
}

/**
 Test basic functionality:
 - checks basic functionality, for example: `func set` sets a value,` func get` returns a value ...
 - verifies that `actions` are performed synchronously
 - checks that the number of references to wrapped `value` ​​does not increase
 */

extension LowPrioritySerialActionsSpec {

    private func testBasicFunctionality() {
        context("test basic functionality") {
            it("get func") {
                self.testWeakReference(before: {
                    expect($0.get()) == .success(self.createInstance(value: 0))
                }, after: {
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }

            it("get in closure func") {
                self.testWeakReference(before: {
                    var wasExecuted = false
                    $0.get { _ in wasExecuted = true  }
                    expect($0.get()) == .success(self.createDefultInstance())
                    expect(wasExecuted) == true
                }, after: {
                    var wasExecuted = false
                    $0.get { _ in wasExecuted = true }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(wasExecuted) == true
                })
            }

            it("set func") {
                let newValue = SimpleClass(value: 2)
                self.testWeakReference(before: {
                    $0.set(newValue: newValue)
                    expect($0.get()) == .success(newValue)
                }, after: {
                    $0.set(newValue: newValue)
                    expect($0.get()) == .failure(.valueContainerDeinited)
                })
            }

            it("update func") {
                let newValue = self.createInstance(value: 2)
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

            it("transform func") {
                self.testWeakReference(before: {
                    let result = $0.transform { "\($0)" }
                    expect($0.get()) == .success(self.createDefultInstance())
                    expect(result) == .success("\(self.createDefultInstance())")
                }, after: {
                    let result = $0.transform { "\($0)" }
                    expect($0.get()) == .failure(.valueContainerDeinited)
                    expect(result) == .failure(.valueContainerDeinited)
                })
            }
        }
    }
}
