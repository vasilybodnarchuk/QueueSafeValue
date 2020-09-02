//
//  SpecableActions.swift
//  QueueSafeValue_Tests
//
//  Created by Vasily Bodnarchuk on 8/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

protocol SpecableActions: class {
    associatedtype Value: AnyObject
    associatedtype Actions: AnyObject
    func createInstance(value: Int) -> Value
    func actions(from queueSafeValue: QueueSafeValue<Value>) -> Actions
    var testedObjectName: String { get }
}

extension SpecableActions {
    func createDefultInstance() -> Value { createInstance(value: 0) }
}

extension SpecableActions where Value == SimpleClass   {
    func createInstance(value: Int) -> SimpleClass { .init(value: value) }
}
