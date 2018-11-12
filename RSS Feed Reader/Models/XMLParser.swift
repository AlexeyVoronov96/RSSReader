//
//  XMLParser.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation

struct RSSItem {
    var title: String
    var description: String
    var pubDate: String
    var link: String
}

class FeedParser: NSObject, XMLParserDelegate {
    
    static let parse = FeedParser()
    
    var i: Int = 0
    
    private var rssItems: [RSSItem] = []
    var feed: FeedsList?
    var message: Feed?
    var imgs: [String] = []
    var url: String = ""
    private var currentElement = ""
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler: (([RSSItem]) -> Void)?
    
    func parseFeed(url: String, completionHandler: (([RSSItem]) -> Void)?) {
        DispatchQueue.global().async {
            self.parserCompletionHandler = completionHandler
            let request = URLRequest(url: URL(string: url)!)
            let urlSession = URLSession.shared
            let task = urlSession.dataTask(with: request){  (data, response, error) in
                guard let data = data else {
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    return
                }
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
            task.resume()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
            currentLink = ""
            if self.imgs.count != self.rssItems.count {
                self.imgs.append("")
            }
        }
        if currentElement == "enclosure" {
            if let urlString = attributeDict["url"] {
                imgs.append(urlString as String)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title": currentTitle += string.html2String
        case "description": currentDescription += string.html2String
        case "pubDate": currentPubDate += string
        case "link": currentLink += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            DispatchQueue.main.sync {
                let rssItem = RSSItem(title: self.currentTitle, description: self.currentDescription, pubDate: self.currentPubDate, link: self.currentLink)
                self.rssItems.append(rssItem)
                _ = Feed.addFeed(title: self.currentTitle, desc: self.currentDescription, pubDate: self.currentPubDate, link: self.currentLink, inFeed: self.feed)
                CoreDataManager.sharedInstance.saveContext()
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItems)
    }
    
    func parser(_ parser: XMLParser,
                parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
}
