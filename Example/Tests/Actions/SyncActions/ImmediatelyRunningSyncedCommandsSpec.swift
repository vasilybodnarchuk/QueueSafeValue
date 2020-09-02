//
//  ImmediatelyRunningSyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 9/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class ImmediatelyRunningSyncedCommandsSpec: QuickSpec, SpecableSyncedCommands {
    var testedObjectName: String { "Immediately Running Synced Commands" }
    func commands(from queueSafeValue: QueueSafeValue<Value>) -> Commands {
        queueSafeValue.wait.immediately
    }
    
    override func spec() { runTests() }
}
