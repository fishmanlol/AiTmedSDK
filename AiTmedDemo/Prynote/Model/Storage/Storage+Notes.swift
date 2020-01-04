//
//  Storage+Notes.swift
//  AiTmedDemo
//
//  Created by tongyi on 12/30/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Storage {
    func addNoteAtLocal(title: String, content: String, in notebook: Notebook, completion: (Note) -> Void) {
        let note = Note(title: title, content: content, notebook: notebook)
        notebook.notes.insert(note, at: 0)
        completion(note)
    }
    
    func addNoteAtRemote(_ note: Note, completion: @escaping (Result<Void, PrynoteError>) -> Void) {
        let notebook = note.notebook
        APIService.addNote(note: note, in: notebook) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(_):
                completion(.success(()))
            }
        }
    }
    
    func loadNotes(in notebook: Notebook, completion: @escaping (Result<[Note], PrynoteError>) -> Void) {
        guard let notebookID = notebook.id else {
            completion(.failure(.unkown))
            return
        }
        
        APIService.loadNotes(in: notebookID) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(.unkown))
            case .success(let files):
                let notes = files.map { Note(file: $0, notebook: notebook) }
                completion(.success(notes))
            }
        }
    }
    
    func indexInNotebook(_ note: Note) -> Int? {
        return note.notebook.notes.firstIndex(of: note)
    }
    
    func allNotes() -> [Note] {
        return notebooks.flatMap({ $0.notes })
    }

    func sharedWithMeNotes() -> [Note] {
        return []
    }

    func notes(in notebook: Notebook) -> [Note] {
        return notebook.notes
    }
}
