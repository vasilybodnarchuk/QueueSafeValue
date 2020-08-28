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
    typealias Value = SimpleClass
    func createInstance(value: Int) -> SimpleClass { .init(value: value) }
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> LowPriorityAsyncActions<Value> {
        queueSafeValue.async(performIn: .default).lowPriority
    }

    override func spec() {
        describe("Low Priority Async Actions") {
            testWeakReferenceAndCoreFunctionality()
        }
    }
    
    private func delay() { usleep(10_000) }
}

// MARK: Test weak reference and core functionality

extension LowPriorityAsyncActionsSpec {
    private func testWeakReferenceAndCoreFunctionality() {
        context("test weak reference and core functionality") {

            it("get func") {
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.get { instance in
                        expect(instance) == .success(self.createDefultInstance())
                        dispatchGroup.leave()
                    }

                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.get { instance in
                        expect(instance) == .failure(.valueContainerDeinited)
                        dispatchGroup.leave()
                    }
                }
            }

            it("set func") {
                let resultInstance = self.createInstance(value: 3)
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    dispatchGroup.enter()
                    action.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }

                    action.get { instance in
                        expect(instance) == .success(resultInstance)
                        dispatchGroup.leave()
                    }

                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    dispatchGroup.enter()
                    action.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }
                    action.get { instance in
                        expect(instance) == .failure(.valueContainerDeinited)
                        dispatchGroup.leave()
                    }
                }
            }
            
            it("update func") {
                let newValue = 4
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    dispatchGroup.enter()
                    let resultInstance = self.createInstance(value: newValue)
                    var valueUpdated = false
                    action.update(closure: { instance in
                        valueUpdated = true
                        instance.value = newValue
                    }) { result in
                        expect(result) == .success(resultInstance)
                        expect(valueUpdated) == true
                        dispatchGroup.leave()
                    }

                    action.get { instance in
                        expect(instance) == .success(resultInstance)
                        dispatchGroup.leave()
                    }

                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    dispatchGroup.enter()
                    var valueUpdated = false
                    action.update(closure: { instance in
                        valueUpdated = true
                        instance.value = newValue
                    }) { result in
                        expect(result) == .failure(.valueContainerDeinited)
                        expect(valueUpdated) == false
                        dispatchGroup.leave()
                    }
                    action.get { instance in
                        expect(instance) == .failure(.valueContainerDeinited)
                        dispatchGroup.leave()
                    }
                }
            }
        }
    }
}
