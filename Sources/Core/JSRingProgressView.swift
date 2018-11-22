//
//  JSRingProgressView.swift
//  JSProgressHUD
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import UIKit

public class JSRingProgressView: UIView {

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
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
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
        return CGSize(width: 40.0, height: 40.0)
    }
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        let lineWidth: CGFloat = 2.0
        let circleRect = self.bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
        
        // Draw background
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(self.progressTintColor.cgColor)
        context?.setFillColor(self.trackTintColor.cgColor)
        
        context?.strokeEllipse(in: circleRect)

        // Draw progress
        let progressPath = UIBezierPath()

        progressPath.lineWidth = lineWidth * 2.0
        progressPath.lineCapStyle = .butt
        
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = (self.bounds.width / 2.0) - lineWidth
        let startAngle: CGFloat = -(.pi / 2.0)
        let endAngle = (CGFloat(self.progress) * 2.0 * .pi) + startAngle
        
        progressPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        context?.setBlendMode(.copy)
        
        self.progressTintColor.set()
        
        progressPath.stroke()
    }
}
