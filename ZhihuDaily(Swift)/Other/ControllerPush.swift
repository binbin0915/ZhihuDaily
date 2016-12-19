//
//  ControllerPush.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/19.
//
//

import UIKit

struct ControllerPush {
    
    let mainNavigationVC: UINavigationController
    
    init(window: UIWindow) {
        
        mainNavigationVC = window.rootViewController as! UINavigationController
        let mainVC = mainNavigationVC.viewControllers[0] as! MainViewController
        mainVC.selectStory = showStory
        
    }
    
    func showStory(story: Story) {
        
        mainNavigationVC.pushViewController(UIStoryboard(name: "Detail", bundle: nil).instantiateInitialViewController()!, animated: true)
        
    }
    
}

