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
                    self.expectResult(.success(self.createDefultInstance()),
                                      action: action, dispatchGroup: dispatchGroup)

                }) { action, dispatchGroup in
                    self.expectResult(.failure(.valueContainerDeinited),
                                       action: action, dispatchGroup: dispatchGroup)
                }
            }

            it("set func") {
                let resultInstance = self.createInstance(value: 3)
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }
                    self.expectResult(.success(resultInstance),
                                      action: action, dispatchGroup: dispatchGroup)

                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.set(newValue: resultInstance) { _ in
                        dispatchGroup.leave()
                    }
                    self.expectResult(.failure(.valueContainerDeinited),
                                      action: action, dispatchGroup: dispatchGroup)
                }
            }
            
            it("update func") {
                let newValue = 4
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    let resultInstance = self.createInstance(value: newValue)
                    var valueUpdated = false
                    action.update(closure: { instance in
                        valueUpdated = true
                        expect(self.createDefultInstance().value) == instance.value
                        instance.value = newValue
                    }) { result in
                        expect(result) == .success(resultInstance)
                        expect(valueUpdated) == true
                        dispatchGroup.leave()
                    }

                    self.expectResult(.success(resultInstance),
                                      action: action, dispatchGroup: dispatchGroup)


                }) { action, dispatchGroup in
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
                    self.expectResult(.failure(.valueContainerDeinited),
                                      action: action, dispatchGroup: dispatchGroup)
                }
            }
            
            it("perform func") {
                let resultInstance = self.createDefultInstance()
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.perform(closure: { result in
                        dispatchGroup.leave()
                        expect(result) == .success(resultInstance)
                    })
                    self.expectResult(.success(resultInstance),
                                      action: action, dispatchGroup: dispatchGroup)

                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.perform { result in
                        dispatchGroup.leave()
                        expect(result) == .failure(.valueContainerDeinited)
                    }
                    self.expectResult(.failure(.valueContainerDeinited),
                                      action: action, dispatchGroup: dispatchGroup)
                }
            }
        }
    }
    
    private func expectResult(_ result: Result<LowPriorityAsyncActionsSpec.Value, QueueSafeValueError>,
                              action: LowPriorityAsyncActions<LowPriorityAsyncActionsSpec.Value>,
                              dispatchGroup: DispatchGroup) {
        dispatchGroup.enter()
        action.get { result in
            expect(result) == result
            dispatchGroup.leave()
        }
    }
}
