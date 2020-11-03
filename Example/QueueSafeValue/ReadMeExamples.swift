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

/// MARK: Sync actions

extension ReadMeExamples {
    func runSyncActions() {
        syncGetActionSample()
        syncGetInClosureActionSample()
        syncedGetValueInsideClosureCommandWithManualCompletionSample()
        syncSetActionSample()
        syncUpdateActionSample()
        syncedUpdateValueInsideClosureCommandWithManualCompletionSample()
        syncTransformActionSample()
    }
    
    private func syncGetActionSample() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: true)
        DispatchQueue.global(qos: .utility).async {
            let result = queueSafeValue.wait.lowestPriority.get()
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }

        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: "a")
        DispatchQueue.global(qos: .utility).async {
            let result = queueSafeSyncedValue.lowestPriority.get()
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func syncGetInClosureActionSample() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: 6)
        DispatchQueue.global(qos: .unspecified).async {
            queueSafeValue.wait.lowestPriority.get { result in
                switch result {
                case .failure(let error): print(error)
                case .success(let value): print(value)
                }
            }
        }
        
        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: [1,2,3])
        DispatchQueue.global(qos: .utility).async {
            queueSafeSyncedValue.lowestPriority.get { result in
                switch result {
                case .failure(let error): print(error)
                case .success(let value): print(value)
                }
            }
        }
    }
    
    private func syncedGetValueInsideClosureCommandWithManualCompletionSample() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: 4.44)
        DispatchQueue.global(qos: .unspecified).async {
            queueSafeValue.wait.highestPriority.get { (result, complete) in
                switch result {
                case .failure(let error): print(error)
                case .success(let value): print(value)
                }
                complete() // should always be executed (called)
            }
        }
        
        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: 4.45)
        DispatchQueue.global(qos: .utility).async {
            queueSafeSyncedValue.highestPriority.get { (result, complete) in
                switch result {
                case .failure(let error): print(error)
                case .success(let value): print(value)
                }
                complete() // should always be executed (called)
            }
        }
    }
    
    private func syncSetActionSample() {
        // Option 1
        let queueSafeValue = QueueSafeValue<Int>(value: 1)
        DispatchQueue.global(qos: .userInitiated).async {
            let result = queueSafeValue.wait.lowestPriority.set(newValue: 2)
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: "b")
        DispatchQueue.global(qos: .userInitiated).async {
            let result = queueSafeSyncedValue.lowestPriority.set(newValue: "b1")
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func syncUpdateActionSample() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: 1)
        DispatchQueue.main.async {
            let result = queueSafeValue.wait.lowestPriority.set { currentValue in
                currentValue = 3
            }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: ["a":1])
        DispatchQueue.main.async {
            let result = queueSafeSyncedValue.lowestPriority.set { currentValue in
                currentValue["b"] = 2
            }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func syncedUpdateValueInsideClosureCommandWithManualCompletionSample() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: "value 1")
        DispatchQueue.main.async {
            let result = queueSafeValue.wait.lowestPriority.set { currentValue, complete in
                currentValue = "value 2"
                complete() // should always be executed (called)
            }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: "value a")
        DispatchQueue.main.async {
            let result = queueSafeSyncedValue.lowestPriority.set { currentValue, complete in
                currentValue = "value b"
                complete() // should always be executed (called)
            }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func syncTransformActionSample() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: 5)
        DispatchQueue.global(qos: .background).async {
            let result = queueSafeValue.wait.lowestPriority.map { "\($0)" }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: "1")
        DispatchQueue.global(qos: .background).async {
            let result = queueSafeSyncedValue.lowestPriority.map { Int($0) }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(String(describing: value))
            }
        }
    }
}

// MARK: Async actions

extension ReadMeExamples {
    func runAsyncActions() {
        getValueAasynchronously()
        getValueAasynchronouslyWithManualCompletion()
        asynchronousSimpleValueSetting()
        asynchronousValueSettingInClosure()
        asynchronousValueSettingInClosureWithManualCompletion()
    }
    
    // MARK: Async get

    private func getValueAasynchronously() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: true)
        queueSafeValue.async(performIn: .global(qos: .utility)).highestPriority.get { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2
        let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: true, queue: .global(qos: .utility))
        queueSafeAsyncedValue.highestPriority.get { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    // MARK: Async get with manual completion
    
    private func getValueAasynchronouslyWithManualCompletion() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: "test")
        queueSafeValue.async(performIn: .global(qos: .utility)).highestPriority.get { result, done in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
            done()
        }
        
        // Option 2
        let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: "super test", queue: .global(qos: .background))
        queueSafeAsyncedValue.highestPriority.get { result, done in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
            done()
        }
    }
    
    private func asynchronousSimpleValueSetting() {
        // Option 1
        let queueSafeValue = QueueSafeValue(value: 7)
        
        // Without completion block
        queueSafeValue.async(performIn: .main).highestPriority.set(newValue: 8)
        
        // With completion block
        queueSafeValue.async(performIn: .main).highestPriority.set(newValue: 9) { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2
        let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: 7, queue: .global())
        
        // Without completion block
        queueSafeAsyncedValue.highestPriority.set(newValue: 8)
        
        // With completion block
        queueSafeAsyncedValue.highestPriority.set(newValue: 9) { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func asynchronousValueSettingInClosure() {
        // Option 1.
        let queueSafeValue = QueueSafeValue(value: 1)

        // Without completion block
        queueSafeValue.async(performIn: .background).highestPriority.set { $0 = 10 }
        
        // With completion block
        queueSafeValue.async(performIn: .background).highestPriority.set { currentValue in
            currentValue = 11
        } completion: { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2.
        let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: 1, queue: .global(qos: .userInteractive))

        // Without completion block
        queueSafeAsyncedValue.highestPriority.set { $0 = 10 }
        
        // With completion block
        queueSafeAsyncedValue.highestPriority.set { currentValue in
            currentValue = 11
        } completion: { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
    
    private func asynchronousValueSettingInClosureWithManualCompletion() {
        // Option 1.
        let queueSafeValue = QueueSafeValue(value: 999.1)

        // Without completion block
        queueSafeValue.async(performIn: .background).highestPriority.set { currentValue, done in
            currentValue = 999.2
            done()
        }
        
        // With completion block
        queueSafeValue.async(performIn: .background).highestPriority.set { currentValue, done in
            currentValue = 999.3
            done()
        } completion: { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2.
        let queueSafeAsyncedValue = QueueSafeAsyncedValue(value: 1000.1, queue: .global(qos: .userInteractive))

        // Without completion block
        queueSafeAsyncedValue.highestPriority.set { currentValue, done in
            currentValue = 1000.2
            done()
        }
        
        // With completion block
        queueSafeAsyncedValue.highestPriority.set { currentValue, done in
            currentValue = 1000.3
            done()
        } completion: { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
    }
}
