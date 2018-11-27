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
    @objc var progress: Float = 0.0 {
        willSet {
            if newValue < 0.0 || newValue > 1.0 {
                return
            }
            self.setNeedsDisplay()
        }
    }
    
    @objc dynamic var progressTintColor: UIColor! = UIColor.white {
        didSet {
            if self.progressTintColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    @objc dynamic var trackTintColor: UIColor! = UIColor.clear {
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

    override init(frame: CGRect) {
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
        
        let lineWidth: CGFloat = 2.0
        let double_lineWidth: CGFloat = 4.0
        
        // Draw background and border
        let backgroundRadius = half_height - lineWidth
        
        content?.setLineWidth(lineWidth)
        content?.setStrokeColor(self.progressTintColor.cgColor)
        content?.setFillColor(self.trackTintColor.cgColor)
        
        content?.move(to: CGPoint(x: lineWidth, y: half_height))
        content?.addArc(tangent1End: CGPoint(x: lineWidth, y: lineWidth), tangent2End: CGPoint(x: backgroundRadius + lineWidth, y: lineWidth), radius: backgroundRadius)
        content?.addArc(tangent1End: CGPoint(x: width - lineWidth, y: lineWidth), tangent2End: CGPoint(x: width - lineWidth, y: half_height), radius: backgroundRadius)
        content?.addArc(tangent1End: CGPoint(x: width - lineWidth, y: height - lineWidth), tangent2End: CGPoint(x: width - backgroundRadius - lineWidth, y: height - lineWidth), radius: backgroundRadius)
        content?.addArc(tangent1End: CGPoint(x: lineWidth, y: height - lineWidth), tangent2End: CGPoint(x: lineWidth, y: half_height), radius: backgroundRadius)
        
        content?.drawPath(using: .fillStroke)
        
        // Draw progress
        let progressWidth = width * CGFloat(self.progress)
        let progressRadius = half_height - double_lineWidth
        
        content?.setFillColor(self.progressTintColor.cgColor)
        
        if progressWidth >= progressRadius + double_lineWidth && progressWidth <= width - progressRadius - double_lineWidth {
            content?.move(to: CGPoint(x: double_lineWidth, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: double_lineWidth, y: double_lineWidth), tangent2End: CGPoint(x: progressRadius + double_lineWidth, y: double_lineWidth), radius: progressRadius)
            content?.addLine(to: CGPoint(x: progressWidth, y: double_lineWidth))
            content?.addLine(to: CGPoint(x: progressWidth, y: height - double_lineWidth))
            content?.addLine(to: CGPoint(x: progressRadius + double_lineWidth, y: height - double_lineWidth))
            content?.addArc(tangent1End: CGPoint(x: double_lineWidth, y: height - double_lineWidth), tangent2End: CGPoint(x: double_lineWidth, y: half_height), radius: progressRadius)
            
            content?.fillPath()
        }
        else if progressWidth < progressRadius + double_lineWidth && progressWidth > 0.0 {
            content?.move(to: CGPoint(x: double_lineWidth, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: double_lineWidth, y: double_lineWidth), tangent2End: CGPoint(x: progressRadius + double_lineWidth, y: double_lineWidth), radius: progressRadius)
            content?.addLine(to: CGPoint(x: progressRadius + double_lineWidth, y: height - double_lineWidth))
            content?.addArc(tangent1End: CGPoint(x: double_lineWidth, y: height - double_lineWidth), tangent2End: CGPoint(x: double_lineWidth, y: half_height), radius: progressRadius)
        
            content?.fillPath()
        }
        else if progressWidth > width - progressRadius - double_lineWidth {
            let tempX = progressWidth - (width - progressRadius - double_lineWidth)
            var angle = acos(tempX / progressRadius)
            if angle.isNaN {
                angle = 0.0
            }
            
            content?.move(to: CGPoint(x: double_lineWidth, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: double_lineWidth, y: double_lineWidth), tangent2End: CGPoint(x: progressRadius + double_lineWidth, y: double_lineWidth), radius: progressRadius)
            content?.addLine(to: CGPoint(x: width - progressRadius - double_lineWidth, y: double_lineWidth))
            
            content?.addArc(center: CGPoint(x: width - progressRadius - double_lineWidth, y: half_height), radius: progressRadius, startAngle: .pi, endAngle: -(angle), clockwise: false)
            content?.addLine(to: CGPoint(x: progressWidth, y: half_height))
            
            content?.move(to: CGPoint(x: double_lineWidth, y: half_height))
            content?.addArc(tangent1End: CGPoint(x: double_lineWidth, y: height - double_lineWidth), tangent2End: CGPoint(x: progressRadius + double_lineWidth, y: height - double_lineWidth), radius: progressRadius)
            content?.addLine(to: CGPoint(x: width - progressRadius - double_lineWidth, y: height - double_lineWidth))
            
            content?.addArc(center: CGPoint(x: width - progressRadius - double_lineWidth, y: half_height), radius: progressRadius, startAngle: -(.pi), endAngle: angle, clockwise: true)
            content?.addLine(to: CGPoint(x: progressWidth, y: half_height))
            
            content?.fillPath()
        }
    }
}
