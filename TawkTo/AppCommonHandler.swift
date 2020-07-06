//
//  AppCommonHandler.swift
//  TawkTo
//
//  Created by robert ordiz on 7/5/20.
//  Copyright © 2020 robert ordiz. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class AppCommonHandler {
    func topViewController() -> BaseViewController {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            let baseNavController = topController as! BaseNavigationController
            return (baseNavController.viewControllers.last as? BaseViewController)!
        }
        
        return BaseViewController()
    }
    
    func checkExistingUserID(predicate: NSPredicate) -> Bool {
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
         request.predicate = predicate
         
         do {
             let result = try context.fetch(request)
             if result.count == 0 {
                 return false
             }
             return true
         } catch {
             return false
         }
     }
     
     func fetchData(predicate: NSPredicate) -> [NSManagedObject] {
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
         request.predicate = predicate
         
         do {
             let result = try context.fetch(request)
             if result.count == 0 {
                 return []
             }
             return result as! [NSManagedObject]
         } catch {
             return []
         }
     }
     
     func saveData(data: String? = nil, userID: Int? = 0,  key: String? = "note") {
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let entity = NSEntityDescription.entity(forEntityName: "Notes", in: context)
         let historyData = NSManagedObject(entity: entity!, insertInto: context)

         historyData.setValue(userID, forKey: "id")
         historyData.setValue(data, forKey: key!)
         
         do {
             try context.save()
         } catch {
             print("Failed saving")
         }
     }
     
     func updateData(updatedData: String? = nil, userID: Int? = 0, key: String? = "note") {
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Notes")
         fetchRequest.predicate = NSPredicate(format: "id == %d", userID!)
         do {
             let items = try context.fetch(fetchRequest)
             let data = items[0] as! NSManagedObject
             data.setValue(updatedData, forKey: key!)
             data.setValue(userID, forKey: "id")
             try context.save()
         } catch {
             print("Failed saving")
         }
     }
    
    func delete(userID: Int? = 0, key: String? = "note") {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Notes")
        fetchRequest.predicate = NSPredicate(format: "id == %d", userID!)
        do {
            let items = try context.fetch(fetchRequest)

            for item in items {
                context.delete(item as! NSManagedObject)
            }
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    ////////
    func updateUserData(updatedData: Data? = nil, key: String? = "user") {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Users")
        do {
            let historyData = try context.fetch(fetchRequest)
            if historyData.count > 0 {
                let data = historyData[0] as! NSManagedObject
                data.setValue(updatedData, forKey: key!)
                try context.save()
            } else {
                saveUserData(data: updatedData)
            }
        } catch {
            print("Failed saving")
        }
    }
    
    func saveUserData(data: Data? = nil,  key: String? = "user") {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: context)
        let historyData = NSManagedObject(entity: entity!, insertInto: context)

        historyData.setValue(data, forKey: key!)
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func fetchUsersData() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        do {
            let result = try context.fetch(request)
            if result.count == 0 {
                return []
            }
            return result as! [NSManagedObject]
        } catch {
            return []
        }
    }
}
