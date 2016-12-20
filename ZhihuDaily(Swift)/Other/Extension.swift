//
//  Extension.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/19.
//
//

import UIKit

//json字典别名
typealias JSONDictionary = [String : AnyObject]


extension UIColor {
    
    static var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(255))/255.0, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1)
    }
    
}


extension String {
    
    //根据宽度、字体，计算文本高度
    func getTextHeight(textWidth: CGFloat, font: UIFont) -> CGFloat {
        
        let text = self as NSString
        let attributes = [NSFontAttributeName: font]
        
        let rect = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return rect.height
    }
    
    
    //获取星期几 针对东八区
    func getWeekDay() -> String{
        
        let weeks = ["星期天", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyyMMdd"
        let date = dateFmt.date(from: self)
        let interval = Int(date!.timeIntervalSince1970) + 24*60*60*8 //+8小时
        let days = Int(interval/(24*60*60))
        let weekday = ((days + 4)%7+7)%7
        
        return weeks[weekday]
        
    }
    
}
