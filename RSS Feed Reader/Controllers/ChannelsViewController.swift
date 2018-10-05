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
    
    @IBAction func pushAddAction(_ sender: Any) {
        AlertService.addAlert(in: self) { (name, link) in
            let channelsData = Channels(name: name, link: link)
            if link != nil && validateUrl(stringURL: link! as NSString) == true {
                RealmService.shared.create(channelsData)
                self.tableView.reloadData()
            } else {
                var style = ToastStyle()
                style.messageColor = UIColor.white
                style.backgroundColor = UIColor.init(red: 66/255, green: 139/255, blue: 202/255, alpha: 1)
                self.view.makeToast("Неверный URL", position: .bottom, style: style)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count != 0{
            return items.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelsTableViewCell
        let currentItem = items[indexPath.row]
        cell.configure(with: currentItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
            let item = self.items[indexPath.row]
            RealmService.shared.delete(item)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Изменить") { (action, indexPath) in
            let currentItem = self.items[indexPath.row]
            AlertService.updateAlert(in: self, channelsData: currentItem) { (name, link) in
                let dict: [String: Any?] = ["name": name,
                                            "link": link]
                RealmService.shared.update(currentItem, with: dict)
                self.tableView.reloadData()
            }
        }
        edit.backgroundColor = UIColor.init(red: 66/255, green: 139/255, blue: 202/255, alpha: 1)
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFeed" {
            if let cell = sender as? ChannelsTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let destination = segue.destination as! FeedViewController
                let currentItem = items[indexPath.row]
                destination.url = currentItem.link
                print(currentItem.link!)
                destination.name = currentItem.name
            }
        }
    }
    
}
