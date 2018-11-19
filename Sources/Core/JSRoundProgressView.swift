//
//  JSRoundProgressView.swift
//  JSProgressHUD
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import UIKit

public class JSRoundProgressView: UIView {

    // MARK: 属性
    public var progress: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var backgroundTintColor: UIColor = UIColor.white {
        didSet {
            if self.backgroundTintColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    public var progressTintColor: UIColor = UIColor.white {
        didSet {
            if self.progressTintColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    public var isAnnular: Bool = false
    
    // MARK: 初始化
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 37.0))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        if self.isAnnular {
            // Draw background
            let lineWidth: CGFloat = 2.0
            let backgroundPath = UIBezierPath()
            
            backgroundPath.lineWidth = lineWidth
            backgroundPath.lineCapStyle = .butt
            
            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            let radius = (self.bounds.size.width - lineWidth) / 2.0
            let startAngle: CGFloat = -(.pi / 2.0)
            var endAngle = (2.0 * .pi) + startAngle
            
            backgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            self.backgroundTintColor.set()
            
            backgroundPath.stroke()
            
            // Draw progress
            let progressPath = UIBezierPath()
            
            progressPath.lineWidth = lineWidth
            progressPath.lineCapStyle = .square
            
            endAngle = (self.progress * 2.0 * .pi) + startAngle
            
            progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            self.progressTintColor.set()
            
            progressPath.stroke()
        }
        else {
            // Draw background
            let lineWidth: CGFloat = 2.0
            
            let circleRect = self.bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
        
            self.progressTintColor.setStroke()
            self.backgroundTintColor.setFill()
            
            context?.setLineWidth(lineWidth)
            context?.strokeEllipse(in: circleRect)

            // Draw progress
            let progressPath = UIBezierPath()
            
            progressPath.lineWidth = lineWidth * 2.0
            progressPath.lineCapStyle = .butt
            
            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            let radius = (self.bounds.width / 2.0) - (lineWidth / 2.0)
            let startAngle: CGFloat = -(.pi / 2.0)
            let endAngle = (self.progress * 2.0 * .pi) + startAngle
            
            progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            context?.setBlendMode(.copy)
            
            self.progressTintColor.set()
            
            progressPath.stroke()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 37.0, height: 37.0)
    }
    
    // MARK: 设置方法
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    // MARK: 私有方法
}
