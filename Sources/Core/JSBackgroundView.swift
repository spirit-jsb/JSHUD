//
//  JSBackgroundView.swift
//  JSHUD
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import UIKit

public class JSBackgroundView: UIView {

    // MARK: 属性
    public var backgroundStyle: JSHUDBackgroundStyle = .blur {
        didSet {
            if self.backgroundStyle != oldValue {
                self.resetBackgroundStyle()
            }
        }
    }
    
    public var blurStyle: UIBlurEffect.Style = .light {
        didSet {
            if self.blurStyle != oldValue {
                self.resetBackgroundStyle()
            }
        }
    }
    
    public var color: UIColor = UIColor(white: 0.8, alpha: 0.6) {
        didSet {
            if self.color != oldValue {
                self.resetBackgroundColor()
            }
        }
    }
    
    private var effectView: UIVisualEffectView?

    // MARK: 初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 设置方法
    private func setupView() {
        self.clipsToBounds = true
        self.resetBackgroundStyle()
    }
    
    // MARK: 重写父类方法
    public override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // MARK: 私有方法
    private func resetBackgroundStyle() {
        self.effectView?.removeFromSuperview()
        self.effectView = nil
        
        if self.backgroundStyle == .blur {
            let effect = UIBlurEffect(style: self.blurStyle)
            let effectView = UIVisualEffectView(effect: effect)
            
            effectView.frame = self.bounds
            effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            self.insertSubview(effectView, at: 0)
            
            self.backgroundColor = self.color
            self.layer.allowsGroupOpacity = false
            
            self.effectView = effectView
        }
        else {
            self.backgroundColor = self.color
        }
    }

    private func resetBackgroundColor() {
        self.backgroundColor = self.color
    }
}
