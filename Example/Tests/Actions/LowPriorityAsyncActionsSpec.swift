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
                    action.get { value in
                        self.delay()
                        expect(value) == .success(self.value)
                        dispatchGroup.leave()
                    }

                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    action.get { value in
                        self.delay()
                        expect(value) == .failure(.valueContainerDeinited)
                        dispatchGroup.leave()
                    }
                }
            }
            
            it("set func") {
                let newValue = self.value + 1
                var countPerformedClosures = 0
                self.testWeakReference(before: { action, dispatchGroup in
                    dispatchGroup.enter()
                    dispatchGroup.enter()
                    expect(countPerformedClosures) == 0
                    action.set(newValue: newValue) { _ in
                        self.delay()
                        expect(countPerformedClosures) == 0
                        countPerformedClosures += 1
                        dispatchGroup.leave()
                    }
                    expect(countPerformedClosures) == 0
                    
                    action.get { value in
                        self.delay()
                        expect(value) == .success(newValue)
                        expect(countPerformedClosures) == 1
                        countPerformedClosures += 1
                        dispatchGroup.leave()
                    }
                    expect(countPerformedClosures) == 0
                    
                }) { action, dispatchGroup in
                    dispatchGroup.enter()
                    dispatchGroup.enter()
                    expect(countPerformedClosures) == 2
                    action.set(newValue: newValue) { _ in
                        self.delay()
                        expect(countPerformedClosures) == 2
                        countPerformedClosures += 1
                        dispatchGroup.leave()
                    }
                    expect(countPerformedClosures) == 2
                    action.get { value in
                        self.delay()
                        expect(value) == .failure(.valueContainerDeinited)
                        expect(countPerformedClosures) == 3
                        dispatchGroup.leave()
                    }
                    expect(countPerformedClosures) == 2
                }
            }
        }
    }
}
