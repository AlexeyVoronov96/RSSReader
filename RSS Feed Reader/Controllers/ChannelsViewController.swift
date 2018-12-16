//
//  ChannelsViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController {
    
    static let shared = ChannelsViewController()
    
    @IBOutlet weak var tableView: UITableView!
    var feed: FeedsList?
    var toast: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Colors.sharedInstance.blue
    }
    
    @IBAction func closeSlideMenu(_ sender: Any) {
        ContainerViewController.shared.sideMenuOpen = true
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    @IBAction func pushAddAction(_ sender: Any) {
        AlertService.addAlert(in: self) { (name, link) in
            DispatchQueue.main.async {
                guard link != nil else {
                    self.makeToast(toast: "URL field is empty")
                    return
                }
                guard  validateUrl(stringURL: link! as NSString) else {
                    self.makeToast(toast: "Invalide URL")
                    return
                }
                guard channels.index(where: { ($0.link! == link) }) == nil else {
                    self.toast = "Channel already exists".localize()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toast"), object: self.toast)
                    NotificationCenter.default.post(name: NSNotification.Name("showToast"), object: nil)
                    return
                }
                if name != nil {
                    _ = FeedsList.newFeed(name: name!, link: link!)
                } else {
                    _ = FeedsList.newFeed(name: "Unnamed channel".localize(), link: link!)
                }
                CoreDataManager.sharedInstance.saveContext()
                self.tableView.reloadData()
            }
        }
    }
    
}

extension ChannelsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let currentChannel = channels[indexPath.row]
        let delete = UITableViewRowAction(style: .destructive, title: "Delete".localize()) { (action, indexPath) in
            CoreDataManager.sharedInstance.managedObjectContext.delete(currentChannel)
            CoreDataManager.sharedInstance.saveContext()
            if FeedViewController.shared.url == currentChannel.link {
                NotificationCenter.default.post(name: NSNotification.Name("deleteChannel"), object: nil)
            }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Change".localize()) { (action, indexPath) in
            AlertService.updateAlert(in: self, channelsData: currentChannel) { (name, link) in
                guard link != nil else {
                    self.makeToast(toast: "URL field is empty")
                    return
                }
                guard  validateUrl(stringURL: link! as NSString) else {
                    self.makeToast(toast: "Invalide URL")
                    return
                }
                if name != nil {
                    currentChannel.name = name
                } else {
                    currentChannel.name = "Unnamed channel".localize()
                }
                currentChannel.link = link
                CoreDataManager.sharedInstance.saveContext()
                self.tableView.reloadData()
            }
        }
        edit.backgroundColor = Colors.sharedInstance.blue
        delete.backgroundColor = Colors.sharedInstance.blue
        return [delete, edit]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentChannel = channels[indexPath.row]
        
        let delete =  UIContextualAction(style: .destructive, title: "Delete".localize(), handler: { (action,view,completionHandler ) in
            CoreDataManager.sharedInstance.managedObjectContext.delete(currentChannel)
            CoreDataManager.sharedInstance.saveContext()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            if FeedViewController.shared.url == currentChannel.link {
                NotificationCenter.default.post(name: NSNotification.Name("deleteChannel"), object: nil)
            }
            completionHandler(true)
        })
        
        let edit = UIContextualAction(style: .normal, title: "Change".localize(), handler: { (action,view,completionHandler ) in
            AlertService.updateAlert(in: self, channelsData: currentChannel) { (name, link) in
                guard link != nil else {
                    self.makeToast(toast: "URL field is empty")
                    return
                }
                guard  validateUrl(stringURL: link! as NSString) else {
                    self.makeToast(toast: "Invalide URL")
                    return
                }
                if name != nil {
                    currentChannel.name = name
                } else {
                    currentChannel.name = "Unnamed channel".localize()
                }
                currentChannel.link = link
                CoreDataManager.sharedInstance.saveContext()
                self.tableView.reloadData()
            }
            completionHandler(true)
        })
        edit.image = UIImage(named: "edit")
        edit.backgroundColor = Colors.sharedInstance.blue
        delete.image = UIImage(named: "delete")
        delete.backgroundColor = Colors.sharedInstance.blue
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

extension ChannelsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard channels.count != 0 else {
            return 0
        }
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelsTableViewCell
        let currentChannel = channels[indexPath.row]
        cell.configure(with: currentChannel)
        return cell
    }
    
}
