//
//  CoreDataManager.swift
//  NotesTestApp
//
//  Created by Nechaev Sergey  on 24.02.2022.
//

import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    var notesList: [Note] { data }
    
    private var data: [Note] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchData() {
        let fetchRequest = Note.fetchRequest()
        do {
            data = try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    func createNote(title: String?, body: NSAttributedString?) {
        let note = Note(context: context)
        note.title = title ?? "Some Title"
        note.body = body ?? nil
        note.created = Date.now
        
        do {
            try context.save()
        } catch let error {
            print("Failed to delete data", error)
        }
    }
    
    func updateNote(note: Note?, title: String?, body: NSAttributedString?) {
        guard let note = note else { return }
        note.title = title
        note.body = body
        do {
            try context.save()
        } catch let error {
            print("Failed to update data", error)
        }
    }
    
    func deleteNote(_ indexPath: IndexPath) {
        let note = data[indexPath.row]
        context.delete(note)
        do {
            try context.save()
        } catch let error {
            print("Failed to delete data", error)
        }
    }
    
    private init() { fetchData() }
    
}
