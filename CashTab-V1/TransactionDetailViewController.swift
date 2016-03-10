//
//  TransactionDetailViewController.swift
//  CashTab-V1
//
//  Created by Kevin Tsui on 2/23/16.
//  Copyright © 2016 Kevin Tsui. All rights reserved.
//

import UIKit

class TransactionDetailViewController: UIViewController, UITextFieldDelegate {
    
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

