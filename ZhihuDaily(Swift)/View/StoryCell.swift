//
//  StoryCell.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/10.
//
//

import UIKit

class StoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    
    var story: Story! {
        didSet{
            titleLabel.text = story.title
            titleImageView.af_setImage(withURL: story.url)
        }
    }

}
