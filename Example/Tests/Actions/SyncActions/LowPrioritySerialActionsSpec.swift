//
//  LowPrioritySerialActionsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class LowPrioritySerialActionsSpec: QuickSpec, SpecableSyncActions {
    var testedObjectName: String { "Low Priority Serial Actions" }
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> Actions {
        queueSafeValue.wait.lowPriority
    }
    
    override func spec() { runTests() }
}
