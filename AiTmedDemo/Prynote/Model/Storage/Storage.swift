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
    func storageDidLoadNotebooks(storage: Storage, success: Bool, error: AiTmedError?)
    func storageDidLoadAllNotes(storage: Storage, success: Bool, error: AiTmedError?)
    func storageDidAddNotebook(storage: Storage, succcess: Bool, error: AiTmedError?, notebook: Notebook)
}

extension StorageDelegate {
    func storageDidLoadNotebooks(storage: Storage, success: Bool, error: AiTmedError?) {}
    func storageDidLoadAllNotes(storage: Storage, success: Bool, error: AiTmedError?) {}
    func storageDidAddNotebook(storage: Storage, succcess: Bool, error: AiTmedError?, notebook: Notebook) {}
}

///Multicast
extension Storage  {
    func boardcastStorageDidLoadNotebooks(success: Bool, error: AiTmedError?) {
        for delegate in delegates {
            delegate?.storageDidLoadNotebooks(storage: self, success: success, error: error)
        }
    }
    
    func boardcastStorageDidLoadAllNotes(success: Bool, error: AiTmedError?) {
        for delegate in delegates {
            delegate?.storageDidLoadAllNotes(storage: self, success: success, error: error)
        }
    }
    
    func boardcastStorageDidAddNotebook(success: Bool, notebook: Notebook, error: AiTmedError?) {
        for delegate in delegates {
            delegate?.storageDidAddNotebook(storage: self, succcess: success, error: error, notebook: notebook)
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
    

//    func removeNotebook(notebook: Notebook, completion: () -> Void) {
//        if let index = notebooks.firstIndex(of: notebook) {
//            notebooks.remove(at: index)
//            if let id = notebook.id {//remove from remote
//                APIService.removeNotebook([notebook]) { (result) in
//                    switch result {
//                    case .failure(let error):
//                    }
//                }
//            }
//        }
//        
//    }
    
    func loadNotes(in notebook: Notebook, completion: @escaping (Result<[Note], AiTmedError>) -> Void) {
        completion(.success([]))
//        APIService.l
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
    
//
//    func load() {
//        APIService.loadNotebooks { (result) in
//            switch result {
//            case .success(let notebooks):
//                print("load notebooks success")
//                self.isLoadingNotebook = false
//                self.notebooks = notebooks
//                self.ensureExistDefaultNotebook { error in
//                    if error != nil {
//                        print("ensureExistDefaultNotebook failed")
//                        NotificationCenter.default.post(name: .signinRequried, object: self, userInfo: ["reason": "unkown"])
//                        return
//                    }
//                    print("ensureExistDefaultNotebook success")
//                    self.sortByDate()
//                    NotificationCenter.default.post(name: .didLoadAllNotebooks, object: self, userInfo: ["success": true])
//                    let group = DispatchGroup()
//                    notebooks.forEach({ (notebook) in
//                        group.enter()
//                        notebook.load {
//                            group.leave()
//                        }
//                    })
//
//                    group.notify(queue: DispatchQueue.main, execute: {
//                        self.isLoadingNotes = false
//                        NotificationCenter.default.post(name: .didLoadAllNotes, object: self)
//                    })
//
//                }
//            case .failure(let error):
//                print("load notebooks failed")
//                NotificationCenter.default.post(name: .didLoadAllNotebooks, object: self, userInfo: ["success": true, "error": error.detail])
//            }
//        }
//    }
//
//    func ensureExistDefaultNotebook(completion: @escaping (AiTmedError?) -> Void) {
//        if !notebooks.contains(where: { $0.title == "Notes" }) {
//            APIService.addNotebook(title: "Notes", isEncrypt: true) { (result) in
//                switch result {
//                case .failure(let error):
//                    completion(error)
//                case .success(let notebook):
//                    self.notebooks.append(notebook)
//                    completion(nil)
//                }
//            }
//        } else {
//            completion(nil)
//        }
//    }
//
//    func addDefaultNotebook(completion: @escaping (Result<Notebook, AiTmedError>) -> Void) {
////        APIService.addNotebook(title: "Notes", completion: <#T##(Notebook) -> Void#>)
//    }
//
//    func allNotes() -> [Note] {
//        return notebooks.flatMap({ $0.notes })
//    }
//
//    func sharedWithMeNotes() -> [Note] {
//        return []
//    }
//
//    func notes(in notebook: Notebook) -> [Note] {
//        return notebook.notes
//    }
//
//    func numberOfNotebooks() -> Int {
//        return notebooks.count
//    }
//
//    func isDuplicateTitle(_ title: String) -> Bool {
//        return notebooks.contains{ $0.title == title }
//    }
//
//    func indexOf(notebook: Notebook) -> Int? {
//        return notebooks.firstIndex(of: notebook)
//    }
//
//    func defaultNotebook() -> Notebook {
//        return notebooks.first(where: { $0.title == "Notes" })!
//    }
//
//    func sortByDate() {
//        guard !notebooks.isEmpty else { return }
//        if let defaultNotebookIndex = notebooks.firstIndex(where: { $0.title == "Notes" }) {
//            (notebooks[0], notebooks[defaultNotebookIndex]) = (notebooks[defaultNotebookIndex], notebooks[0])
//        }
//        notebooks[1..<notebooks.count].sort(by: { $0.date > $1.date })
//    }
//
//    //crud of notebook
//    func addNotebook(title: String, isEncrypt: Bool = true) {
//        APIService.addNotebook(title: title, isEncrypt: isEncrypt) { (result) in
//            switch result {
//            case .success(let notebook):
//                self.notebooks.append(notebook)
//                self.sortByDate()
//                NotificationCenter.default.post(name: .didAddNotebook, object: self, userInfo: [Constant.UserInfoKey.notebook: notebook])
//            case .failure(let error):
//                NotificationCenter.default.post(name: .didAddNotebook, object: self, userInfo: ["error": error.detail])
//            }
//
//        }
//    }
//
//    func remove(_ notebook: Notebook) {
//        APIService.removeNotebook([notebook]) { (result) in
//            switch result {
//            case .success(_):
//                if let index = self.indexOf(notebook: notebook) {
//                    self.notebooks.remove(at: index)
//                    NotificationCenter.default.post(name: .didRemoveNotebook, object: self, userInfo: [Constant.UserInfoKey.notebook: notebook, "index": index])
//                } else {
//                    NotificationCenter.default.post(name: .didRemoveNotebook, object: self, userInfo: [Constant.UserInfoKey.notebook: notebook, "error": "unkown"])
//                }
//            case .failure(let error):
//                NotificationCenter.default.post(name: .didRemoveNotebook, object: self, userInfo: [Constant.UserInfoKey.notebook: notebook, "error": error.detail])
//            }
//        }
//    }
//
//    func update(_ notebook: Notebook) {
//
//    }
//
//    func load(_ notebook: Notebook) {
//
//    }
//
//    //crud of note
//    func remove(_ note: Note) {
//        let notebook = note.notebook
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if let index = notebook.notes.firstIndex(of: note) {
//                notebook.notes.remove(at: index)
//                NotificationCenter.default.post(name: .didRemoveNote, object: self, userInfo: [Constant.UserInfoKey.note: note])
//            }
//        }
//    }
//
//    func add(_ note: Note) {
//        let notebook = note.notebook
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            notebook.notes.insert(note, at: 0)
//            NotificationCenter.default.post(name: .didAddNote, object: self, userInfo: [Constant.UserInfoKey.note: note])
//        }
//    }
//
//    func load(_ note: Note) {
//        note.isLoading = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            note.title = String(Double.random(in: 1...10))
//            note.content = "adjflaksdjflsdjf \(Int.random(in: 1...1000000))"
//            note.isLoading = false
//            NotificationCenter.default.post(name: .didLoadNote, object: self)
//        }
//    }
//
//    func update(_ note: Note) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//        }
//    }
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
