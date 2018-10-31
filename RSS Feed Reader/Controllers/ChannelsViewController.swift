//
//  ChannelsViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
import UIKit

class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let channelsController = ChannelsViewController()
    
    @IBOutlet weak var tableView: UITableView!
    var feed: FeedsList?
    var toast: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Colors.color.blue
    }
    
    @IBAction func closeSlideMenu(_ sender: Any) {
        ContainerViewController.containerController.sideMenuOpen = true
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    @IBAction func pushAddAction(_ sender: Any) {
        AlertService.addAlert(in: self) { (name, link) in
            DispatchQueue.main.async {
                if link != nil && validateUrl(stringURL: link! as NSString) == true {
                    if channels.index(where: { ($0.link! == link) }) == nil {
                        if name != nil {
                            _ = FeedsList.newFeed(name: name!, link: link!)
                        } else {
                            _ = FeedsList.newFeed(name: "Unnamed channel".localize(), link: link!)
                        }
                        CoreDataManager.sharedInstance.saveContext()
                        self.tableView.reloadData()
                    } else {
                        self.toast = "Channel already exists"
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toast"), object: self.toast)
                        NotificationCenter.default.post(name: NSNotification.Name("showToast"), object: nil)
                    }
                } else {
                    self.toast = "Invalide URL"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toast"), object: self.toast)
                    NotificationCenter.default.post(name: NSNotification.Name("showToast"), object: nil)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if channels.count != 0{
            return channels.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelsTableViewCell
        let currentChannel = channels[indexPath.row]
        cell.configure(with: currentChannel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let currentChannel = channels[indexPath.row]
        let delete = UITableViewRowAction(style: .destructive, title: "Delete".localize()) { (action, indexPath) in
            CoreDataManager.sharedInstance.managedObjectContext.delete(currentChannel)
            CoreDataManager.sharedInstance.saveContext()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }

        let edit = UITableViewRowAction(style: .normal, title: "Change".localize()) { (action, indexPath) in
            AlertService.updateAlert(in: self, channelsData: currentChannel) { (name, link) in
                if link != nil && validateUrl(stringURL: link! as NSString) == true {
                    if name != nil {
                        currentChannel.name = name
                    } else {
                        currentChannel.name = "Unnamed channel".localize()
                    }
                    currentChannel.link = link
                    CoreDataManager.sharedInstance.saveContext()
                    self.tableView.reloadData()
                } else {
                    self.toast = "Invalide URL"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toast"), object: self.toast)
                    NotificationCenter.default.post(name: NSNotification.Name("showToast"), object: nil)
                }
            }
        }
        edit.backgroundColor = Colors.color.blue
        delete.backgroundColor = Colors.color.blue
        return [delete, edit]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentChannel = channels[indexPath.row]
        
        let delete =  UIContextualAction(style: .destructive, title: "Delete".localize(), handler: { (action,view,completionHandler ) in
            CoreDataManager.sharedInstance.managedObjectContext.delete(currentChannel)
            CoreDataManager.sharedInstance.saveContext()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            NotificationCenter.default.post(name: NSNotification.Name("deleteChannel"), object: nil)
            completionHandler(true)
        })
        
        let edit = UIContextualAction(style: .normal, title: "Change".localize(), handler: { (action,view,completionHandler ) in
            AlertService.updateAlert(in: self, channelsData: currentChannel) { (name, link) in
                if link != nil && validateUrl(stringURL: link! as NSString) == true {
                    if name != nil {
                        currentChannel.name = name
                    } else {
                        currentChannel.name = "Unnamed channel".localize()
                    }
                    currentChannel.link = link
                    CoreDataManager.sharedInstance.saveContext()
                    self.tableView.reloadData()
                } else {
                    self.toast = "Invalide URL"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toast"), object: self.toast)
                    NotificationCenter.default.post(name: NSNotification.Name("showToast"), object: nil)
                }
            }
            completionHandler(true)
        })
        edit.image = UIImage(named: "edit")
        edit.backgroundColor = Colors.color.blue
        delete.image = UIImage(named: "delete")
        delete.backgroundColor = Colors.color.blue
        let confrigation = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return confrigation
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentChannel = channels[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentChannel"), object: currentChannel)
        let dictionary = ["name": currentChannel.name!, "link": currentChannel.link!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendChannelStats"), object: nil, userInfo: dictionary)
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
}
