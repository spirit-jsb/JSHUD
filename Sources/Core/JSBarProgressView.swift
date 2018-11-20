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
    public var progress: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var borderColor: UIColor = UIColor.white
    
    public var progressColor: UIColor = UIColor.white {
        didSet {
            if self.progressColor != oldValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    public var progressRemainingColor: UIColor = UIColor.clear {
        didSet {
            if self.progressRemainingColor != oldValue {
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
    
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        // Draw background and border
        context?.setLineWidth(2.0)
        context?.setStrokeColor(self.borderColor.cgColor)
        context?.setFillColor(self.progressRemainingColor.cgColor)
        
        let rect_width = rect.size.width
        let rect_height = rect.size.height
        var radius = (rect.size.height / 2.0) - 2.0
        
        context?.move(to: CGPoint(x: 2.0, y: rect_height / 2.0))
        context?.addArc(tangent1End: CGPoint(x: 2.0, y: 2.0), tangent2End: CGPoint(x: radius + 2.0, y: 2.0), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect_width - 2.0, y: 2.0), tangent2End: CGPoint(x: rect_width - 2.0, y: rect_height / 2.0), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect_width - 2.0, y: rect_height - 2.0), tangent2End: CGPoint(x: rect_width - radius - 2.0, y: rect_height - 2.0), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: 2.0, y: rect_height - 2.0), tangent2End: CGPoint(x: 2.0, y: rect_height / 2.0), radius: radius)
        
        context?.drawPath(using: .fillStroke)
        context?.setFillColor(self.progressColor.cgColor)

        // Draw progress
        let amount = self.progress * rect_width
        radius = radius - 2.0

        if amount >= radius + 4.0 && amount <= (rect_width - radius - 4.0) {
            context?.move(to: CGPoint(x: 4.0, y: rect_height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0), tangent2End: CGPoint(x: radius + 4.0, y: 4.0), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: 4.0))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4.0))

            context?.move(to: CGPoint(x: 4.0, y: rect_height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: rect_height - 4.0), tangent2End: CGPoint(x: radius + 4.0, y: rect_height - 4.0), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: rect_height - 4.0))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4.0))

            context?.fillPath()
        }
        else if amount > radius + 4.0 {
            let x = amount - (rect_width - radius - 4.0)

            context?.move(to: CGPoint(x: 4.0, y: rect_height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0), tangent2End: CGPoint(x: radius + 4.0, y: 4.0), radius: radius)
            context?.addLine(to: CGPoint(x: rect_width - radius - 4.0, y: 4.0))

            var angle = -acos(x / radius)
            if angle.isNaN {
                angle = 0.0
            }

            context?.addArc(center: CGPoint(x: rect_width - radius - 4.0, y: rect_height / 2.0), radius: radius, startAngle: .pi, endAngle: angle, clockwise: false)
            context?.addLine(to: CGPoint(x: amount, y: rect_height / 2.0))

            context?.move(to: CGPoint(x: 4.0, y: rect_height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: rect_height - 4.0), tangent2End: CGPoint(x: radius + 4.0, y: rect_height - 4.0), radius: radius)
            context?.addLine(to: CGPoint(x: rect_width - radius - 4.0, y: rect_height - 4.0))

            angle = acos(x / radius)
            if angle.isNaN {
                angle = 0.0
            }

            context?.addArc(center: CGPoint(x: rect_width - radius - 4.0, y: rect_height / 2.0), radius: radius, startAngle: -(.pi), endAngle: angle, clockwise: true)
            context?.addLine(to: CGPoint(x: amount, y: rect_height / 2.0))

            context?.fillPath()
        }
        else if amount < radius + 4.0 && amount > 0.0 {
            context?.move(to: CGPoint(x: 4.0, y: rect_height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: 4.0), tangent2End: CGPoint(x: radius + 4.0, y: 4.0), radius: radius)
            context?.addLine(to: CGPoint(x: radius + 4.0, y: rect_height / 2.0))

            context?.move(to: CGPoint(x: 4.0, y: rect_height / 2.0))
            context?.addArc(tangent1End: CGPoint(x: 4.0, y: rect_height - 4.0), tangent2End: CGPoint(x: radius + 4.0, y: rect_height - 4.0), radius: radius)
            context?.addLine(to: CGPoint(x: radius + 4.0, y: rect_height / 2.0))

            context?.fillPath()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 120.0, height: 10.0)
    }
    
    // MARK: 设置方法
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    // MARK: 私有方法
}
