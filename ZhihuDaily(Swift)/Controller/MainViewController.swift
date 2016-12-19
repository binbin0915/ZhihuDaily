//
//  MainViewController.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/9.
//
//

import UIKit
import Alamofire
import AlamofireImage

class MainViewController: UITableViewController {

    @IBOutlet weak var bannerView: BannerView!
    let bannerViewHeight: CGFloat = 200
    
    var navigationBarAlpha: CGFloat {
        return tableView.contentOffset.y / (bannerViewHeight - 64)
    }
    
    var news = [News]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                //局部刷新tableView
                self?.tableView.insertSections(IndexSet(integer: (self?.news.count)! - 1), with: .top)
                
            }
        }
    }
    
    //BannerData
    var topStories = [Story]() {
        didSet {
            bannerView.topStories = topStories
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        loadLatestNews()
        
    }

}


// MARK: - setup
extension MainViewController {
    
    fileprivate func setupNavigationBar() {
        
        let navBar = navigationController?.navigationBar
//        navBar?.isTranslucent = false
        navBar?.shadowImage = UIImage()
        navBar?.barTintColor = Theme.themeColor
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        
    }
    
    fileprivate func setupTableView() {
        
        tableView.rowHeight = 101
//        tableView.estimatedRowHeight = 101
        tableView.contentInset.top = -64
        tableView.scrollIndicatorInsets.top = tableView.contentInset.top
        tableView.clipsToBounds = false
        tableView.backgroundColor = UIColor.white
//弹簧效果        tableView.bounces = false
        //header注册
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
}



// MARK: - Get Data
extension MainViewController {
    
    
    func loadLatestNews() {
        loadNews(url: News.latestNewsURL)
    }
    func loadPreviousNews() {
        loadNews(url: (news.last?.previousNewsURL)!)
    }
    
    func loadNews(url: URL) {
        
        request(url).responseJSON { (response) in
            switch response.result {
                
            case .success(let json as JSONDictionary):
                let new = News.parse(json: json)
                self.news.append(new)
                //Banner
                if(self.news.count == 1){
                    self.topStories = self.news[0].topStories!
                }
                
                
                
            case .failure(let error):
                print(error)
                
            default: break
                
            }
            
        }
        
    }
    
    
    
}




// MARK: - tableView
extension MainViewController {
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return news[section].stories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as? StoryCell
        cell?.story = news[indexPath.section].stories[indexPath.row]
        return cell!
    }
    
    
    // MARK: - Table view Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        
        header?.textLabel?.text = news[section].formatDate
        header?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        header?.textLabel?.textColor = UIColor.white
        header?.contentView.backgroundColor = Theme.themeColor
        
        return header
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 40
        }else {
            return 0
        }
    
    }
    
    // MARK: - Table view Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //提前加载下一列数据
        if indexPath.section == news.count - 1 && indexPath.row == 0 {
            loadPreviousNews()
        }
        
        //navigationBar文字变化
        print("\(indexPath.section):\(indexPath.row)")
        
        
    }
    
    
    
    // MARK: - 监听滚动
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Banner随动
        if tableView.contentOffset.y < 0{
        bannerView.bannerOffset = tableView.contentOffset.y
        }
        
        //导航栏透明变化
        if navigationBarAlpha > 1 && navigationBarAlpha < 0{
            return
        }
        navigationController?.navigationBar.subviews.first?.alpha = navigationBarAlpha
        
    }
    
    
}
