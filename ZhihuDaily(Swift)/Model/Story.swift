//
//  Story.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/11.
//
//

import UIKit
struct Story {
    
    var id: Int
    var title: String
    var urlString: String
    var url: URL {
        return URL(string: urlString.replacingOccurrences(of: "http", with: "https"))!//http 转https
    }
    
}



// MARK: - 字典转模型
extension Story {

    static func parse(json: JSONDictionary) -> Story {
        
        guard let id = json["id"] as? Int else {
            fatalError("Expected id Int")
        }
        
        guard let title = json["title"] as? String else {
            fatalError("Expected title String")

        }
        
        guard let urlString = (json["images"] as? [String])?.first ?? json["image"] as? String else {
            fatalError("Expected images/image  [String]/String")

        }
        
        return Story(id: id, title: title, urlString: urlString)
    }
    
}
