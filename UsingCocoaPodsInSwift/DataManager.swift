//
//  DataManager.swift
//  UsingCocoaPodsInSwift
//
//  Created by Naoyuki Takura on 2014/07/28.
//  Copyright (c) 2014年 Naoyuki Takura. All rights reserved.
//

import Foundation

private let _dbFilename:String = "my.db"

//instance
private let _instance:DataManager = DataManager(dbFilename: _dbFilename)

class DataManager {
    private var m_db:FMDatabase
    private var m_dbPath:String
    
    init(dbFilename:String) {
        //create database file path at the document Directory
        var documentPath: AnyObject =
            NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory,
                .UserDomainMask,
                true)[0]

        m_dbPath = (documentPath as NSString).stringByAppendingPathComponent(dbFilename)

        NSLog("db file path : %@", m_dbPath)
        m_db = FMDatabase(path:m_dbPath)
        
        //initialize schema if does not create schema ever.
        var fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(m_dbPath) {
            //db file not exist
            //initialize db schema
            if m_db.open() {
                m_db.executeUpdate(
                    "create table memo(id integer primary key autoincrement, contents text, 'update' integer)",
                    withArgumentsInArray: [])
                m_db.close()
                NSLog("initialize database schema.")
            }
        }
    }
    
    
    func open() -> Bool {
        return m_db.open()
    }
    
    func close() -> Bool {
        return m_db.close()
    }
    
    func commit() -> Bool {
        return m_db.commit()
    }

    class func sharedInstance() -> DataManager {
        return _instance
    }
    
    func createNewContent(content:String) -> Bool {
        if m_db.goodConnection() {
            m_db.beginTransaction()
            m_db.executeUpdate("insert into memo (contents, 'update') values (?, ?)", withArgumentsInArray: [content, NSDate()])
            m_db.commit()
            //OK
            return true
        }
        //FAIL, database not opend.
        return false;
    }
    
    func allContents() -> Array<(Int32, String!, NSDate!)> {
        if !m_db.goodConnection() {
            return [];
        }
        
        //empty array
        var contentsArray:[(Int32, String!, NSDate!)] = []

        var resultSet:FMResultSet =
            m_db.executeQuery("select * from memo order by 'update'", withArgumentsInArray: [])
        
        while resultSet.next() {
            var index = resultSet.intForColumnIndex(0)
            var contents = resultSet.stringForColumnIndex(1)
            var nowDate = resultSet.dateForColumnIndex(2)
            
            var row:(Int32, String!, NSDate!) = (index, contents, nowDate)

            //append to array of contents
            contentsArray += [row]

        }

        return contentsArray
    }
    
    func deleteRecord(index:Int) -> Bool {
        if !m_db.goodConnection() {
            return false
        }
        
        m_db.beginTransaction()
        var result = m_db.executeUpdate("delete from memo where id = ?", withArgumentsInArray: [index])
        m_db.commit()
        return result
    }
    
    func count() -> Int32? {
        if !m_db.goodConnection() {
            return nil
        }
        
        var resultSet:FMResultSet =
            m_db.executeQuery("select count(*) from memo", withArgumentsInArray: [])
        
        resultSet.next()
        var count:Int32 = resultSet.intForColumnIndex(0)

        return count
    }
    
    
    
    
}