//
//  LowestPrioritySyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import QueueSafeValue

class LowestPrioritySyncedCommandsSpec: QuickSpec, SpecableSyncedCommands {

    typealias Value = SimpleClass
    typealias Commands = SyncedCommandsWithPriority<Value>
    typealias QueueSafeValueType = QueueSafeValue<Value>

    var testedObjectName: String { "Lowest Priority Synced Commands" }
    func commands(from queueSafeValue: QueueSafeValueType) -> Commands {
        queueSafeValue.wait.lowestPriority
    }
    
    override func spec() { runTests() }
    func createQueueSafeValue(value: SimpleClass) -> QueueSafeValueType { QueueSafeValue(value: value) }
}
