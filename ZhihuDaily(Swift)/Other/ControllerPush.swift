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
    let mainVC: MainViewController
    
    init(window: UIWindow) {
        
        mainNavigationVC = window.rootViewController as! UINavigationController
        mainVC = mainNavigationVC.viewControllers[0] as! MainViewController
        mainVC.selectStory = showStory
        
    }
    
    func showStory(story: Story) {
        
        let detailVC = UIStoryboard(name: "Detail", bundle: nil).instantiateInitialViewController() as! DetailViewController
        detailVC.story = story
        mainNavigationVC.pushViewController(detailVC, animated: true)
        
    }
    
}

