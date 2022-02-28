//
//  AppDelegate.swift
//  NotesTestApp
//
//  Created by Nechaev Sergey  on 24.02.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: NotesListViewController())
        window?.makeKeyAndVisible()
        generateFirstNote()
        
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotesTestApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func generateFirstNote() {
        let isNotFirstOpen = UserDefaults.standard.bool(forKey: "isNotFirstOpen")
        if !isNotFirstOpen {
            let string = """
            Note example.

            https://github.com/nechaevios
            """
            let nsString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0)])
            CoreDataManager.shared.createNote(
                title: "Note example.",
                body: nsString)
            
            UserDefaults.standard.set(true, forKey: "isNotFirstOpen")
            CoreDataManager.shared.fetchData()
        }
    }
}
