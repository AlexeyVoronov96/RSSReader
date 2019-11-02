//
//  DataFetcher.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation

class DataFetcher: NSObject, XMLParserDelegate {
    var i: Int = 0
    
    var feed: FeedsList?
    var message: Feed?
    var imgs: [String] = []
    var url: String = ""
    private var currentElement = ""
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentPubDate: String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var currentImageLink: String = "" {
        didSet {
            currentImageLink = currentImageLink.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler: ((Error?) -> Void)?
    
    func getFeed(with url: String, completion: ((Error?) -> Void)?) {
        self.parserCompletionHandler = completion
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request){ [weak self] (data, response, error) in
            guard let self = self else {
                return
            }
            if let error = error {
                self.parserCompletionHandler?(error)
                return
            }
            guard let data = data else {
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
            currentLink = ""
        }
        if currentElement == "enclosure" {
            if let urlString = attributeDict["url"] {
                currentImageLink = urlString
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title": currentTitle += string.html2String
        case "description": currentDescription += string.html2String
        case "pubDate": currentPubDate += string
        case "link": currentLink += string
        case "url": currentImageLink += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" || elementName == "enclosure",
            !CoreDataManager.shared.checkItem(with: currentTitle, description: currentDescription)  {
            Feed.addFeed(title: currentTitle,
                         desc: currentDescription,
                         pubDate: currentPubDate.stringToDate(),
                         link: currentLink,
                         image: currentImageLink,
                         inFeed: feed)
            CoreDataManager.shared.saveContext()
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(nil)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        parserCompletionHandler?(parseError)
    }
    
}
