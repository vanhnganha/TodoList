//
//  ToDoItemsController.swift
//  TodoList
//
//  Created by Macbook Pro on 3/21/20.
//  Copyright © 2020 Galaxy. All rights reserved.
//

import UIKit
import CoreData
class ToDoItemsController: UITableViewController{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var setCategory: Category?{
    didSet{
        loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("load view")
  
        
    }
    //MARK: Add ITEM BUTTON
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController.init(title: "Add new Item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction.init(title: "Add", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text
            newItem.done = false
            newItem.parentCategory = self.setCategory
            self.itemArray.append(newItem)
            self.saveItem()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    //MARK: TableView Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    // MARK: TABLEVIEW DELEGATE
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         itemArray[indexPath.row].done = !itemArray[indexPath.row].done
               saveItem()
               tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: LOAD AND SAVE ITEMS
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(),
                   predicate: NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@" , setCategory!.name!)
        if let additionPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionPredicate])
            print(request.predicate!)
        }else {
            request.predicate = categoryPredicate
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching data \(error)")
        }
        tableView.reloadData()
    }
    func saveItem(){
        do {
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
        tableView.reloadData()
    }

   
    
   
}
extension ToDoItemsController: UISearchBarDelegate {
    //MARK: SearchBarDelegate
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            print("Hi, can your hear me?")
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            print(searchBar.text!)
            let sort = NSSortDescriptor(key: "title", ascending: true)
            
            request.sortDescriptors = [sort]
            loadItems(with: request, predicate: predicate)
            
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0 {
            loadItems()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
}


