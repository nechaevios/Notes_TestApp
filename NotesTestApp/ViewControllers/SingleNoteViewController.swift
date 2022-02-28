//
//  SingleNoteViewController.swift
//  NotesTestApp
//
//  Created by Nechaev Sergey  on 24.02.2022.
//

import UIKit

class SingleNoteViewController: UIViewController {
    
    var delegate: NotesListViewControllerDelegate?
    var note: Note?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    private lazy var noteTextView: UITextView = {
        let textView = UITextView(frame: CGRect.zero, textContainer: nil)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.attributedText = NSAttributedString(string: "Enter Text")
        textView.backgroundColor = .secondarySystemBackground
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.tintColor = .systemRed
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.isScrollEnabled = true
        textView.sizeToFit()
        textView.showsVerticalScrollIndicator = true
        textView.isEditable = true
        textView.allowsEditingTextAttributes = true
        
        return textView
    }()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let storage = CoreDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        registerKeyboardNotification()
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    @objc private func save() {
        prepareData { title, body in
            if note == nil {
                storage.createNote(title: title, body: body)
            } else {
                storage.updateNote(note: note, title: title, body: body)
            }
        }
        
        delegate?.reloadData()
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func prepareData(completion: (String, NSAttributedString) -> ()) {
        if !noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            guard let originalText = noteTextView.attributedText else { return }
            let originalTextString = originalText.string
            let lines = originalTextString.split(separator:"\n")
            guard let title = lines.first else { return }
            completion(String(title), originalText )
        }
    }
}

extension SingleNoteViewController {
    
    //MARK: - Setup UI
    
    private func setupNavigationBar() {
        let title = note == nil ? "New Note" : note?.title
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(save)
        )
    }
    
    private func setupUI() {
        setupNavigationBar()
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(noteTextView)
        
        if note != nil {
            guard let text = note?.body else { return }
            noteTextView.attributedText = text
        }
    }
    
    //MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            noteTextView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            noteTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            noteTextView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -70),
            noteTextView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    // MARK: - Keyboard Show Hide
    
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        let userInfo = notification.userInfo
        guard var keyboardHeight = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardHeight = noteTextView.convert(keyboardHeight, from:nil)
        noteTextView.contentInset.bottom = keyboardHeight.size.height
        noteTextView.verticalScrollIndicatorInsets.bottom = keyboardHeight.size.height
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        noteTextView.contentInset = contentInsets
        noteTextView.verticalScrollIndicatorInsets = contentInsets
    }
}
