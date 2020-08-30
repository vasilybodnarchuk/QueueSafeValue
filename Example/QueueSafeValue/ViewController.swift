//
//  ViewController.swift
//  QueueSafeValue
//
//  Created by Vasily Bodnarchuk on 06/30/2020.
//  Copyright (c) 2020 Vasily Bodnarchuk. All rights reserved.
//

import UIKit
import QueueSafeValue

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Examples().run()
    }
}

class Examples {
    func run() {
        runSyncActions()
        runAsyncActions()
    }
}

extension Examples {
    private func log<Value>(title: String, result: (Result<Value, QueueSafeValueError>)) {
        var description = "\"\(title)\" func result: "
        switch result {
        case .failure(let error): description += "\(error)"
        case .success(let value): description += "\(value)"
        }
        print(description + " or \(result)")
    }
}

/// MARK: Sync actions

extension Examples {
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
            let result = queueSafeValue.wait.lowPriority.get()
            self.log(title: "Sync lowPriority get", result: result)
        }
    }
    
    private func syncGetInClosureActionSample() {
        let queueSafeValue = QueueSafeValue(value: 6)
        DispatchQueue.global(qos: .unspecified).async {
            queueSafeValue.wait.lowPriority.get { result in
                self.log(title: "Sync lowPriority get in closure", result: result)
            }
        }
    }
    
    private func syncSetActionSample() {
        let queueSafeValue = QueueSafeValue<Int>(value: 1)
        DispatchQueue.global(qos: .userInitiated).async {
            let result = queueSafeValue.wait.lowPriority.set(newValue: 2)
            self.log(title: "Sync lowPriority set", result: result)
        }
    }
    
    private func syncUpdateActionSample() {
        let queueSafeValue = QueueSafeValue(value: 1)
        DispatchQueue.main.async {
            let result = queueSafeValue.wait.lowPriority.update { currentValue in
                currentValue = 3
            }
            self.log(title: "Sync lowPriority update", result: result)
        }
    }
    
    private func syncTransformActionSample() {
        let queueSafeValue = QueueSafeValue(value: 5)
        DispatchQueue.global(qos: .background).async {
            let result = queueSafeValue.wait.lowPriority.transform { "\($0)" }
            self.log(title: "Sync lowPriority transform", result: result)
        }
    }
}

/// MARK: Async actions

extension Examples {
    func runAsyncActions() {
        asyncGetActionSample()
        asyncSetActionSample()
        asyncUpdateActionSample()
    }

    private func asyncGetActionSample() {
        let queueSafeValue = QueueSafeValue(value: true)
        queueSafeValue.async(performIn: .global(qos: .utility)).lowPriority.get { result in
            self.log(title: "Async lowPriority get", result: result)
        }
    }
    
    private func asyncSetActionSample() {
        let queueSafeValue = QueueSafeValue(value: 7)
        
        // Without completion block
        queueSafeValue.async(performIn: .main).lowPriority.set(newValue: 8)
        
        // With completion block
        queueSafeValue.async(performIn: .main).lowPriority.set(newValue: 9) { result in
            self.log(title: "Async lowPriority set", result: result)
        }
    }
    
    private func asyncUpdateActionSample() {
        let queueSafeValue = QueueSafeValue<Int>(value: 1)
        // Without completion block
        queueSafeValue.async(performIn: .background).lowPriority.update(closure: { currentValue in
            currentValue = 10
        })
        
        // With completion block
        queueSafeValue.async(performIn: .background).lowPriority.update(closure: { currentValue in
            currentValue = 11
        }, completion: { result in
            self.log(title: "Async lowPriority update", result: result)
        })
    }
}
