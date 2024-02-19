//
//  CoreDataStack.swift
//  WeatherIsMyMood
//
//  Created by HappyDuck on 2/16/24.
//

import CoreData

protocol CoreDataObject {
    var persistentContaier: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    func saveWeatherCache(_ info: WeatherContent)
    func fetchWeatherCache(condition: String, completion: @escaping (WeatherConditionInfo?) -> ())
}

final class CoreDataStack: CoreDataObject, ObservableObject {
    
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
    
    private let weatherEntity = "WeatherConditionInfo"
}

extension CoreDataStack {
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
