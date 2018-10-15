//
//  ChannelsViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
import UIKit
import RealmSwift
import Toast_Swift

class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var realm: Realm!
    var items: Results<Channels>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        items = realm.objects(Channels.self)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
    }
    
    @IBAction func pushEditAction(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing,
                             animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func pushAddAction(_ sender: Any) {
        AlertService.addAlert(in: self) { (name, link) in
            let channelsData = Channels(name: name, link: link)
            DispatchQueue.main.async {
                if link != nil && validateUrl(stringURL: link! as NSString) == true {
                    RealmService.shared.create(channelsData)
                    self.tableView.reloadData()
                } else {
                    self.view.makeToast("Неверный URL",
                                        duration: 3.0,
                                        position: .bottom)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if items.count != 0{
            return items.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelsTableViewCell
        let currentItem = items[indexPath.row]
        cell.configure(with: currentItem)
        if tableView.isEditing {
            cell.labelName.alpha = 0.4
            cell.labelLink.alpha = 0.4
        } else {
            cell.labelName.alpha = 1
            cell.labelLink.alpha = 1
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView,
                   moveRowAt fromIndexPath: IndexPath,
                             to: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
            let item = self.items[indexPath.row]
            RealmService.shared.delete(item)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let edit = UITableViewRowAction(style: .normal,
                                        title: "Изменить") { (action, indexPath) in
            let currentItem = self.items[indexPath.row]
            AlertService.updateAlert(in: self, channelsData: currentItem) { (name, link) in
                if link != nil && validateUrl(stringURL: link! as NSString) == true {
                let dict: [String: Any?] = ["name": name,
                                            "link": link]
                RealmService.shared.update(currentItem,
                                           with: dict)
                self.tableView.reloadData()
                } else {
                    self.view.makeToast("Неверный URL",
                                        duration: 3.0,
                                        position: .bottom)
                }
            }
        }
        edit.backgroundColor = UIColor.init(red: 66/255,
                                            green: 139/255,
                                            blue: 202/255,
                                            alpha: 1)
        delete.backgroundColor = UIColor.init(red: 239/255,
                                              green: 101/255,
                                              blue: 101/255,
                                              alpha: 1)
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        let destination = FeedViewController()
        let currentItem = items[indexPath.row]
        destination.url = currentItem.link
        print(currentItem.link!)
        destination.name = currentItem.name
        if currentItem.name == nil {
            let dictionary = ["name": "Лента новостей",
                              "link": currentItem.link!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"),
                                            object: nil,
                                            userInfo: dictionary)
            UserDefaults.standard.set(currentItem.link!,
                                      forKey: "link")
            UserDefaults.standard.set("Лента новостей",
                                      forKey: "name")
        } else {
            let dictionary = ["name": currentItem.name!,
                              "link": currentItem.link!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"),
                                            object: nil,
                                            userInfo: dictionary)
            UserDefaults.standard.set(currentItem.link!,
                                      forKey: "link")
            UserDefaults.standard.set(currentItem.name!,
                                      forKey: "name")
        }
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                            object: nil)
    }
    
}
