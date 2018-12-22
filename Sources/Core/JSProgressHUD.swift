//
//  JSHUD.swift
//  JSHUD
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import UIKit

public class JSHUD: UIView {
    
    static public let JSProgressMaxOffset: CGFloat = CGFloat.greatestFiniteMagnitude
    
    static let JSDefaultPadding: CGFloat = 4.0
    static let JSDefaultLabelFontSize: CGFloat = 16.0
    static let JSDefaultDetailsLabelFontSize: CGFloat = 12.0
    
    // MARK: 属性
    public typealias JSHUDCompletionHandle = () -> Void
    
    public weak var delegate: JSHUDDelegate?
    
    public var completionHandle: JSHUDCompletionHandle?
    
    public var graceTime: TimeInterval = 0.0
    
    public var minShowTime: TimeInterval = 0.0
    
    public var removeFromSuperViewWhenHide: Bool = false
    
    public var mode: JSHUDMode = .loading {
        didSet {
            if self.mode != oldValue {
                self.updateIndicators()
            }
        }
    }
    
    public var animation: JSHUDAnimation = .fade
    
    public var contentColor: UIColor = UIColor(white: 0.0, alpha: 0.7) {
        didSet {
            if self.contentColor != oldValue && !(self.contentColor.isEqual(oldValue)) {
                self.updateViewsColor()
            }
        }
    }
    
    public var offset: CGPoint = .zero {
        didSet {
            if !(self.offset.equalTo(oldValue)) {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    public var margin: CGFloat = 20.0 {
        didSet {
            if self.margin != oldValue {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    public var minSize: CGSize = .zero {
        didSet {
            if !(self.minSize.equalTo(oldValue)) {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    public var areDefaultMotionEffectsEnabled: Bool = true {
        didSet {
            if self.areDefaultMotionEffectsEnabled != oldValue {
                self.updateBezelMotionEffects()
            }
        }
    }
    
    @objc public var progress: Float = 0.0 {
        didSet {
            if self.progress != oldValue {
                self.indicatorView?.setValue(self.progress, forKey: "progress")
            }
        }
    }
    
    public var progressObject: Progress? {
        didSet {
            if self.progressObject != oldValue {
                self.enableSetProgressDisplayLink(true)
            }
        }
    }
    
    public private(set) var bezelView: JSBackgroundView!
    
    public private(set) var backgroundView: JSBackgroundView!
    
    public private(set) var label: UILabel!
    
    public private(set) var detailsLabel: UILabel!
    
    public var customView: UIView? {
        didSet {
            if self.customView != oldValue && self.mode == .custom {
                self.updateIndicators()
            }
        }
    }
    
    private var isUseAnimation: Bool!
    private var hasFinished: Bool!

    private var indicatorView: UIView?
    
    private var showStartDate: Date?
    
    private lazy var paddingConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    private lazy var bezelConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    
    private weak var graceTimer: Timer?
    private weak var minShowTimer: Timer?
    private weak var hideDelayTimer: Timer?
    
    private weak var progressObjectDisplayLink: CADisplayLink? {
        didSet {
            if self.progressObjectDisplayLink != oldValue {
                oldValue?.invalidate()
                self.progressObjectDisplayLink?.add(to: RunLoop.main, forMode: .default)
            }
        }
    }
    
    private var topSpacerView: UIView!
    private var bottomSpacerView: UIView!
    
    // MARK: 初始化
    public convenience init(with view: UIView?) {
        self.init(frame: view?.bounds ?? .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeNotification()
    }
    
    // MARK: 重写父类方法
    public override func layoutSubviews() {
        if !self.needsUpdateConstraints() {
            self.updatePaddingConstraints()
        }
        super.layoutSubviews()
    }
    
    public override func didMoveToSuperview() {
        self.updateCurrentOrientationAnimated()
    }
    
    public override func updateConstraints() {
        let metrics: [String: Any] = ["margin": self.margin]
        
        var subViews = [self.topSpacerView, self.label, self.detailsLabel, self.bottomSpacerView]
        if let indicatorView = self.indicatorView {
            subViews.insert(indicatorView, at: 1)
        }
        
        // 移除现有约束
        self.removeConstraints(self.constraints)
        self.topSpacerView.removeConstraints(self.topSpacerView.constraints)
        self.bottomSpacerView.removeConstraints(self.bottomSpacerView.constraints)
        if self.bezelConstraints.count != 0 {
            self.bezelView.removeConstraints(self.bezelConstraints)
            self.bezelConstraints.removeAll()
        }
        if self.paddingConstraints.count != 0 {
            self.paddingConstraints.removeAll()
        }
        
        var centerConstraints = [NSLayoutConstraint]()
        centerConstraints.append(NSLayoutConstraint(item: self.bezelView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: self.offset.x))
        centerConstraints.append(NSLayoutConstraint(item: self.bezelView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: self.offset.y))
        self.applyPriority(UILayoutPriority(998.0), to: centerConstraints)
        self.addConstraints(centerConstraints)
        
        var sideConstraints = [NSLayoutConstraint]()
        sideConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezelView]-(>=margin)-|", options: [], metrics: metrics, views: ["bezelView": self.bezelView])
        sideConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=margin)-[bezelView]-(>=margin)-|", options: [], metrics: metrics, views: ["bezelView": self.bezelView])
        self.applyPriority(UILayoutPriority(999.0), to: sideConstraints)
        self.addConstraints(sideConstraints)
        
        // Minimum bezel size, if set
        if !self.minSize.equalTo(.zero) {
            var minSizeConstraints = [NSLayoutConstraint]()
            minSizeConstraints.append(NSLayoutConstraint(item: self.bezelView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.minSize.width))
            minSizeConstraints.append(NSLayoutConstraint(item: self.bezelView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.minSize.height))
            self.applyPriority(UILayoutPriority(rawValue: 997.0), to: minSizeConstraints)
            self.bezelConstraints += minSizeConstraints
        }
        
        // Top and Bottom Spacing
        self.topSpacerView.addConstraint(NSLayoutConstraint(item: self.topSpacerView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.margin))
        self.bottomSpacerView.addConstraint(NSLayoutConstraint(item: self.bottomSpacerView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.margin))
        // Top and Bottom Spaces should be equal
        self.bezelConstraints.append(NSLayoutConstraint(item: self.topSpacerView, attribute: .height, relatedBy: .equal, toItem: self.bottomSpacerView, attribute: .height, multiplier: 1.0, constant: 0.0))
        
        // Layout subviews in bezel
        for (index, view) in subViews.enumerated() {
            self.bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self.bezelView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            self.bezelConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[view]-(>=margin)-|", options: [], metrics: metrics, views: ["view": view])
            
            if index == 0 {
                self.bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.bezelView, attribute: .top, multiplier: 1.0, constant: 0.0))
            }
            else if index == subViews.count - 1 {
                self.bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.bezelView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
            }
            
            if index > 0 {
                let paddingConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: subViews[index - 1], attribute: .bottom, multiplier: 1.0, constant: 0.0)
                self.bezelConstraints.append(paddingConstraint)
                self.paddingConstraints.append(paddingConstraint)
            }
        }
        
        self.bezelView.addConstraints(self.bezelConstraints)
        
        self.updatePaddingConstraints()
        
        super.updateConstraints()
    }
    
    // MARK: 公开方法
    public class func showHUD(addTo view: UIView?, animated: Bool) -> JSHUD {
        let hud = JSHUD(with: view)
        hud.removeFromSuperViewWhenHide = true
        view?.addSubview(hud)
        hud.showAnimated(animated)
        return hud
    }
    
    public class func hideHUD(for view: UIView?, animated: Bool) -> Bool {
        let hud = self.HUD(for: view)
        if let _hud = hud {
            _hud.removeFromSuperViewWhenHide = true
            _hud.hideAnimated(animated)
            return true
        }
        return false
    }
    
    public class func HUD(for view: UIView?) -> JSHUD? {
        guard let _view = view else {
            return nil
        }
        for subview in _view.subviews.reversed() {
            if subview.isKind(of: self) {
                let hud = subview as! JSHUD
                if hud.hasFinished == false {
                    return hud
                }
            }
        }
        return nil
    }
    
    public func showAnimated(_ animated: Bool) {
        assert(Thread.isMainThread, "请在主线程上访问 JSHUD")
        
        self.minShowTimer?.invalidate()
        
        self.isUseAnimation = animated
        self.hasFinished = false
        
        if self.graceTime > 0.0 {
            let timer = Timer(timeInterval: self.graceTime, target: self, selector: #selector(handleGraceTimer(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .common)
            self.graceTimer = timer
        }
        else {
            self.showUsingAnimation()
        }
    }
    
    public func hideAnimated(_ animated: Bool) {
        assert(Thread.isMainThread, "请在主线程上访问 JSHUD")
        
        self.graceTimer?.invalidate()
        
        self.isUseAnimation = animated
        self.hasFinished = true
    
        if self.minShowTime > 0.0 && self.showStartDate != nil {
            let interval = Date().timeIntervalSince(self.showStartDate!)
            if interval < self.minShowTime {
                let timer = Timer(timeInterval: (self.minShowTime - interval), target: self, selector: #selector(handleMinShowTimer(_:)), userInfo: nil, repeats: false)
                RunLoop.current.add(timer, forMode: .common)
                self.minShowTimer = timer
                return
            }
        }
        
        self.hideUsingAnimation()
    }
    
    public func hideAnimated(_ animated: Bool, afterDelay delay: TimeInterval) {
        self.hideDelayTimer?.invalidate()
        
        let timer = Timer(timeInterval: delay, target: self, selector: #selector(handleHideTimer(_:)), userInfo: animated, repeats: false)
        RunLoop.current.add(timer, forMode: .common)
        self.hideDelayTimer = timer
    }
    
    // MARK: 设置方法
    private func setupView() {
        // 透明背景
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        // 暂时隐藏
        self.alpha = 0.0
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layer.allowsGroupOpacity = false
        
        // BackgroundView
        self.backgroundView = JSBackgroundView(frame: self.bounds)
        self.backgroundView.alpha = 0.0
        self.backgroundView.backgroundStyle = .solidColor
        self.backgroundView.backgroundColor = UIColor.clear
        self.backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(self.backgroundView)
        
        self.bezelView = JSBackgroundView()
        self.bezelView.alpha = 0.0
        self.bezelView.translatesAutoresizingMaskIntoConstraints = false
        self.bezelView.layer.cornerRadius = 5.0
        
        self.addSubview(self.bezelView)

        self.updateBezelMotionEffects()
        
        self.label = UILabel()
        self.label.isOpaque = false
        self.label.backgroundColor = UIColor.clear
        self.label.adjustsFontSizeToFitWidth = false
        self.label.textAlignment = .center
        self.label.textColor = self.contentColor
        self.label.font = UIFont.boldSystemFont(ofSize: JSHUD.JSDefaultLabelFontSize)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.setContentCompressionResistancePriority(UILayoutPriority(998.0), for: .horizontal)
        self.label.setContentCompressionResistancePriority(UILayoutPriority(998.0), for: .vertical)
        
        self.bezelView.addSubview(self.label)

        self.detailsLabel = UILabel()
        self.detailsLabel.isOpaque = false
        self.detailsLabel.backgroundColor = UIColor.clear
        self.detailsLabel.adjustsFontSizeToFitWidth = false
        self.detailsLabel.textAlignment = .center
        self.detailsLabel.textColor = self.contentColor
        self.detailsLabel.numberOfLines = 0
        self.detailsLabel.font = UIFont.boldSystemFont(ofSize: JSHUD.JSDefaultDetailsLabelFontSize)
        
        self.detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailsLabel.setContentCompressionResistancePriority(UILayoutPriority(998.0), for: .horizontal)
        self.detailsLabel.setContentCompressionResistancePriority(UILayoutPriority(998.0), for: .vertical)
        
        self.bezelView.addSubview(self.detailsLabel)
        
        self.topSpacerView = UIView()
        self.topSpacerView.translatesAutoresizingMaskIntoConstraints = false
        self.topSpacerView.isHidden = true
        
        self.bezelView.addSubview(self.topSpacerView)

        self.bottomSpacerView = UIView()
        self.bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomSpacerView.isHidden = true
        
        self.bezelView.addSubview(self.bottomSpacerView)
    }
    
    // MARK: 私有方法
    private func showUsingAnimation() {
        self.bezelView.layer.removeAllAnimations()
        self.backgroundView.layer.removeAllAnimations()
        
        self.hideDelayTimer?.invalidate()
        
        self.showStartDate = Date()
        self.alpha = 1.0
 
        self.enableSetProgressDisplayLink(true)
        
        if self.isUseAnimation {
            self.animate(true, withType: self.animation)
        }
        else {
            self.bezelView.alpha = 1.0
            self.backgroundView.alpha = 1.0
        }
    }
    
    private func hideUsingAnimation() {
        self.hideDelayTimer?.invalidate()
        
        if self.isUseAnimation && self.showStartDate != nil {
            self.showStartDate = nil
            self.animate(false, withType: self.animation, completionHandle: { (_) in
                self.done()
            })
        }
        else {
            self.showStartDate = nil
            self.bezelView.alpha = 0.0
            self.backgroundView.alpha = 1.0
            self.done()
        }
    }
    
    private func done() {
        self.enableSetProgressDisplayLink(false)
        
        if self.hasFinished {
            self.alpha = 0.0
            if self.removeFromSuperViewWhenHide {
                self.removeFromSuperview()
            }
        }
        
        if let _completionHandle = self.completionHandle {
            _completionHandle()
        }
        
        if self.delegate?.responds(to: #selector(JSHUDDelegate.hudWasHidden(_:))) ?? false {
            self.delegate?.perform(#selector(JSHUDDelegate.hudWasHidden(_:)), with: self)
        }
    }
    
    private func animate(_ isZoomIn: Bool, withType type: JSHUDAnimation, completionHandle: ((Bool) -> ())? = nil) {
        var animationType = type
        
        if animationType == .zoom {
            animationType = isZoomIn ? .zoomIn : .zoomOut
        }
        
        let smallTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let largeTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        if isZoomIn && self.bezelView.alpha == 0.0 && animationType == .zoomIn {
            self.bezelView.transform = smallTransform
        }
        else if isZoomIn && self.bezelView.alpha == 0.0 && animationType == .zoomOut {
            self.bezelView.transform = largeTransform
        }
        
        let animationsHandle = {
            if isZoomIn {
                self.bezelView.transform = CGAffineTransform.identity
            }
            else if !isZoomIn && animationType == .zoomIn {
                self.bezelView.transform = largeTransform
            }
            else if !isZoomIn && animationType == .zoomOut {
                self.bezelView.transform = smallTransform
            }
            let alpha: CGFloat = isZoomIn ? 1.0 : 0.0
            self.bezelView.alpha = alpha
            self.backgroundView.alpha = alpha
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: animationsHandle, completion: completionHandle)
    }
    
    private func initialize() {
        self.setupView()
        self.updateIndicators()
        self.addNotification()
    }
    
    private func addNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(statusBarOrientationDidChange(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    private func removeNotification() {
        let notification = NotificationCenter.default
        notification.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    private func updateIndicators() {
        switch self.mode {
        case .loading:
            self.indicatorView?.removeFromSuperview()
            self.indicatorView = UIActivityIndicatorView(style: .whiteLarge)
            (self.indicatorView as! UIActivityIndicatorView).startAnimating()
            self.bezelView.addSubview(self.indicatorView!)
        case .barProgress:
            self.indicatorView?.removeFromSuperview()
            self.indicatorView = JSBarProgressView()
            self.bezelView.addSubview(self.indicatorView!)
        case .ringProgress:
            self.indicatorView?.removeFromSuperview()
            self.indicatorView = JSRingProgressView()
            self.bezelView.addSubview(self.indicatorView!)
        case .sectorProgress:
            self.indicatorView?.removeFromSuperview()
            self.indicatorView = JSSectorProgressView()
            self.bezelView.addSubview(self.indicatorView!)
        case .custom where !(self.customView?.isEqual(self.indicatorView) ?? true):
            self.indicatorView?.removeFromSuperview()
            self.indicatorView = self.customView
            self.bezelView.addSubview(self.indicatorView!)
        case .text:
            self.indicatorView?.removeFromSuperview()
            self.indicatorView = nil
        default:
            break
        }
        
        self.indicatorView?.translatesAutoresizingMaskIntoConstraints = false
        
        if self.indicatorView?.responds(to: #selector(setter: progress)) ?? false {
            self.indicatorView?.setValue(self.progress, forKey: "progress")
        }
        
        self.indicatorView?.setContentCompressionResistancePriority(UILayoutPriority(998.0), for: .horizontal)
        self.indicatorView?.setContentCompressionResistancePriority(UILayoutPriority(998.0), for: .vertical)
        
        self.updateViewsColor()
        self.setNeedsUpdateConstraints()
    }
    
    private func updateViewsColor() {
        self.label.textColor = self.contentColor
        self.detailsLabel.textColor = self.contentColor
        
        if self.indicatorView?.isKind(of: UIActivityIndicatorView.classForCoder()) ?? false {
            let appearance = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [JSHUD.self])
            if appearance.color == nil {
                (self.indicatorView as! UIActivityIndicatorView).color = self.contentColor
            }
        }
        else if self.indicatorView?.isKind(of: JSRingProgressView.classForCoder()) ?? false {
            let appearance = JSRingProgressView.appearance(whenContainedInInstancesOf: [JSHUD.self])
            if appearance.trackTintColor == nil {
                (self.indicatorView as! JSRingProgressView).trackTintColor = self.contentColor.withAlphaComponent(0.1)
            }
            if appearance.progressTintColor == nil {
                (self.indicatorView as! JSRingProgressView).progressTintColor = self.contentColor
            }
        }
        else if self.indicatorView?.isKind(of: JSBarProgressView.classForCoder()) ?? false {
            let appearance = JSBarProgressView.appearance(whenContainedInInstancesOf: [JSHUD.self])
            if appearance.trackTintColor == nil {
                (self.indicatorView as! JSBarProgressView).trackTintColor = self.contentColor.withAlphaComponent(0.1)
            }
            if appearance.progressTintColor == nil {
                (self.indicatorView as! JSBarProgressView).progressTintColor = self.contentColor
            }
        }
        else if self.indicatorView?.isKind(of: JSSectorProgressView.classForCoder()) ?? false {
            let appearance = JSSectorProgressView.appearance(whenContainedInInstancesOf: [JSHUD.self])
            if appearance.trackTintColor == nil {
                (self.indicatorView as! JSSectorProgressView).trackTintColor = self.contentColor.withAlphaComponent(0.1)
            }
            if appearance.progressTintColor == nil {
                (self.indicatorView as! JSSectorProgressView).progressTintColor = self.contentColor
            }
        }
        else {
            self.indicatorView?.tintColor = self.contentColor
        }
    }
    
    private func updatePaddingConstraints() {
        var hasVisibleAncestors = false
        for paddingConstraint in self.paddingConstraints {
            let firstPaddingView = paddingConstraint.firstItem as? UIView
            let secondPaddingView = paddingConstraint.secondItem as? UIView
            
            let firstVisible = !(firstPaddingView?.isHidden ?? true) && !(firstPaddingView?.intrinsicContentSize.equalTo(.zero) ?? true)
            let secondVisible = !(secondPaddingView?.isHidden ?? true) && !(secondPaddingView?.intrinsicContentSize.equalTo(.zero) ?? true)
            
            paddingConstraint.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? JSHUD.JSDefaultPadding : 0.0
            hasVisibleAncestors = secondVisible || hasVisibleAncestors
        }
    }
    
    private func applyPriority(_ priority: UILayoutPriority, to constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            constraint.priority = priority
        }
    }
    
    private func updateBezelMotionEffects() {
        if !self.bezelView.responds(to: #selector(addMotionEffect(_:))) {
            return
        }
        
        if self.areDefaultMotionEffectsEnabled {
            let effectOffset: CGFloat = 10.0
            
            let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            effectX.minimumRelativeValue = -(effectOffset)
            effectX.maximumRelativeValue = effectOffset
            
            let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            effectY.minimumRelativeValue = -(effectOffset)
            effectY.maximumRelativeValue = effectOffset
            
            let effectGroup = UIMotionEffectGroup()
            effectGroup.motionEffects = [effectX, effectY]
            
            self.bezelView.addMotionEffect(effectGroup)
        }
        else {
            let effectGroup = self.bezelView.motionEffects
            for effect in effectGroup {
                self.bezelView.removeMotionEffect(effect)
            }
        }
    }
    
    private func updateCurrentOrientationAnimated() {
        // 与父视图保持一致
        if let superview = self.superview {
            self.frame = superview.bounds
        }
    }
    
    // MARK: 时间事件
    @objc private func handleGraceTimer(_ timer: Timer) {
        if !(self.hasFinished) {
            self.showUsingAnimation()
        }
    }
    
    @objc private func handleMinShowTimer(_ timer: Timer) {
        self.hideUsingAnimation()
    }
    
    @objc private func handleHideTimer(_ timer: Timer) {
        self.hideAnimated(timer.userInfo as! Bool)
    }

    // MARK: 进度事件
    private func enableSetProgressDisplayLink(_ enabled: Bool) {
        if enabled && self.progressObject != nil {
            if self.progressObjectDisplayLink == nil {
                let displayLink = CADisplayLink(target: self, selector: #selector(updateProgressFromProgressObject))
                self.progressObjectDisplayLink = displayLink
            }
        }
        else {
            self.progressObjectDisplayLink = nil
        }
    }
    
    @objc private func updateProgressFromProgressObject() {
        self.progress = Float(self.progressObject!.fractionCompleted)
    }
    
    // MARK: 通知事件
    @objc private func statusBarOrientationDidChange(_ notification: Notification) {
        if let _ = self.superview {
            self.updateCurrentOrientationAnimated()
        }
    }
}
