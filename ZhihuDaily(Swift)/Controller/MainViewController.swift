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

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bannerView: BannerView!
    @IBOutlet weak var reFreshView: RefreshView!
    
    var currentOffset: CGFloat {
        return tableView.contentOffset.y
    }
    
    var isRefreshing: Bool! {
        didSet {
            if isRefreshing == true {
                reFreshView.updateProgress(progress: 0)
                reFreshView.startAnimation()
                news.removeAll()
                loadLatestNews()
                
            }else {
                DispatchQueue.main.async { [weak self] in
                    self?.reFreshView.stopAnimation()
                }
            }
            
        }
        
    }
    let refreshOffset: CGFloat = 40
    let bannerViewHeight: CGFloat = Theme.bannerViewHeight
    
    var topViewAlpha: CGFloat {
        return currentOffset / (bannerViewHeight - 64)
    }
    
    var news = [News]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                
                if self?.isRefreshing == true {
                    self?.tableView.reloadData()
                }else{
                    self?.tableView.insertSections(IndexSet(integer: (self?.news.count)! - 1), with: .top)
                }
                
                
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
        
        setupTopView()
        setupTableView()
        setupBannerView()
        setupRefreshView()
        
        loadLatestNews()
        
    }
    //隐藏默认导航栏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
}


// MARK: - setup
extension MainViewController {
    
    fileprivate func setupTopView() {
        topView.backgroundColor = Theme.themeColor
        
    }
    
    
    fileprivate func setupTableView() {
        tableView.rowHeight = 101
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset.top = -20
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.delegate = self
        
        //header注册
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    
    fileprivate func setupBannerView() {
        bannerView.delegate = self
    }
    
    fileprivate func setupRefreshView() {
        isRefreshing = false
        
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
                self.isRefreshing = false
                print(error)
                
            default: break
            
            }
        }
    }
    
}




// MARK: - tableView
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return news.count
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return news[section].stories.count
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as? StoryCell
        cell?.story = news[indexPath.section].stories[indexPath.row]
        return cell!
    }
    
    
    // MARK: - Table view Header
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            return nil
        }
        
        
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
//        header?.textLabel?.text = news[section].formatDate
//        header?.textLabel?.font = UIFont.systemFont(ofSize: 14)
//        header?.textLabel?.textAlignment = .center
//        header?.textLabel?.textColor = UIColor.white
//        header?.contentView.backgroundColor = Theme.themeColor
//        return header
        
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        textLabel.text = news[section].formatDate
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.backgroundColor = Theme.themeColor
        
        return textLabel
    }

    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 40
        }else {
            return 0
        }
    
    }
    
    
    
    // MARK: - Table view Delegate
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
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
                self!.topLabel.text = "今日热文"
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self!.topLabel.text = self!.news[displaySection!].formatDate
            }
        }
        
    }
    
    
    
    // MARK: - scrollViewDidScroll 监听滚动
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //下拉刷新
        if isRefreshing == false {
            reFreshView.updateProgress(progress: -currentOffset / refreshOffset)
        }
        
        
        if currentOffset < 0{
            //Banner随动
            bannerView.bannerOffset = currentOffset
            
        }
        
        //导航栏透明变化
        if topViewAlpha > 1 && topViewAlpha < 0{
            return
        }
        topView.alpha = topViewAlpha
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //松手进入刷新状态
        if -currentOffset > refreshOffset && isRefreshing == false{
            isRefreshing = true
            
            let delayQueue = DispatchQueue(label: "com.appcoda.delayqueue", qos: .userInitiated)
            delayQueue.asyncAfter(deadline: .now() + 2) {
                self.isRefreshing = false
            }
        
        }
        
    }
    
    
    
    
    //cell点击
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectStory(news[indexPath.section].stories[indexPath.row])
    }
    
}

// MARK: - BannerViewDelegate
extension MainViewController: BannerViewDelegate {
    
    func tapBanner(topStories: Story) {
        selectStory(topStories)
    }
    
    
}



