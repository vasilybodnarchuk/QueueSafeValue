//
//  SpecableActions.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Nimble
import QueueSafeValue

protocol SpecableActions: class {
    associatedtype Value: AnyObject
    associatedtype Actions: AnyObject
    func createInstance(value: Int) -> Value
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> Actions
}


extension SpecableActions {
    func createDefultInstance() -> Value { createInstance(value: 0) }
}

extension SpecableActions where Actions: SyncActionsWithPriority<Value> {
    func testWeakReference(before: (Actions) -> Void,
                           after: @escaping (Actions) -> Void) {
        let object = createDefultInstance()
        expect(2) == CFGetRetainCount(object)
        var queueSafeValue: QueueSafeValue<Value>! = .init(value: object)
        expect(3) == CFGetRetainCount(object)
        let lowPriorityAction = actions(from: queueSafeValue)
        var closure: (() -> Void)? = {
            expect(3) == CFGetRetainCount(object)
            after(lowPriorityAction)
            expect(3) == CFGetRetainCount(object)
        }
        before(lowPriorityAction)
        queueSafeValue = nil
        closure?()
        closure = nil
        expect(2) == CFGetRetainCount(object)
    }
}

extension SpecableActions where Actions: AsyncActionsWithPriority<Value> {
    func testWeakReference(before: @escaping (Actions, DispatchGroup) -> Void,
                           after: @escaping (Actions, DispatchGroup) -> Void) {
        let object = createDefultInstance()
        expect(2) == CFGetRetainCount(object)
        var queueSafeValue: QueueSafeValue<Value>! = .init(value: object)
        expect(3) == CFGetRetainCount(object)
        let lowPriorityAction = actions(from: queueSafeValue)

        var closure: (() -> Void)? = {
            var wasCompleted = false
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            waitUntil(timeout: 1) { done in
                dispatchGroup.notify(queue: .main) {
                    wasCompleted = true
                    done()
                }
                after(lowPriorityAction, dispatchGroup)
                dispatchGroup.leave()
                expect(wasCompleted) == false
            }
            dispatchGroup.wait()
            expect(wasCompleted) == true
        }

        var wasCompleted = false
        waitUntil(timeout: 1) { done in
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            dispatchGroup.notify(queue: .main) {
                wasCompleted = true
                done()
            }
            before(lowPriorityAction, dispatchGroup)
            dispatchGroup.leave()
            expect(wasCompleted) == false
        }
        expect(wasCompleted) == true
        queueSafeValue = nil
        closure?()
        closure = nil
        expect(2) == CFGetRetainCount(object)
    }
}

