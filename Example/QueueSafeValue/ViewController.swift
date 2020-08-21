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
        getSample()
        setSample()
        updateSample()
        updatedSample()
        performSample()
        transformSample()
    }
    
    private func getSample() {
        let atomicValue = QueueSafeValue(value: true)
        print(atomicValue.wait.lowPriority.get())                   // Optional(true)
    }
    
    private func setSample() {
        let atomicValue = QueueSafeValue<Int>(value: 1)
        atomicValue.wait.lowPriority.set(value: 2)
        print(atomicValue.wait.lowPriority.get())                   // Optional(2)
    }
    
    private func updateSample() {
        let atomicValue = QueueSafeValue(value: 1)
        atomicValue.wait.lowPriority.update { $0 = 3 }
        print(atomicValue.wait.lowPriority.get())                   // Optional(3)
    }
    
    private func updatedSample() {
        let atomicValue = QueueSafeValue(value: 1)
        print(atomicValue.wait.lowPriority.updated { $0 = 4 })       // Optional(4)
    }
    
    private func performSample() {
        let atomicValue = QueueSafeValue(value: 6)
        atomicValue.wait.lowPriority.perform { print($0) }           // 6
    }
    
    private func transformSample() {
        let atomicValue = QueueSafeValue(value: 5)
        print(atomicValue.wait.lowPriority.transform { "\($0)" })   // Optional("5")
    }
}
