//
//  BACKUP_CODE.swift
//  CashTab-V1
//
//  Created by Kevin Tsui on 3/10/16.
//  Copyright © 2016 Kevin Tsui. All rights reserved.
//

//
//  ViewController.swift
//  CashTab-V1
//
//  Created by Kevin Tsui & Grant Campanelli on 2/9/16.
//  Copyright © 2016 Kevin Tsui. All rights reserved.
//
//


// -------------------------------------------
// -------------------------------------------
// -------------------------------------------

// TransactionTableViewController.swift

// -------------------------------------------
// -------------------------------------------
// -------------------------------------------


import UIKit
import CoreData

// Custom UITableViewCell allowing for customized prototype cells (Configureable in Storyboard)
class BACKUP_TransactionViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    var thisTransaction: NSManagedObject?
}


class BACKUP_TransactionTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var myTableView: UITableView!
    
    var transactions = [NSManagedObject]() // Array of CoreData Objects
    
    
    // -------------------
    // MARK: Actions
    // -------------------
    
    // Add a transaction
    @IBAction func addTransaction(sender: AnyObject) {
        // Setting up controller for the pop-up that will appear when the button is pressed
        let alert = UIAlertController(title: "New Transaction", message: "Add a new transaction", preferredStyle: .Alert)
        
        // Setting up Save Action
        // Takes whatever text is in the textfield and puts it into the Transactions array
        let saveAction = UIAlertAction(title: "Save",
            style: .Default,
            handler: { (action:UIAlertAction) -> Void in
                let transactionTitle = alert.textFields![0]
                let transactionCost = alert.textFields![1]
                self.saveTransaction(transactionTitle.text!, cost: transactionCost.text!)
                self.myTableView.reloadData()
        })
        
        // Setting up Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) {
            (action: UIAlertAction) -> Void in
        }
        
        // Configure the alert controller - Add a textfield in the alert
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        // Add another textfield in the alert
        alert.addTextFieldWithConfigurationHandler {
            (transactionCost: UITextField) -> Void in
            transactionCost.placeholder = "$1.99"
        }
        
        
        // Add the "Save" and "Cancel" actions to the alert controller
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // Display the Alert View Controller on-screen
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Action handling the unwind segue -> Add a new row to the table view in the transaction table
    @IBAction func unwindToTransactionList(sender: UIStoryboardSegue) {
        
        // Unwind Segue after hitting "Save" button in the Transaction Details VC
        if let sourceViewController = sender.sourceViewController as? TransactionDetailViewController, newTransaction = sourceViewController.curTransaction {
            
            // Create a reference to the managed object context so we can make changes to it (SO TEDIOUS)
            let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext  = appDelegate.managedObjectContext
            
            
            // Update an existing transaction and reload the table view
            if let selectedIndexPath = myTableView.indexPathForSelectedRow {
                
                // TODO - Refactor Code to remove NSManagedObject overhead
                
                //                transactions[selectedIndexPath.row] = newTransaction
                //                myTableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            
            // Add a new transaction
            let newIndexPath = NSIndexPath(forRow: transactions.count, inSection: 0)
            
            
            // Create a new managed object of "Transaction" type (SO TEDIOUS)
            let entity          = NSEntityDescription.entityForName("Transaction", inManagedObjectContext: managedContext)
            let transactionMO   = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            // Set the values of the new Transaction Managed Object using the 'newTransaction'
            transactionMO.setValue(newTransaction.title, forKey: "title")
            transactionMO.setValue(newTransaction.cost, forKey: "cost")
            
            // Append the new managed object to the list of transactions
            transactions.append(transactionMO)
            
            // Animates the addition of a new row to the table view
            // '.Bottom' shows the inserted row slide in from the bottom
            myTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            
            // Try to commit the changes to the managed object context
            self.commitChanges()
        }
    }
    
    
    // -----------------
    // MARK: Callbacks
    // -----------------
    
    // Handle Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Prepare to move to the TransactionDetailViewController
        // Pass data from the selected row to that VC
        if segue.identifier == "EditTransaction" {
            // Ensure the destination View Controller is a TransactionDetailViewController
            let dest = segue.destinationViewController as! TransactionDetailViewController
            
            // Get the data from the selected row so we can pass it to the destination VC
            if let transactionCell = sender as? TransactionViewCell {
                let selectedIndexPath = myTableView.indexPathForCell(transactionCell)
                let selectedTransaction = transactions[selectedIndexPath!.row]
                
                // Create a new Transaction using the selectedTransaction (of type NSManagedObject) to pass to dest VC
                let transactionToPass = Transaction(title: selectedTransaction.valueForKey("title") as! String,
                    cost: selectedTransaction.valueForKey("cost") as! String)
                
                // Set the Destination VC data
                dest.curTransaction = transactionToPass
            }
            else if segue.identifier == "AddTransaction" {
                print("Adding a transaction...")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // -- Initial Setup --
        // Register the UITableViewCell class with the table view so when dequeueing a cell,
        //  the table view will return a cell with the correct type
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // Callback just before view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update the transactions view array
        self.fetchTransactions()
    }
    
    // ---------------------------------------
    // MARK: Helper Functions
    // ---------------------------------------
    
    // Commit all changes to the managed context to disk
    func commitChanges() {
        // Get the application delegate and grab a reference to its managed object context
        let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext  = appDelegate.managedObjectContext
        
        // Commit the changes to the disk
        do {
            // Try to save the changes, note that it COULD throw an error
            try managedContext.save()
            
        } catch let error as NSError {
            print("Welp. Couldn't save \(error), \(error.userInfo)")
        }
    }
    
    // Fetch (query) the transactions from the context
    func fetchTransactions() {
        
        // 1: Get the application delegate and grab a reference to its managed object context
        let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext  = appDelegate.managedObjectContext
        
        // 2: Create a fetch request that will find all 'Transaction's (entity description)
        /*
        - FULL EXPLANATION -
        NSFetchRequest is the class responsible for fetching from Core Data, essentially the thing that queries the database. NSEntityDescription is a qualifier that can refine these results. (e.g. "I want all employees in the past 3 years)
        
        Setting a fetch request's entity property (or initializing it with init(entityName: <something>)), fetches all objects of a particular entity. This is how we will fetch all transactions.
        */
        let fetchRequest = NSFetchRequest(entityName: "Transaction")
        
        
        // 3: Use the fetch request to grab an array of the transactions that matches the request
        /*
        - FULL EXPLANATION -
        We hand the fetch request to the managed object context to do the heavy lifting.
        
        executeFetchRequest(...)
        Returns an array of managed objects that meets the criteria specified by the fetch request
        */
        do {
            // execute the fetch request and store the result
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            // set our transactions array to the result of the fetch which should be an NSManagedObject array
            transactions = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Yikes. Could NOT fetch \(error), \(error.userInfo)")
        }
    }
    
    // Save the transaction to the managed object context
    func saveTransaction(title: String, cost: String){
        // 1: Acquire the managed object context (so we can do work with managed objects) using a reference to the app delegate
        /*
        - FULL EXPLANATION -
        Before we can save/retrieve anything from our Core Data store, we first need to get an NSManagedObjectContext.
        Think of a managed object context as an in-memory "scratchpad" for working with managed objects.
        
        Saving a new managed object to Core Data is considered a 2-step process
        1: Insert a new managed object into a managed object context
        2: "Commit" the changes in our managed object context (overwriting the existing context)
        
        The default managed object context was created during the project's creation and lives as a property of the
        application delegate. To access it, we first need a reference to the app delegate
        */
        let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext  = appDelegate.managedObjectContext
        
        
        // 2: Create and insert a new managed object into the context
        /*
        - FULL EXPLANATION -
        We are creating a new managed object and inserting it into the managed object context.
        
        NSEntityDescription
        The NSManagedObject is a "shape-shifter" class (able to represent any entity). It's the piece that links the entity definition from your data model with an instance of the NSManagedObject at runtime
        */
        let entity          = NSEntityDescription.entityForName("Transaction", inManagedObjectContext: managedContext)
        let myTransaction   = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        
        // 3: Set the values for "myTransaction"'s attributes
        myTransaction.setValue(title, forKey: "title")
        myTransaction.setValue(cost, forKey: "cost")
        
        
        // 4: Try to commit our changes to myTransaction and save to disk. Then insert the new managed object into the transactions array so it shows up in the table view when it reloads
        do {
            // Try to save the changes, note that it COULD throw an error
            try managedContext.save()
            
            // Add the new transaction to the array
            transactions.append(myTransaction)
        } catch let error as NSError {
            print("Welp. Couldn't save \(error), \(error.userInfo)")
        }
        
    }
    
    
    // ---------------------------------------
    // MARK: UITableViewDataSource Protocol
    // ---------------------------------------
    
    // Setting the number of rows of the table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Set the row count to the number of transactions
        return transactions.count
    }
    
    // Set what will go in each cell (row) of the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue from the "TransactionViewCell" identifier
        let cell = myTableView.dequeueReusableCellWithIdentifier("TransactionViewCell", forIndexPath: indexPath) as! TransactionViewCell
        
        // Store the transaction in our custom cell type "TransactionViewCell"
        cell.thisTransaction = transactions[indexPath.row]
        
        // Grab the "title" out of the Transaction object (of type NSManagedObject)
        cell.title?.text    = cell.thisTransaction?.valueForKey("title") as? String
        
        // Get the "cost" from the transction object (of type NSManagedObject)
        cell.cost?.text     = cell.thisTransaction?.valueForKey("cost") as? String
        
        return cell
    }
    
    // Callback that will allow for cell editing
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // Callback that handles swipe-to actions
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Swipe-to-Delete action
        if (editingStyle == .Delete)
        {
            // Get the transaction that will be deleted
            let transactionToDelete = transactions[indexPath.row]
            
            // Get the managed object context so we can perform work on it
            let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext  = appDelegate.managedObjectContext
            
            // Delete the transaction from the context
            managedContext.deleteObject(transactionToDelete)
            
            // Refresh the table view
            self.fetchTransactions()
            
            // Tell table view to animate out that row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            // Commit the changes to the disk
            do {
                // Try to save the changes, note that it COULD throw an error
                try managedContext.save()
                
            } catch let error as NSError {
                print("Welp. Couldn't save \(error), \(error.userInfo)")
            }
        }
    }
    
    // Function to add more swipe-to options
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // Set up Swipe-to-Edit option
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            print("edit button tapped")
        }
        edit.backgroundColor = UIColor.orangeColor() // set the color
        
        return [edit]
    }
    
    
    // --------------------
    // MARK: Misc
    // --------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

































// -------------------------------------------
// -------------------------------------------
// -------------------------------------------

// TransactionDetailViewController.swift

// -------------------------------------------
// -------------------------------------------
// -------------------------------------------


import UIKit

class BACKUP_TransactionDetailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var costTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Value passed by either 'TransactionTableViewController' in 'prepareForSegue(_:sender:)'
    //  or constructed as prt of adding a new transaction
    var curTransaction: Transaction?
    
    
    // -------------------
    // MARK: Actions
    // -------------------
    
    // "Cancel" Action
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Dismiss transaction scene w/o storing any info.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doSomething(sender: AnyObject) {
        titleLabel.text = "Poop"
    }
    
    
    // ------------------
    // MARK: Navigation
    // ------------------
    
    // Configure a view controller before it's presented
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // "===" Identity Operator - checks if both objects are the same object
        
        // Check that the object referenced by 'saveButton' is the same object instance as 'sender'
        if saveButton === sender {
            let myTitle     = titleTextField.text
            let myCost      = costTextField.text
            
            // This will get passed to 'TransactionTableViewController' after the unwind segue
            curTransaction  = Transaction(title: myTitle!, cost: myCost!)
        }
    }
    
    // ------------------
    // MARK: Callbacks
    // ------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the textfields' delegates to this class (courtesy of the UITextFieldDelegate Protocol)
        // Allows this class to handle user's input from text fields through delegate callbacks
        titleTextField.delegate = self
        costTextField.delegate  = self
        
        
        // Pre-populate the data view if we are editing the transaction (from "EditTransaction" segue)
        if let existingTransaction = curTransaction {
            titleTextField.text = existingTransaction.title
            costTextField.text  = existingTransaction.cost
        }
        
        
        // Make sure "Save" is only enabled if the proper conditions are met (Valid Transaction)
        checkValidTransaction()
    }
    
    
    // -----------------
    // MARK: Protocols
    // -----------------
    
    // MARK: UITextFieldDelegate
    
    // Callback: Called after every new char addition/deletion in the text field
    // Basically allowing for dynamic string checking in the text field
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Since the function passes in the changes to the text field, we must put together the pieces to get the NEW string
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        print(newString.characters.count)
        
        // Check conditions are met for "Saving"
        checkValidTransaction()
        return true
    }
    
    //    // Callback: Called when the text field begins editing
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //        // Disable the Save Button while editing
    //        saveButton.enabled = false
    //    }
    //
    //    // Callback: Called when the text field finishes editing and resigns its first-responder status
    //    func textFieldDidEndEditing(textField: UITextField) {
    //        // After any text field is finished editing, check if the conditions are met to allow "Save"
    //        checkValidTransaction()
    //    }
    //
    //    // Text field should resign first-responder status when the user taps a button to end editing in the text field
    //    func textFieldShouldReturn(textField: UITextField) -> Bool {
    //        // Hides the Keyboard (when resigning first responder status)
    //        textField.resignFirstResponder()
    //
    //        return true
    //    }
    
    
    // -----------------------
    // MARK: Helper Functions
    // -----------------------
    
    // Ensures that the transaction has the MINIMUM REQUIRED values before allowing "Save"
    func checkValidTransaction() {
        // Disable the save button if the transaction title is empty
        let titleText = titleTextField.text ?? ""
        
        saveButton.enabled = !titleText.isEmpty
    }
    
}
































// -------------------------------------------
// -------------------------------------------
// -------------------------------------------

// CTModel.swift

// -------------------------------------------
// -------------------------------------------
// -------------------------------------------


import Foundation

class BACKUP_Transaction {
    // MARK: Transaction Properties
    
    var title: String
    var cost: String
    
    init(title: String, cost: String) {
        self.title  = title
        self.cost   = cost
    }
}


