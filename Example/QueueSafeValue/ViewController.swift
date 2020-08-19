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

    private var atomicValue = QueueSafeValue<Bool>(value: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("1")
        //atomicValue.sync().set(value: false)
//        atomicValue.waitWhile.update { (value) in
//            print(value)
//            value = false
//        }
//        print(atomicValue.syncInCurrentQueue.get())
//        atomicValue.waitUpdate { (value) in
//            value = false
//            sleep(10)
//        }
//        print("2")
//        print(atomicValue.waitGet().notQueueSafeValue)
    }
}
