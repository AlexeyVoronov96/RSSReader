//
//  FeedItemsFetcher.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation

class FeedItemsFetcher: NSObject {
    enum Errors: LocalizedError {
        case internalInconsistency
        
        var errorDescription: String? {
            return "Something goes wrong...".localize()
        }
    }
    private let networkWorker = NetworkWorker()
    
    var feed: Feed?
    
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
    
    func getFeed(with urlString: String, completion: @escaping ((Error?) -> Void)) {
        networkWorker.getData(with: URL(string: urlString)) { [weak self] (result) in
            guard let self = self else {
                completion(Errors.internalInconsistency)
                return
            }
            
            switch result {
            case let .success(data):
                self.parserCompletionHandler = completion
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
                
            case let .failure(error):
                completion(error)
            }
        }
    }
}

extension FeedItemsFetcher: XMLParserDelegate {
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
            FeedMessage.addFeed(title: currentTitle,
                         desc: currentDescription,
                         pubDate: currentPubDate.stringToDate(),
                         link: currentLink,
                         image: currentImageLink,
                         feed: feed)
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
