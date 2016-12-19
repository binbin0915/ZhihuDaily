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
    
    //执行点击cell和Banner的闭包
    var selectStory: (Story) -> () = {_ in}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupBannerView()
        
        loadLatestNews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

}


// MARK: - setup
extension MainViewController {
    
    fileprivate func setupNavigationBar() {
        let navBar = navigationController?.navigationBar
        navBar?.shadowImage = UIImage()
        navBar?.barTintColor = Theme.themeColor
        navBar?.tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    
    fileprivate func setupTableView() {
        tableView.rowHeight = 101
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset.top = -64
        tableView.backgroundColor = UIColor.white
        
        //header注册
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    
    fileprivate func setupBannerView() {
        bannerView.delegate = self
    }
    
    
}



// MARK: - Get Data
extension MainViewController {
    
    //新数据
    func loadLatestNews() {
        loadNews(url: News.latestNewsURL)
    }
    //旧数据
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
        /*
         ⬇️reduce函数原理：取出当前所有显示的rowCell所在的section值 与
         一个无穷大的值进行比对(如Int.max)返回最小值，partialResult会接收
         每次比对的操作结果进行下次比对，reduce函数操作完成后会返回当前显示cell
         所在section最小值，当页面所有旧cell都完全不显示了，displaySection就会取
         得新值(0完全不显示了，就会轮到1和Int.max比对)
         
         
         
         */
        
        let displaySection = tableView.indexPathsForVisibleRows?.reduce(Int.max, {
            (partialResult, indexPath) -> Int in
            return min(partialResult, indexPath.section)
        })
        
        if displaySection == 0 {
            DispatchQueue.main.async { [weak self] in
                self!.navigationItem.title = "今日热文"
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self!.navigationItem.title = self!.news[displaySection!].formatDate
            }
        }
        
        
    }
    
    
    //cell点击
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectStory(news[indexPath.section].stories[indexPath.row])
    }
    
    
    // MARK: - scrollViewDidScroll 监听滚动
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

// MARK: - BannerViewDelegate
extension MainViewController: BannerViewDelegate {
    
    func tapBanner(topStories: Story) {
        selectStory(topStories)
    }
    
    
}



