//
//  BannerViewCell.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/19.
//
//

import UIKit


class BannerViewCell: UIView{
    
    var bannerImageView: UIImageView!
    var bannerLabelView: UILabel!
    let bannerLabelMargin: CGFloat = 10

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBannerImage()
        setupBannerLabelView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



// MARK: - setup
extension BannerViewCell {
    
    func setupBannerImage() {
       
        bannerImageView = UIImageView(frame: frame)
        bannerImageView.clipsToBounds = true
        bannerImageView.contentMode = .scaleAspectFill
        
        addSubview(bannerImageView)
        
    }
    
    func setupBannerLabelView() {
        bannerLabelView = UILabel()
        bannerLabelView.textColor = UIColor.white
        bannerLabelView.numberOfLines = 0
        bannerLabelView.font = UIFont.boldSystemFont(ofSize: 20)
        
        addSubview(bannerLabelView)
    }
    
    //配置数据
    func configData(topStory: Story) {
        
        //BannerImage
        bannerImageView.af_setImage(withURL: topStory.url)
        
        
        //bannerLabel
        bannerLabelView.text = topStory.title
        // frame
        let textWidth = UIScreen.main.bounds.size.width - 2 * bannerLabelMargin
        let textHeight = topStory.title.getTextHeight(textWidth: textWidth, font: bannerLabelView.font)
        let labelX = bannerLabelMargin
        let labelY = frame.size.height - 37 - textHeight
        
        bannerLabelView.frame = CGRect(x: labelX, y: labelY, width: textWidth, height: textHeight)
        
        
    }
    
}
