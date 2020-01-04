//
//  Storage+Notebook.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/30/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Storage {
    //MARK: - Load
    ///Load all if ids == []
    func loadNotebooks(ids: [Data] = []) {
        isLoadingAllNotebooks = true
        isLoadingAllNotes = true
        isLoadingAllSharedNotes = true
        
        APIService.loadNotebooks(ids: ids) { (result) in
            switch result {
            case .failure(let error):
                self.isLoadingAllNotebooks = false
                self.isLoadingAllNotes = false
                
                self.boardcastStorageDidLoadNotebooks(success: false, error: .unkown)
            case .success(let notebooks):
                self.isLoadingAllNotebooks = false
                self.notebooks = notebooks
                self.boardcastStorageDidLoadNotebooks(success: true, error: nil)
                
                let group = DispatchGroup()
                notebooks.forEach({ (notebook) in
                    notebook.isLoading = true
                    group.enter()
                    
                    self.loadNotes(in: notebook, completion: { (result) in
                        notebook.isLoading = false
                        group.leave()
                        switch result {
                            case .failure(let error):
                                print(error)
                                self.boardcastStorageDidLoadNotebook(succeess: false, notebook: notebook, error: .unkown)
                            case .success(let notes):
                                notebook.notes = notes
                            self.boardcastStorageDidLoadNotebook(succeess: true, notebook: notebook, error: .unkown)
                        }
                    })
                })
                
                group.notify(queue: DispatchQueue.main, execute: {
                    self.isLoadingAllNotes = false
                    self.boardcastStorageDidLoadAllNotes(success: true, error: nil)
                })
            }
        }
    }
    
    //MARK: - Add
    func addNotebookAtLocal(notebook: Notebook, at index: Int, completion: (Int) -> Void) {
        notebooks.insert(notebook, at: index)
        completion(index)
    }
    
    func addNotebookAtRemote(notebook: Notebook, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        APIService.addNotebook(title: notebook.title, isEncrypt: false) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(let id):
                notebook.id = id
                completion(.success(()))
            }
        }
    }
    
    //MARK: - Remove
    func removeNotebookAtLocal(notebook: Notebook, completion: (Int) -> Void) {
        if let index = notebooks.firstIndex(of: notebook) {
            notebooks.remove(at: index)
            completion(index)
        }
    }
    
    func removeNotebookAtRemote(notebook: Notebook, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        if let id = notebook.id {
            isDeleting = true
            APIService.removeNotebook(id) { (result) in
                self.isDeleting = false
                switch result {
                case .failure(let error):
                    completion(.failure(.unkown))
                case .success(_):
                    completion(.success(()))
                }
            }
        } else {
            completion(.failure(.unkown))
        }
    }
    
    //MARK: - Update
    func updateNotebookAtLocal(notebook: Notebook, title: String, completion: (Int) -> Void) {
        if let index = notebooks.firstIndex(of: notebook) {
            notebook.title = title
            completion(index)
        }
    }
    
    func updateNotebookAtRemote(notebook: Notebook, title: String? = nil, isEncrypt: Bool? = nil, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        if let id = notebook.id {
            APIService.updateNotebook(id: id, title: title, isEncrypt: isEncrypt) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(.unkown))
                case .success(_):
                    completion(.success(()))
                }
            }
        }
    }
    
    //MARK: - Helper
    func numberOfNotebooks() -> Int {
        return notebooks.count
    }
    
    func notebook(at index: Int) -> Notebook? {
        guard isSafeIndexForNotebook(index) else { return nil }
        
        return notebooks[index]
    }
    
    func isSafeIndexForNotebook(_ index: Int) -> Bool {
        if index >= 0 && index < notebooks.count {
            return true
        } else {
            return false
        }
    }
    
    func index(of notebook: Notebook) -> Int? {
        return notebooks.firstIndex(of: notebook)
    }
}
