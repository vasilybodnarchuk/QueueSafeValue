//
//  ValueContainerSpec.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import QueueSafeValue

class ValueContainerSpec: QuickSpec {
    override func spec() {
        
        describe("Value container") {
            context("test a strong reference to the wrapped object") {
                let vlaue = 10
                var object: SimpleClass! = .init(value: vlaue)
                let valueContainer = ValueContainer(value: object!)
                
                let retainCount1 = CFGetRetainCount(object)
                let retainCount2 = Int(valueContainer.countObjectReferences())
                it("expected that reference count increased") {
                    expect(retainCount1) == 3
                    expect(retainCount1) == retainCount2
                }
                
                object = nil
                let retainCount3 = valueContainer.countObjectReferences()
                it("expected that reference count decreased") { expect(retainCount3) == 2 }
                
                let dispatchQueue = DispatchGroup()
                dispatchQueue.enter()
                var _value: Int!
                valueContainer.appendAndPerform { obj in
                    _value = obj.value
                    dispatchQueue.leave()
                }
                dispatchQueue.wait()
                it("expected that value exists") { expect(_value) == vlaue }
            }
        }
    }
}