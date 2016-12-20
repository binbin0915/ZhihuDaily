//
//  RefreshView.swift
//  ZhihuDaily(Swift)
//
//  Created by ldming on 2016/12/20.
//
//

import UIKit


class RefreshView: UIView {
    
    var indicatorView: UIActivityIndicatorView!
    var whiteShapeLayer: CAShapeLayer!
    var grayShapeLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRefreshView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRefreshView()
    }
    
}


extension RefreshView {
    
    fileprivate func setupRefreshView() {
        
        indicatorView = UIActivityIndicatorView(frame: bounds)
        
        grayShapeLayer = CAShapeLayer()
        grayShapeLayer.lineWidth = 2
        grayShapeLayer.strokeColor = UIColor.gray.cgColor
        grayShapeLayer.fillColor = UIColor.clear.cgColor
        grayShapeLayer.opacity = 0
        grayShapeLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        
        whiteShapeLayer = CAShapeLayer()
        whiteShapeLayer.lineWidth = 2
        whiteShapeLayer.strokeColor = UIColor.white.cgColor
        whiteShapeLayer.fillColor = UIColor.clear.cgColor
        whiteShapeLayer.opacity = 0
        whiteShapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2, y: frame.width / 2), radius: frame.width / 2, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(M_PI) * 5 / 2, clockwise: true).cgPath
        whiteShapeLayer.strokeEnd = 0
        
        addSubview(indicatorView)
        layer.addSublayer(grayShapeLayer)
        layer.addSublayer(whiteShapeLayer)
        
    }
    
    // draw
    func updateProgress(progress: CGFloat) {
        
        if (progress <= 0) {
            whiteShapeLayer.opacity = 0
            grayShapeLayer.opacity = 0
            
        }else {
            whiteShapeLayer.opacity = 1
            grayShapeLayer.opacity = 1
        }
        
        var progress = progress
        if progress > 1 {
            progress = 1
        }

        whiteShapeLayer.strokeEnd = progress
    }
    
    //animation
    func startAnimation() {
        indicatorView.startAnimating()
    }
    func stopAnimation() {
        indicatorView.stopAnimating()
    }
    
    
    
}
