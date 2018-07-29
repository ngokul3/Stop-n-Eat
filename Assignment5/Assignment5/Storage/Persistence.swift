//
//  Persistence.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/29/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

class Persistence {
    static let ModelFileName = "AppModel.serialized"
    static let FileMgr = FileManager.default
    
    static func getStorageURL() throws -> URL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if dirPaths.count == 0 {
            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "No paths found"])
        }
  
        let urlPath = URL(fileURLWithPath: dirPaths[0])
        if !FileMgr.fileExists(atPath: dirPaths[0]) {
            try mkdir(urlPath)
        }
        
        return urlPath.appendingPathComponent(ModelFileName)
    }
    
    static func mkdir(_ newDirURL: URL) throws {
        try FileManager.default.createDirectory(at: newDirURL, withIntermediateDirectories: false, attributes: nil)
    }
    
    static func save(_ model: NSObject) throws {
        let saveURL = try Persistence.getStorageURL()
        print("saveURL: \(saveURL)")
      
        let success = NSKeyedArchiver.archiveRootObject(model, toFile: saveURL.path)
        if !success {
            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to archive"])
        }
        print("saved model success: \(success) at \(Date()) to path: \(saveURL)")
    }
    
    
    static func restore() throws -> NSObject {
        let saveURL = try Persistence.getStorageURL()
        guard let rawData = try? Data(contentsOf: URL(fileURLWithPath: saveURL.path)) else {
            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve unarchival data"])
        }
   
        let unarchiver = NSKeyedUnarchiver(forReadingWith: rawData)
        
        guard let model = unarchiver.decodeObject(forKey: "root") as? NSObject else {
            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to find root object"])
        }
        print("restored model successfully at \(Date()): \(type(of: model))")
        return model
    }
}
