//
//  MemoViewController.swift
//  UsingCocoaPodsInSwift
//
//  Created by Naoyuki Takura on 2014/09/02.
//  Copyright (c) 2014年 Naoyuki Takura. All rights reserved.
//

import Foundation
import UIKit

class MemoViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private var contents:[(Int32, String!, NSDate!)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //get all contents
        let dataManager: DataManager = DataManager.sharedInstance()
        dataManager.open()
        contents = dataManager.allContents()
        
        //for refreshcontrol
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("onRefreshTable"), forControlEvents: .ValueChanged)

        self.refreshControl = refreshControl
        

    }
    
    deinit {
        DataManager.sharedInstance().close()
    }
    
    @IBAction func addButtonClicked(sender: AnyObject) {
        NSLog("add button clicked.")
        
        //show alert view
        createAlertController()
    }
    
    //for refresh
    func onRefreshTable() {
        self.refreshControl?.beginRefreshing()
        refreshTable()
        self.refreshControl?.endRefreshing();
    }
    
    private func refreshTable() {
        self.contents = DataManager.sharedInstance().allContents()
        self.tableView.reloadData()
    }
    
    //Alert View
    private func createAlertController() {
        //create alert controller
        let alertController = UIAlertController(title: "enter new memo", message: "", preferredStyle: .Alert)
        
        //add text field
        alertController.addTextFieldWithConfigurationHandler { (testField) -> Void in
            //
            testField.placeholder = "enter your memo"
        }

        //create actions
        //ok
        let okAction = UIAlertAction(title: "ok", style: .Default) { action in
            //TODO
            if let textField = alertController.textFields?[0] as? UITextField {
                //got text
                NSLog("test : \(textField.text)")
                
                if textField.text.utf16Count > 0 {
                    //add to database
                    let dataManager = DataManager.sharedInstance()
                    if dataManager.createNewContent(textField.text) {
                        //success
                        //refresh
                        self.refreshTable()
                    }
                }
            }
        }
        //cancel
        let cancelAction = UIAlertAction(title: "cancel", style: .Cancel, handler: nil)
        
        //add actions to controller
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        //show alertController(ios8)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //tableview delegate

    
    //tableview datasource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        //contents
        var content = contents[indexPath.row]
        cell.textLabel?.text = content.1
        cell.tag = Int(content.0)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            if let index = cell?.tag {
                if DataManager.sharedInstance().deleteRecord(index) {
                    //success
                    refreshTable()
                }
            }
        }
    }
    
    
}
