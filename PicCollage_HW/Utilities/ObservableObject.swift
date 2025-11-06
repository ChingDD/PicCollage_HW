//
//  ObservableObject.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/10/29.
//

import Foundation

class ObservableObject <T> {
    var value: T {
        didSet {
            listener?(value)
        }
    }

    private var listener: ((T) -> Void)?
    
    init(value: T) {
        self.value = value
    }
    
    func bind(notifyImmediately: Bool = true, _ listener: @escaping ((T) -> Void)) {
        self.listener = listener
        if notifyImmediately {
            self.listener?(value)
        }
    }
}

class ObservableChangedObject<T: Equatable> {
    var value: T {
        didSet {
            if oldValue != value {
                listener?(value)
            }
        }
    }

    private var listener: ((T) -> Void)?
    
    init(value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping ((T) -> Void)) {
        self.listener = listener
        self.listener?(value)
    }
}
