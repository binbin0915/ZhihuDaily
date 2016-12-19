//
//  Extension.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/19.
//
//

import UIKit

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
    
}
