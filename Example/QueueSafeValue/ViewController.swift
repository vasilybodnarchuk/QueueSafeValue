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
        runSyncActions()
    }
    
}

/// MARK: Sync actions

extension ViewController {
    func runSyncActions() {
        syncGetActionSample()
        syncSetActionSample()
        syncUpdateActionSample()
        syncPerformActionSample()
        syncTransformActionSample()
    }
    
    private func syncGetActionSample() {
        let atomicValue = QueueSafeValue(value: true)
        print(String(describing: atomicValue.wait.lowPriority.get()))                   // success(true)
        print(QueueSafeValue(value: true).wait.lowPriority.get())
    }
    
    private func syncSetActionSample() {
        let atomicValue = QueueSafeValue<Int>(value: 1)
        atomicValue.wait.lowPriority.set(newValue: 2)
        print(String(describing: atomicValue.wait.lowPriority.get()))                   // success(2)
    }
    
    private func syncUpdateActionSample() {
        let atomicValue = QueueSafeValue(value: 1)
        atomicValue.wait.lowPriority.update { $0 = 3 }
        print(String(describing: atomicValue.wait.lowPriority.get()))                   // success(3)
    }
    
    private func syncPerformActionSample() {
        let atomicValue = QueueSafeValue(value: 6)
        atomicValue.wait.lowPriority.perform { print($0) }           // Optional(6)
    }
    
    private func syncTransformActionSample() {
        let atomicValue = QueueSafeValue(value: 5)
        print(String(describing: atomicValue.wait.lowPriority.transform { "\($0)" }))   // success("5")
    }
}
