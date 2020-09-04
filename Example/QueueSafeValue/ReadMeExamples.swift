//
//  ReadMeExamples.swift
//  QueueSafeValue_Example
//
//  Created by Vasily Bodnarchuk on 9/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import QueueSafeValue

class ReadMeExamples {
    func run() {
        runSyncActions()
        runAsyncActions()
    }
}

//extension ReadMeExamples {
//    private func log<Value>(title: String, result: (Result<Value, QueueSafeValueError>)) {
//        var description = "\"\(title)\" func result: "
//        switch result {
//        case .failure(let error): description += "\(error)"
//        case .success(let value): description += "\(value)"
//        }
//        print(description + " or \(result)")
//    }
//}

/// MARK: Sync actions

extension ReadMeExamples {
    func runSyncActions() {
        syncGetActionSample()
        syncGetInClosureActionSample()
        syncSetActionSample()
        syncUpdateActionSample()
        syncTransformActionSample()
    }
    
    private func syncGetActionSample() {
        let queueSafeValue = QueueSafeValue(value: true)
        DispatchQueue.global(qos: .utility).async {
            let result = queueSafeValue.wait.lowestPriority.get()
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func syncGetInClosureActionSample() {
        let queueSafeValue = QueueSafeValue(value: 6)
        DispatchQueue.global(qos: .unspecified).async {
            queueSafeValue.wait.lowestPriority.get { result in
                switch result {
                case .failure(let error): print(error)
                case .success(let value): print(value)
                }
            }
        }
    }
    
    private func syncSetActionSample() {
        let queueSafeValue = QueueSafeValue<Int>(value: 1)
        DispatchQueue.global(qos: .userInitiated).async {
            let result = queueSafeValue.wait.lowestPriority.set(newValue: 2)
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func syncUpdateActionSample() {
        let queueSafeValue = QueueSafeValue(value: 1)
        DispatchQueue.main.async {
            let result = queueSafeValue.wait.lowestPriority.update { currentValue in
                currentValue = 3
            }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func syncTransformActionSample() {
        let queueSafeValue = QueueSafeValue(value: 5)
        DispatchQueue.global(qos: .background).async {
            let result = queueSafeValue.wait.lowestPriority.transform { "\($0)" }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
}

/// MARK: Async actions

extension ReadMeExamples {
    func runAsyncActions() {
        asyncGetActionSample()
        asyncSetActionSample()
        asyncUpdateActionSample()
    }

    private func asyncGetActionSample() {
        let queueSafeValue = QueueSafeValue(value: true)
        queueSafeValue.async(performIn: .global(qos: .utility)).lowestPriority.get { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func asyncSetActionSample() {
        let queueSafeValue = QueueSafeValue(value: 7)
        
        // Without completion block
        queueSafeValue.async(performIn: .main).lowestPriority.set(newValue: 8)
        
        // With completion block
        queueSafeValue.async(performIn: .main).lowestPriority.set(newValue: 9) { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func asyncUpdateActionSample() {
        let queueSafeValue = QueueSafeValue<Int>(value: 1)
        // Without completion block
        queueSafeValue.async(performIn: .background).lowestPriority.update(closure: { currentValue in
            currentValue = 10
        })
        
        // With completion block
        queueSafeValue.async(performIn: .background).lowestPriority.update(closure: { currentValue in
            currentValue = 11
        }, completion: { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        })
    }
}
