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

class LowPriorityAsyncActionsSpec: QuickSpec, SpecableAsyncActions {   
    var testedObjectName: String { "Low Priority Async Actions" }
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> Actions {
        actions(from: queueSafeValue, queue: .global(qos: .default))
    }

    override func spec() { runTests() }
}
