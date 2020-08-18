//
//  ValueContainerSpec.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 8/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

import Quick
import Nimble
import QueueSafeValue

class ValueContainerSpec: QuickSpec {
    override func spec() {
        
        describe("Value container") {
//            var valueContainer: ValueContainer<SimpleClass>!
//            beforeEach {
//                valueContainer = ValueContainer(value: SimpleClass())
//            }
            
            context("test a strong reference to the wrapped object") {
                let vlaue = 10
                var object: SimpleClass! = .init(value: vlaue)
                let valueContainer = ValueContainer(value: object!)
                
                var retainCount = CFGetRetainCount(object)
                expect(retainCount) == 3
                expect(retainCount) == valueContainer.countObjectReferences()

                object = nil
                retainCount = valueContainer.countObjectReferences()
                it("expected that reference count decreased") { expect(retainCount) == 2 }
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


            it("test ") {
//                var object: SimpleClass = .init()
//                var retainCount = CFGetRetainCount(object)
//                expect(retainCount) == 4
//                let valueContainer = ValueContainer(value: object)
//                retainCount = CFGetRetainCount(object)
//                expect(retainCount) == 3
//                retainCount = valueContainer.countReferencesToObject()
//                expect(retainCount) == 3
//                var object2 = object
//                object = nil
//                retainCount = valueContainer.countReferencesToObject()
//                expect(retainCount) == 3
            }
        }
    }
}
