//
//  ChannelsViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import SystemConfiguration

class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func pushEditAction(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func pushAddAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Добавить новый канал", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField1) in
            textField1.placeholder = "Введите название канала"
        }
        
        alertController.addTextField { (textField2) in
            textField2.placeholder = "Введите ссылку на канал"
        }
        
        let alertAction1 = UIAlertAction(title: "Отмена", style: .destructive) { (alert) in
            
        }
        
        let alertAction2 = UIAlertAction(title: "Добавить", style: .cancel) { (alert) in
            let newItem = alertController.textFields![0].text
            let newItem2 = alertController.textFields![1].text
            if (newItem2 != ""){
            addItem(nameItem: newItem!, linkItem: newItem2!)
            self.tableView.reloadData()
            }
        }
        
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ToAddLinks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelsTableViewCell
        
        
        let currentItem = ToAddLinks[indexPath.row]
        cell.labelName.text = currentItem["Name"] as? String
        cell.labelLink.text = currentItem["Link"] as? String
        if tableView.isEditing {
            cell.labelName?.alpha = 0.4
            cell.labelLink?.alpha = 0.4
        } else {
            cell.labelName?.alpha = 1
            cell.labelLink?.alpha = 1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            let currentItem = ToAddLinks[indexPath.row]
            let alertController = UIAlertController(title: "Изменить канал", message: nil, preferredStyle: .alert)
            
            alertController.addTextField { (textField1) in
                textField1.text = (currentItem["Name"]) as? String
                textField1.placeholder = "Введите название канала"
            }
            
            alertController.addTextField { (textField2) in
                textField2.text = (currentItem["Link"]) as? String
                textField2.placeholder = "Введите ссылку на канал"
            }
            
            let alertAction1 = UIAlertAction(title: "Отмена", style: .destructive) { (alert) in
                
            }
            
            let alertAction2 = UIAlertAction(title: "Изменить", style: .cancel) { (alert) in
                let newItem = alertController.textFields![0].text
                let newItem2 = alertController.textFields![1].text
                renameItem(nameItem: newItem!, linkItem: newItem2!, at: indexPath.row)
                self.tableView.reloadData()
            }
            
            alertController.addAction(alertAction1)
            alertController.addAction(alertAction2)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            let currentItem = ToAddLinks[indexPath.row]
            let newsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "news") as! NewsViewController
            newsVC.url = (currentItem["Link"]) as? String
            newsVC.name = (currentItem["Name"]) as? String
            self.present(newsVC, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        moveItem(fromIndex: fromIndexPath.row, toIndex: to.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .insert
        } else {
            return .delete
        }
        
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
