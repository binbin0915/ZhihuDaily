//
//  DetailViewController.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/19.
//
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var story: Story! {
        didSet {
            loadStoryContent()
        }
    }
    
    var bannerView: BannerViewCell!
    let bannerViewHeight: CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBannerView()
        setupWebView()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

}



// MARK: - setup
extension DetailViewController {
    
    func setupBannerView() {
        
        bannerView = BannerViewCell(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: bannerViewHeight))
//        bannerView.contentMode = .scaleAspectFill
//        bannerView.clipsToBounds = true
    }
    
    func setupWebView() {
        
        let webScrollView = webView.subviews[0] as! UIScrollView
        webScrollView.contentInset.top = -20
        webScrollView.delegate = self
//        webView.clipsToBounds = false
        webScrollView.addSubview(bannerView)
    }
    
}



// MARK: - Get Data
extension DetailViewController {
    
    func loadStoryContent() {
        
        request(story.storyURL).responseJSON { (response) in
            switch response.result {
                
            case .success(let json as JSONDictionary):
                guard let body = json["body"] as? String,
                      let css = json["css"] as? [String],
                      let image = json["image"] as? String else {
                    fatalError("StoryContent -> nil")
                }
                self.bannerView.configData(title: self.story.title, imageString: image)
                
                let html = self.spliceHTML(body: body, css: css)
                DispatchQueue.main.async { [weak self] in
                    self!.webView.loadHTMLString(html, baseURL: nil)
                }
            
            case .failure(let error):
                fatalError("\(error)")
                
            default: break
            }
            
        }
        
    }
    
    //拼接html
    func spliceHTML(body: String, css: [String]) -> String {
        var html = "<html>"
        
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\($0)>" }
        html += "<style>img{max-width:320px !important;}</style>"
        html += "</head>"
        
        html += "<body>"
        html += body
        html += "</body>"
        
        html += "</html>"
        
        return html
        
    }
    
}


// MARK: - Banner动画
extension DetailViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < 0 {
           
            let offsetY = scrollView.contentOffset.y
            bannerView.bannerImageView.frame.origin.y = min(offsetY, 0)
            bannerView.bannerImageView.frame.size.height = max(bannerViewHeight, bannerViewHeight - offsetY)
        }
        
    }
    
    
}

