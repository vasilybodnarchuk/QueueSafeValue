//
//  LowPrioritySyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class LowPrioritySyncedCommandsSpec: QuickSpec, SpecableSyncedCommands {
    var testedObjectName: String { "Low Priority Synced Commands" }
    func commands(from queueSafeValue: QueueSafeValue<Value>) -> Commands {
        queueSafeValue.wait.lowPriority
    }
    
    override func spec() { runTests() }
}
