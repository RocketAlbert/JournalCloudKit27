//
//  EntryController.swift
//  JournalCloudKit27
//
//  Created by Albert Yu on 7/8/19.
//  Copyright © 2019 AlbertLLC. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    static let shared = EntryController()
    private init() {}
    
    
    var entries: [Entry] = []
    
    func save(entry: Entry, completion: @escaping (Bool) -> ()){
        // Why we need the third initializer.
        // Searches the entry and returns it in the from of a record.
        let record = CKRecord(entry: entry)
        CKContainer.default().privateCloudDatabase.save(record) { (record, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            // Adding to the shared instance.
            guard let record = record,
                let entry = Entry(ckRecord: record) else { completion(false) ; return }
            self.entries.append(entry)
            completion(true)
        }
    }
    
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> Void){
        let entry = Entry(title: title, body: body)
        save(entry: entry, completion: completion)
    }
    
    func fetchEntries(completion: @escaping (Bool) -> Void){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryConstants.RecordType, predicate: predicate)
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            guard let records = records else { completion(false) ; return }
            let entries = records.compactMap{ Entry(ckRecord: $0) }
            self.entries = entries
            completion(true)
        }
    }
}

