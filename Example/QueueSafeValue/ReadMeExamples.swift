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
        syncSetActionSample()
        syncUpdateActionSample()
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
            let result = queueSafeValue.wait.lowestPriority.update { currentValue in
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
            let result = queueSafeSyncedValue.lowestPriority.update { currentValue in
                currentValue["b"] = 2
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
            let result = queueSafeValue.wait.lowestPriority.transform { "\($0)" }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        }
        
        // Option 2
        let queueSafeSyncedValue = QueueSafeSyncedValue(value: "1")
        DispatchQueue.global(qos: .background).async {
            let result = queueSafeSyncedValue.lowestPriority.transform { Int($0) }
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(String(describing: value))
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
    
    private func asyncSetActionSample() {
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
    
    private func asyncUpdateActionSample() {
        // Option 1.
        let queueSafeValue = QueueSafeValue<Int>(value: 1)

        // Without completion block
        queueSafeValue.async(performIn: .background).highestPriority.update(closure: { currentValue in
            currentValue = 10
        })
        
        // With completion block
        queueSafeValue.async(performIn: .background).highestPriority.update(closure: { currentValue in
            currentValue = 11
        }, completion: { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        })
        
        // Option 2.
        let queueSafeAsyncedValue = QueueSafeAsyncedValue<Int>(value: 1, queue: .global(qos: .userInteractive))

        // Without completion block
        queueSafeAsyncedValue.highestPriority.update(closure: { currentValue in
            currentValue = 10
        })
        
        // With completion block
        queueSafeAsyncedValue.highestPriority.update(closure: { currentValue in
            currentValue = 11
        }, completion: { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let value): print(value)
            }
        })
    }
}
