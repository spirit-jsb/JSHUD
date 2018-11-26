//
//  JSBarProgressView.swift
//  JSProgressHUD
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import UIKit

public class JSBarProgressView: UIView {

    // MARK: 属性
    public var progress: Float = 0.0 {
        willSet {
            if newValue < 0.0 || newValue > 1.0 {
                return
            }
            self.setNeedsDisplay()
        }
    }
    
    public var progressTintColor: UIColor = UIColor.black {
        didSet {
            if self.progressTintColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    public var trackTintColor: UIColor = UIColor.white {
        didSet {
            if self.trackTintColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    // MARK: 初始化
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 120.0, height: 20.0))
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 设置方法
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }

    // MARK: 重写父类方法
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 120.0, height: 10.0)
    }
    
    public override func draw(_ rect: CGRect) {
        let content = UIGraphicsGetCurrentContext()
        
        let width = rect.width
        let height = rect.height
        let half_width = width / 2.0
        let half_height = height / 2.0
        
        // Draw background and border
        let backgroundRadius = half_height - 2.0
        
        content?.setLineWidth(2.0)
        content?.setStrokeColor(self.progressTintColor.cgColor)
        content?.setFillColor(self.trackTintColor.cgColor)
        
        content?.move(to: CGPoint(x: 2.0, y: half_height))
        content?.addArc(tangent1End: CGPoint(x: 2.0, y: 2.0), tangent2End: CGPoint(x: backgroundRadius + 2.0, y: 2.0), radius: backgroundRadius)
        content?.addArc(tangent1End: CGPoint(x: width - 2.0, y: 2.0), tangent2End: CGPoint(x: width - 2.0, y: half_height), radius: backgroundRadius)
        content?.addArc(tangent1End: CGPoint(x: width - 2.0, y: height - 2.0), tangent2End: CGPoint(x: width - backgroundRadius - 2.0, y: height - 2.0), radius: backgroundRadius)
        content?.addArc(tangent1End: CGPoint(x: 2.0, y: height - 2.0), tangent2End: CGPoint(x: 2.0, y: half_height), radius: backgroundRadius)
        
        content?.drawPath(using: .fillStroke)
        
        // Draw progress
        let progressWidth = width * CGFloat(self.progress)
        let progressRadius = half_height - 4.0
        
        content?.setFillColor(self.progressTintColor.cgColor)
        
        if progressWidth >= progressRadius + 4.0 && progressWidth <= width - progressRadius - 4.0 {
            content?.move(to: CGPoint(x: 4.0, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0), tangent2End: CGPoint(x: progressRadius + 4.0, y: 4.0), radius: progressRadius)
            content?.addLine(to: CGPoint(x: progressWidth, y: 4.0))
            content?.addLine(to: CGPoint(x: progressWidth, y: height - 4.0))
            content?.addLine(to: CGPoint(x: progressRadius + 4.0, y: height - 4.0))
            content?.addArc(tangent1End: CGPoint(x: 4.0, y: height - 4.0), tangent2End: CGPoint(x: 4.0, y: half_height), radius: progressRadius)
            
            content?.fillPath()
        }
        else if progressWidth < progressRadius + 4.0 && progressWidth > 0 {
            content?.move(to: CGPoint(x: 4.0, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0), tangent2End: CGPoint(x: progressRadius + 4.0, y: 4.0), radius: progressRadius)
            content?.addLine(to: CGPoint(x: progressRadius + 4.0, y: height - 4.0))
            content?.addArc(tangent1End: CGPoint(x: 4.0, y: height - 4.0), tangent2End: CGPoint(x: 4.0, y: half_height), radius: progressRadius)
        
            content?.fillPath()
        }
        else if progressWidth > width - progressRadius - 4.0 {
            let tempX = progressWidth - (width - progressRadius - 4.0)
            var angle = acos(tempX / progressRadius)
            if angle.isNaN {
                angle = 0.0
            }
            
            content?.move(to: CGPoint(x: 4.0, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0), tangent2End: CGPoint(x: progressRadius + 4.0, y: 4.0), radius: progressRadius)
            content?.addLine(to: CGPoint(x: width - progressRadius - 4.0, y: 4.0))
            
            content?.addArc(center: CGPoint(x: width - progressRadius - 4.0, y: half_height), radius: progressRadius, startAngle: .pi, endAngle: -(angle), clockwise: false)
            content?.addLine(to: CGPoint(x: progressWidth, y: half_height))
            
            content?.move(to: CGPoint(x: 4.0, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: 4.0, y: height - 4.0), tangent2End: CGPoint(x: progressRadius + 4.0, y: height - 4.0), radius: progressRadius)
            content?.addLine(to: CGPoint(x: width - progressRadius - 4.0, y: height - 4.0))
            
            content?.addArc(center: CGPoint(x: width - progressRadius - 4.0, y: half_height), radius: progressRadius, startAngle: -(.pi), endAngle: angle, clockwise: true)
            content?.addLine(to: CGPoint(x: progressWidth, y: half_height))
            
            content?.fillPath()
        }
    }
}
