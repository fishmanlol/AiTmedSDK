//
//  Storage.swift
//  Prynote3
//
//  Created by tongyi on 12/13/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation

enum State {
    case none
    case loading
    case creating
    case updating
    case removing
}

protocol StorageDelegate: AnyObject {
    func storageDidLoadNotebooks(storage: Storage, success: Bool, error: PrynoteError?)
    func storageDidLoadAllNotes(storage: Storage, success: Bool, error: PrynoteError?)
    func storageDidAddNotebook(storage: Storage, succcess: Bool, error: PrynoteError?, notebook: Notebook)
    func storageDidLoadNotebook(storage: Storage, succcess: Bool, error: PrynoteError?, notebook: Notebook)
}

extension StorageDelegate {
    func storageDidLoadNotebooks(storage: Storage, success: Bool, error: PrynoteError?) {}
    func storageDidLoadAllNotes(storage: Storage, success: Bool, error: PrynoteError?) {}
    func storageDidAddNotebook(storage: Storage, succcess: Bool, error: PrynoteError?, notebook: Notebook) {}
    func storageDidLoadNotebook(storage: Storage, succcess: Bool, error: PrynoteError?, notebook: Notebook) {}
}

///Multicast
extension Storage  {
    func boardcastStorageDidLoadNotebooks(success: Bool, error: PrynoteError?) {
        for delegate in delegates {
            delegate?.storageDidLoadNotebooks(storage: self, success: success, error: error)
        }
    }
    
    func boardcastStorageDidLoadAllNotes(success: Bool, error: PrynoteError?) {
        for delegate in delegates {
            delegate?.storageDidLoadAllNotes(storage: self, success: success, error: error)
        }
    }
    
    func boardcastStorageDidAddNotebook(success: Bool, notebook: Notebook, error: PrynoteError?) {
        for delegate in delegates {
            delegate?.storageDidAddNotebook(storage: self, succcess: success, error: error, notebook: notebook)
        }
    }
    
    func boardcastStorageDidLoadNotebook(succeess: Bool, notebook: Notebook, error: PrynoteError?) {
        for delegate in delegates {
            delegate?.storageDidLoadNotebook(storage: self, succcess: succeess, error: error, notebook: notebook)
        }
    }
}

class Storage {
    private let phoneNumber: String
    var notebooks: [Notebook] = []
    var isLoadingAllNotebooks = false
    var isLoadingAllNotes = false
    var isLoadingAllSharedNotes = false
    var isDeleting = false
    var delegates = WeakArray<StorageDelegate>()
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    func numberOfAllNotes() -> Int {
        return notebooks.reduce(0) { $0 + $1.numberOfNotes() }
    }
    
    func addDelegate(_ delegate: StorageDelegate) {
        delegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: StorageDelegate) {
        delegates.remove(delegate)
    }
}

extension Notebook: Equatable {
    static func ==(lhs: Notebook, rhs: Notebook) -> Bool {
        return lhs.id == rhs.id
    }
}

class WeakBox<T> {
    weak var base: AnyObject?
    init<T: AnyObject>(_ base: T) {
        self.base = base
    }
}

class WeakArray<T>: Collection {
    var base: [WeakBox<T>] = []
    
    func append(_ ele: T) {
        base.append(WeakBox<T>(ele as AnyObject))
    }
    
    func remove(_ ele: T) {
        base.removeAll(where: { $0.base === (ele as AnyObject)})
    }
    
    func removeAll() {
        base.removeAll()
    }
    
    var startIndex: Int { return base.startIndex }
    var endIndex: Int { return base.endIndex }
    
    subscript(_ index: Int) -> T? {
        return base[index].base as? T
    }
    
    func index(after idx: Int) -> Int {
        return base.index(after: idx)
    }
}
