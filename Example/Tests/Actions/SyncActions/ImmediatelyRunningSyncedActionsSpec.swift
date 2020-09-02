//
//  ImmediatelyRunningSyncedActionsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class ImmediatelyRunningSyncedActionsSpec: QuickSpec, SpecableSyncActions {
    var testedObjectName: String { "Immediately Running Sync Actions" }
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> Actions {
        queueSafeValue.wait.now
    }
    
    override func spec() { runTests() }
}
