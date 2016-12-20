//
//  News.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/11.
//
//

import Foundation

struct News {
    
    var date: String
    var stories: [Story]
    var topStories: [Story]?
    
    //格式化日期
    var formatDate: String {
        let yearIndex = date.index(date.startIndex, offsetBy: 4)
        let dayIndex = date.index(date.endIndex, offsetBy: -2)
        let monthRange = yearIndex ..< dayIndex
        
        let month = date.substring(with: monthRange)
        let day = date.substring(from: dayIndex)
        
        return "\(month)月\(day)日 \(date.getWeekDay())"
        
    }
    
    //URL
    static var latestNewsURL: URL {
        return URL(string: "https://news-at.zhihu.com/api/4/news/latest")!
    }
    var previousNewsURL: URL {
        return URL(string: "https://news-at.zhihu.com/api/4/news/before/\(date)")!
    }
    
    
}



// MARK: - JSON 转模型
extension News {
    
    static func parse(json: JSONDictionary) -> News {
        
        guard let date = json["date"] as? String else {
            fatalError("Expected date String")

        }
        
        guard let storiesDicts = json["stories"] as? [JSONDictionary] else {
            fatalError("Expected stories JSONDictionary")

        }
        
        let stories = storiesDicts.map { (json) -> Story in
            return Story.parse(json: json)
        }
        

        var topStories: [Story]?
        if let topStoriesDicts = json["top_stories"] as? [JSONDictionary]{
            
            topStories = topStoriesDicts.map { (json) -> Story in
                return Story.parse(json: json)
            }
            
        }
        
        
        return News(date: date, stories: stories, topStories: topStories)
    }
    
    
}
