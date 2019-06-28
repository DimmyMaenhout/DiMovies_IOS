import Foundation
import UIKit
import RealmSwift

class AddCollectionViewController: UITableViewController {
    
    private var user: User!
    var collection: Collection?
    
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var collectionNameField: UITextField!
    
    override func viewDidLoad() {
        
        let realm = try! Realm()
        user = try! realm.objects(User.self)[0]
        collectionNameField.becomeFirstResponder()
        //Mark: From UIViewController extension
        self.hideKeyBoardOnTap()
        
    }
    
    @IBAction func saveCollection() {
        
        if collection == nil {
            performSegue(withIdentifier: Constants.didAddCollectionSegue, sender: self)
        }
    }
    
    @IBAction func hideKeyboard(_ sender: UITextField) {
        
        sender.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case Constants.didAddCollectionSegue:
            if let collectionName = collectionNameField.text {
                collection = Collection(name: collectionName)
            }
        default:
            fatalError(Constants.unknownSegue)
        }
    }
    
}

extension AddCollectionViewController: UITextFieldDelegate {
    //MARK: The text field calls this method whenever user actions cause its text to change.
    //MARK: Use this method to validate text as it is typed by the user. For example,
    //MARK: you could use this method to prevent the user from entering anything but numerical values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text {
            let oldText = text as NSString
            let newText = oldText.replacingCharacters(in: range, with: string)
            saveButton.isEnabled = newText.count > 0
        }
        else {
            saveButton.isEnabled = string.count > 0
        }
        //MARK: True if the specified text range should be replaced; otherwise, false to keep the old text.
        return true
    }
}
