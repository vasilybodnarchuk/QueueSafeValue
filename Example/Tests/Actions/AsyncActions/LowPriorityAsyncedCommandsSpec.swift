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
    func commands(from queueSafeValue: QueueSafeValue<Value>, queue: DispatchQueue) -> Commands {
        queueSafeValue.async(performIn: queue).lowPriority
    }

    override func spec() { runTests() }
}
