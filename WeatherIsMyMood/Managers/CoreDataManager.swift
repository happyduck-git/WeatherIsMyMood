//
//  CoreDataStack.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/16/24.
//

import CoreData
import ActivityKit

protocol CoreDataObject {
    var persistentContaier: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    func saveWeatherCache(_ info: WeatherContent)
    func fetchWeatherCache(condition: String, completion: @escaping (WeatherConditionInfo?) -> ())
}

final class CoreDataManager: CoreDataObject, ObservableObject {
    
    @Published var error: Error?
    
    private let weatherEntity = "WeatherConditionInfo"
    private let currentActivity = "CurrentActivity"
    
    lazy var persistentContaier: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
#if DEBUG
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
#else
                print("Failed to load persistent stores: \(error.localizedDescription)")
#endif
            }
        }
        return container
    }()
    
    lazy var context: NSManagedObjectContext = self.persistentContaier.viewContext
    
}

extension CoreDataManager {

    func save<T: NSManagedObject>(_ data: T) {
        self.context.insert(data)
        if self.context.hasChanges {
            do {
                try self.context.save()
            }
            catch {
                self.error = CoreDataError.saveNotSuccess
            }
        }
    }
    
    func delete<T: NSManagedObject>(_ data: T) {
        self.context.delete(data)
        do {
            try self.context.save()
        }
        catch {
            self.error = CoreDataError.saveNotSuccess
        }
    }
}

extension CoreDataManager {
    func saveWeatherCache(_ info: WeatherContent) {
        
        let _ = NSEntityDescription.entity(forEntityName: self.weatherEntity,
                                           in: self.context)
        
        let weather = WeatherConditionInfo(context: self.context)
        weather.backgroundImage = info.imageData
        weather.name = info.name
        
        do {
            try self.context.save()
        }
        catch {
            print("Error saving weather cache to CoreData -- \(error)")
        }
    }
    
    func fetchWeatherCache(condition: String, completion: @escaping (WeatherConditionInfo?) -> ()) {
        
        guard let request = persistentContaier
            .managedObjectModel
            .fetchRequestFromTemplate(withName: self.weatherEntity,
                                      substitutionVariables: ["name": condition]) as? NSFetchRequest<WeatherConditionInfo> else {
            completion(nil)
            return
        }
        
        let fetchRequest = NSAsynchronousFetchRequest<WeatherConditionInfo>(fetchRequest: request) { result in
            completion(result.finalResult?.first)
        }
        
        do {
            try self.context.execute(fetchRequest)
            
        }
        catch {
            completion(nil)
        }
    }
}

extension CoreDataManager {
    enum CoreDataError: Error {
        case saveNotSuccess
        case deleteNotSuccess
    }
}
