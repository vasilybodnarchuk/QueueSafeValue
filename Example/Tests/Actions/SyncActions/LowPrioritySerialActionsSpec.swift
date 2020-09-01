//
//  LowPrioritySerialActionsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class LowPrioritySerialActionsSpec: QuickSpec, SpecableSerialActions {
    typealias Value = SimpleClass
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> LowPrioritySyncActions<Value> {
        queueSafeValue.wait.lowPriority
    }
    
    override func spec() { runTests() }
}
