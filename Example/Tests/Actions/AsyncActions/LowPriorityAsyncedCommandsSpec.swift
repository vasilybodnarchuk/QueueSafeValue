//
//  LowPriorityAsyncedCommandsSpec.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class LowPriorityAsyncedCommandsSpec: QuickSpec, SpecableAsyncedCommands {
    var testedObjectName: String { "Low Priority Asynced Commands" }
    func commands(from queueSafeValue: QueueSafeValue<Value>) -> Commands {
        commands(from: queueSafeValue, queue: .global(qos: .default))
    }

    override func spec() { runTests() }
}
