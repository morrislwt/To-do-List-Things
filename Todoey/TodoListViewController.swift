//
//  ViewController.swift
//  Todoey
//
//  Created by Morris on 2018/4/3.
//  Copyright © 2018年 Morris. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    
    
    var selectedCategoty : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.barTintColor = UIColor(hexString: "00649F")
        searchBar.isTranslucent = true
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        if let title = selectedCategoty?.name {
            navigationItem.title = title
        }
    }
    //MARK : TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
//            if let color = FlatYellow().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = UIColor(hexString: "E6AF2E")
//                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.textLabel?.font = UIFont(name: "Courier", size: 20)
                
                
        }else{
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
    


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        ///try to delete item
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        ///the order matters a huge deal
//        saveItems()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    //MARK : add new item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New To-do List", message: "", preferredStyle: .alert)
        
        //add the button when the alertsheet pop up
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            if textField.text != "" {
            if let currentCategory = self.selectedCategoty {
                
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new Item \(error)")
                }
            }
            self.tableView.reloadData()
            }else{
                let blankAlert = UIAlertController(title: "To-do list can't be empty", message: "", preferredStyle: .actionSheet)
                let gotItAction = UIAlertAction(title: "Got it", style: .default, handler: { (gotItAction) in
                    self.present(alert,animated: true,completion: nil)
                })
                blankAlert.addAction(gotItAction)
                self.present(blankAlert,animated: true,completion: nil)
            }

        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField

        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        alert.addAction(action)
    }
//    func saveItems(item:Item){
//        tableView.reloadData()
////        do{
////            try context.save()
////        }catch{
////            print("Error saving context\(error.localizedDescription)")
////        }
//
//        //use userdefault to save what you added
//        //            self.defaults.set(self.itemArray, forKey: "todolistarray")
//        //remember reload to show new item
//
//    }
    func loadItems(){
        
        todoItems = selectedCategoty?.items.sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            deleteModel(itemForDelete: itemForDeletion)
        }
    }
    override func editModel(at indexPath: IndexPath) {
        if let toDoItemForEdit = todoItems?[indexPath.row].title {
            var editText = UITextField()
            
            let alert = UIAlertController(title: "Edit", message: "Change the name", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = toDoItemForEdit
                editText = textField
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            let saveAction = UIAlertAction(title: "Save", style: .default) { (saveAction) in
                if editText.text != "" {
                
                do{
                    try self.realm.write {
                        self.todoItems?[indexPath.row].title = editText.text!
                    }
                }catch{
                    print("Error editing Category \(error)")
                }
                self.tableView.reloadData()
                }else{
                    let blankAlert = UIAlertController(title: "Need some text to change title", message: "", preferredStyle: .actionSheet)
                    let gotItAction = UIAlertAction(title: "Got it", style: .default, handler: { (gotItAction) in
                        self.present(alert,animated: true,completion: nil)
                    })
                    blankAlert.addAction(gotItAction)
                    self.present(blankAlert,animated: true,completion: nil)
                }
            }
            alert.addAction(saveAction)
            present(alert,animated: true, completion: nil)
        }
    }
}

//MARK: - Search bar methods
extension TodoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        ////若是true 最新的排在最下面
        animateTable()
    }
//        let dataRequest:NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        dataRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
////        do{
////            itemArray = try context.fetch(dataRequest)
////        }catch{
////            print("Error fetching data from context \(error)")
////        }
//        ///重複的就用func來代替
//        loadItems(with: dataRequest, predicate: predicate)
//        tableView.reloadData()
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            animateTable()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

