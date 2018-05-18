//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Morris on 2018/4/23.
//  Copyright © 2018年 Morris. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categoryArray:Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        searchBar.barTintColor = UIColor(hexString: "00649F")
        searchBar.isTranslucent = false
        
        
    }
    
    
    
    //Mark: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories add yet"
        cell.backgroundColor = UIColor(hexString: "D3D6DB")
        
//        cell.textLabel?.textColor = ContrastColorOf(.flatOrange, returnFlat: true)
        cell.textLabel?.font = UIFont(name: "Courier", size: 20)
//        cell.backgroundColor = UIColor(randomColorIn: [.flatOrange,.flatYellow,])
//        if let color = RandomFlatColor().lighten(byPercentage: CGFloat(indexPath.row) / CGFloat(categoryArray!.count)) {
//            cell.backgroundColor = color
//            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
//        }
        return cell
    }


    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategoty = categoryArray?[indexPath.row]
        }
    }

    //MARK: - Data Manipulation Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Things", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Creat new category"
            textField = alertTextField
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text != "" {
            let newCategory = Category()
            newCategory.name = textField.text!
            //auto update, so no need append
//            self.categoryArray.append(newCategory)
            self.save(category: newCategory)
            }else{
                let blankAlert = UIAlertController(title: "Category can't be empty", message: "", preferredStyle: .actionSheet)
                let gotItAction = UIAlertAction(title: "Got it", style: .default, handler: { (gotItAction) in
                    self.present(alert,animated: true,completion: nil)
                })
                blankAlert.addAction(gotItAction)
                self.present(blankAlert,animated: true,completion: nil)
            }
        }
        
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
        
    }
    

    func save(category:Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving Category context \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    
    func loadCategory(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }

    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            deleteModel(itemForDelete: categoryForDeletion)
        }
    }
    override func editModel(at indexPath: IndexPath) {
        if let categoryForEdit = categoryArray?[indexPath.row].name{
            var editText = UITextField()
            
            let alert = UIAlertController(title: "Edit", message: "Change the name of this Category", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = categoryForEdit
                editText = textField
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            let saveAction = UIAlertAction(title: "Save", style: .default) { (saveAction) in
                if editText.text != "" {
                
                do{
                    try self.realm.write {
                        self.categoryArray?[indexPath.row].name = editText.text!
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

extension CategoryViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categoryArray = categoryArray?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        animateTable()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadCategory()
            animateTable()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}





