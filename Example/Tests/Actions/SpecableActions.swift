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

extension SpecableActions where Actions: AsyncActionsWithPriority<Value> {
    typealias Completion = () -> Void
    func testWeakReference(before: @escaping (Actions, @escaping Completion) -> Void,
                           after: @escaping (Actions, @escaping Completion) -> Void) {
        var queueSafeValue: QueueSafeValue<Value>! = .init(value: value)
        let lowPriorityAction = actions(from: queueSafeValue)
        expect(CFGetRetainCount(lowPriorityAction)) == 3
        
        let closure: () -> Void = {
            var wasCompleted = false
            print("!!!!! 1 \(wasCompleted)")
            expect(CFGetRetainCount(lowPriorityAction)) == 4
            waitUntil(timeout: 1) { done in
                print("!!!!! 2 \(wasCompleted)")
                after(lowPriorityAction) {
                    usleep(1_000)
                    wasCompleted = true
                    print("!!!!! 3 \(wasCompleted)")
                    done()
                }
                print("!!!!! 4 \(wasCompleted)")
                expect(wasCompleted) == true
            }
            print("!!!!! 5 \(wasCompleted)")
            expect(wasCompleted) == true
            expect(CFGetRetainCount(lowPriorityAction)) == 4
        }
        
        var wasCompleted = false
        waitUntil(timeout: 1) { done in
            before(lowPriorityAction) {
                usleep(1_000)
                wasCompleted = true
                done()
            }
            expect(wasCompleted) == false
        }
        expect(wasCompleted) == true
        queueSafeValue = nil
        closure()
    }
}
