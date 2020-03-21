//
//  ListViewController.swift
//  TodoList
//
//  Created by Macbook Pro on 3/18/20.
//  Copyright © 2020 Galaxy. All rights reserved.
//

import UIKit
import CoreData
class ListViewController: UITableViewController {

    var categoryList = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        setupLongPressGesture()
    }
    //MARK: tableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath)
        cell.textLabel?.text = categoryList[indexPath.row].name
        cell.accessoryType = categoryList[indexPath.row].done ? .checkmark : .none
       
        return cell
    }
    //MARK: tableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TodoItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoItemsController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.setCategory = categoryList[indexPath.row]
        }
       
     }
    //MARK: Long pressed
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                categoryList[indexPath.row].done = !categoryList[indexPath.row].done
                saveCategory()
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
 

    //MARK: Add new Category

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.done = false
            
            self.categoryList.append(newCategory)
            
            self.saveCategory()
            print("Success!")
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create something new"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: Extension function
    func loadCategory(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do{
            categoryList = try context.fetch(request)
            
        }catch{
            print("Error fetching data from CoreData \(error)")
        }
    }
    func saveCategory(){
    do{
        try context.save()
        }catch{
        print("Error saving data to CoreData \(error)")
        }
        tableView.reloadData()
    }
    
}
