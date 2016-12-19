//
//  AppDelegate.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/9.
//
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var controllerPush: ControllerPush?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        if let window = window {
            controllerPush = ControllerPush(window: window)
        }
        
        //启动动画
        setupLaunchImage()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


// MARK: - Launcher Image
extension AppDelegate {
    
    func setupLaunchImage() {
        
        if let LaunchImageData = UserDefaults.standard.data(forKey: "LaunchImage") {
            let launchImageView = UIImageView(frame: UIScreen.main.bounds)
            launchImageView.backgroundColor = UIColor.white
            window?.addSubview(launchImageView)
            launchImageView.image = UIImage(data: LaunchImageData)
            UIView.animate(withDuration: 2, animations: {
                
                launchImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                launchImageView.alpha = 0
                
            }, completion: { (_) in
                
                launchImageView.removeFromSuperview()
                
            })

        }
        
        downLaunchImage()
        
    }
    
    
    func downLaunchImage() {
        
        //获取json
        let url = URL(string: "https://news-at.zhihu.com/api/4/start-image/1080*1776")!
        request(url).responseJSON { (jsonResponse) in
            switch jsonResponse.result {
                
            case .success(let json as [String : AnyObject]):
                guard let imgURLString = json["img"] as? String,
                    let imgURL = URL(string: imgURLString) else {
                        fatalError()
                }
                
                //下载图片
                request(imgURL).responseData(completionHandler: { (dataResponse) in
                    switch dataResponse.result {
                        
                    case .success(let data):
                        UserDefaults.standard.set(data, forKey: "LaunchImage")
                        
                    case .failure(let error):
                        print(error)
                    }
                })
                
            
            case .failure(let error):
                print(error)
                
            default : break
            }
            
        }
        
    }
    
    
    
}
