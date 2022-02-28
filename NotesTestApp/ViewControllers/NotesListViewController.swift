//
//  NotesListViewController.swift
//  NotesTestApp
//
//  Created by Nechaev Sergey  on 24.02.2022.
//

import UIKit

protocol NotesListViewControllerDelegate {
    func reloadData()
}

class NotesListViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let storage = CoreDataManager.shared
    private let cellID = "Note"
    
    private var notesList: [Note] { storage.notesList }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Note")
    }
    
    @objc private func addNewNote() {
        openSingleView(note: nil)
    }
}

// MARK: - UITableViewDataSource

extension NotesListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let note = notesList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = note.title
        content.textProperties.numberOfLines = 1
        
        let dateFormatter = DateFormatter()
        if let date = note.created {
            dateFormatter.dateFormat = "YY-MM-dd"
            content.secondaryText = dateFormatter.string(from: date)
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = storage.notesList[indexPath.row]
        openSingleView(note: note)
    }
}

// MARK: - UITableViewDelegate

extension NotesListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(at: indexPath)
        }
    }
    
    private func deleteNote(at indexPath: IndexPath) {
        storage.deleteNote(indexPath)
        storage.fetchData()
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

// MARK: - Navigation

extension NotesListViewController {
    func openSingleView(note: Note?) {
        let singleNoteVC = SingleNoteViewController()
        singleNoteVC.note = note
        singleNoteVC.delegate = self
        navigationController?.pushViewController(singleNoteVC, animated: true)
    }
}

// MARK: - TaskViewControllerDelegate

extension NotesListViewController: NotesListViewControllerDelegate {
    func reloadData() {
        storage.fetchData()
        tableView.reloadData()
    }
}

//MARK: - UI Setup

extension NotesListViewController {
    
    private func setupUI() {
        setupNavigationBar()
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "My Notes"
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 18/255,
            green: 16/255,
            blue: 54/255,
            alpha: 255/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewNote)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}
