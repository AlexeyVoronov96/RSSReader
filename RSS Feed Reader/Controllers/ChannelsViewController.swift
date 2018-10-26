//
//  ChannelsViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
import UIKit
import Toast_Swift

class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var feed: FeedsList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
    }
    
    @IBAction func closeSlideMenu(_ sender: Any) {
        ContainerViewController().sideMenuOpen = true
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                        object: nil)
    }
    
    @IBAction func pushAddAction(_ sender: Any) {
        AlertService.addAlert(in: self) { (name, link) in
            DispatchQueue.main.async {
                if link != nil && validateUrl(stringURL: link! as NSString) == true {
                    _ = FeedsList.newFeed(name: name!, link: link!)
                    CoreDataManager.sharedInstance.saveContext()
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
        if channels.count != 0{
            return channels.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelsTableViewCell
        let currentChannel = channels[indexPath.row]
        cell.configure(with: currentChannel)
        return cell
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
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let currentChannel = channels[indexPath.row]
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
            CoreDataManager.sharedInstance.managedObjectContext.delete(currentChannel)
            CoreDataManager.sharedInstance.saveContext()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }

        let edit = UITableViewRowAction(style: .normal,
                                        title: "Изменить") { (action, indexPath) in
            AlertService.updateAlert(in: self, channelsData: currentChannel) { (name, link) in
                if link != nil && validateUrl(stringURL: link! as NSString) == true {
                    currentChannel.name = name
                    currentChannel.link = link
                    CoreDataManager.sharedInstance.saveContext()
                    self.tableView.reloadData()
                } else {
                    self.view.makeToast("Неверный URL",
                                        duration: 3.0,
                                        position: .bottom)
                }
            }
        }
        edit.backgroundColor = Colors().blue
        delete.backgroundColor = Colors().red
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        let currentChannel = channels[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentChannel"),
                                        object: currentChannel)
        if currentChannel.name == nil {
            let dictionary = ["name": "Лента новостей",
                              "link": currentChannel.link!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"),
                                            object: nil,
                                            userInfo: dictionary)
            UserDefaults.standard.set(currentChannel.link!,
                                      forKey: "link")
            UserDefaults.standard.set("Лента новостей",
                                      forKey: "name")
        } else {
            let dictionary = ["name": currentChannel.name!,
                              "link": currentChannel.link!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"),
                                            object: nil,
                                            userInfo: dictionary)
            UserDefaults.standard.set(currentChannel.link!,
                                      forKey: "link")
            UserDefaults.standard.set(currentChannel.name!,
                                      forKey: "name")
        }
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                            object: nil)
    }
    
}
