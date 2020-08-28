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
    associatedtype Value
    associatedtype Actions: AnyObject
    var value: Value { get }
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> Actions
}

extension SpecableActions where Actions: SyncActionsWithPriority<Value> {
    func testWeakReference(before: (Actions) -> Void,
                           after: @escaping (Actions) -> Void) {
        var queueSafeValue: QueueSafeValue<Value>! = .init(value: value)
        let lowPriorityAction = actions(from: queueSafeValue)
        defer { expect(CFGetRetainCount(lowPriorityAction)) == 3 }
        expect(CFGetRetainCount(lowPriorityAction)) == 3
        let closure: () -> Void = {
            expect(CFGetRetainCount(lowPriorityAction)) == 4
            after(lowPriorityAction)
            expect(CFGetRetainCount(lowPriorityAction)) == 4
        }
        before(lowPriorityAction)
        expect(CFGetRetainCount(lowPriorityAction)) == 4
        queueSafeValue = nil
        closure()
    }
}

extension SpecableActions where Actions: AsyncActionsWithPriority<Value> {
    func testWeakReference(before: @escaping (Actions, DispatchGroup) -> Void,
                           after: @escaping (Actions, DispatchGroup) -> Void) {
        var queueSafeValue: QueueSafeValue<Value>! = .init(value: value)
        let lowPriorityAction = actions(from: queueSafeValue)
        expect(CFGetRetainCount(lowPriorityAction)) == 3
        
        let completionDispatchGroup = DispatchGroup()
        completionDispatchGroup.enter()
        completionDispatchGroup.enter()
        completionDispatchGroup.notify(queue: .main) { expect(CFGetRetainCount(lowPriorityAction)) == 3 }
        
        let closure: () -> Void = {
            var wasCompleted = false
            waitUntil(timeout: 10) { done in
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                dispatchGroup.notify(queue: .main) {
                    wasCompleted = true
                    done()
                }
                after(lowPriorityAction, dispatchGroup)
                dispatchGroup.leave()
                expect(wasCompleted) == false
            }
            expect(wasCompleted) == true
            expect(CFGetRetainCount(lowPriorityAction)) == 5
            completionDispatchGroup.leave()
        }
        
        var wasCompleted = false
        waitUntil(timeout: 10) { done in
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
        expect(CFGetRetainCount(lowPriorityAction)) == 5
        queueSafeValue = nil
        completionDispatchGroup.leave()

        closure()
        completionDispatchGroup.wait()
    }
}
