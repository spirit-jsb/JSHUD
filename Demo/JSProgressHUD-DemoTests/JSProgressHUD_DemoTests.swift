//
//  JSProgressHUD_DemoTests.swift
//  JSProgressHUD-DemoTests
//
//  Created by Max on 2018/11/27.
//  Copyright © 2018 Max. All rights reserved.
//

import XCTest
import JSProgressHUD

class JSProgressHUD_DemoTests: XCTestCase, JSProgressHUDDelegate {

    // MARK: 属性
    var hide_expectation: XCTestExpectation?
    var hide_handle: (() -> Void)?

    // MARK: 生命周期
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MAKR: 测试方法
    func test_initialize() {
        XCTAssertNotNil(JSProgressHUD(with: UIView()))
        XCTAssertNotNil(JSProgressHUD(frame: .zero))
        XCTAssertNotNil(JSProgressHUD(with: nil))
    }
    
    func test_non_animated_convenience_hud_presentation() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD.showHUD(addTo: root_view, animated: false)
        
        XCTAssertNotNil(hud, "A HUD should be created.")
        
        js_hud_was_visible(hud, root_view: root_view!)
        
        XCTAssertFalse(hud.bezelView.layer.animationKeys()?.contains("opacity") ?? false, "The opacity should NOT be animated.")
        
        XCTAssertEqual(JSProgressHUD.HUD(for: root_view), hud, "The HUD should be found via the convenience operation.")
        
        XCTAssertTrue(JSProgressHUD.hideHUD(for: root_view, animated: false), "The HUD should be found and removed.")
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
        
        XCTAssertFalse(JSProgressHUD.hideHUD(for: root_view, animated: false), "A subsequent HUD hide operation should fail.")
    }
    
    func test_animated_convenience_hud_presentation() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        self.hide_expectation = self.expectation(description: "The hudWasHidden: delegate should have been called.")
        
        let hud = JSProgressHUD.showHUD(addTo: root_view, animated: true)
        hud.delegate = self
        
        XCTAssertNotNil(hud, "A HUD should be created.")
        
        js_hud_was_visible(hud, root_view: root_view!)
        
        XCTAssertTrue(hud.bezelView.layer.animationKeys()?.contains("opacity") ?? false, "The opacity should be animated.")
        
        XCTAssertEqual(JSProgressHUD.HUD(for: root_view), hud, "The HUD should be found via the convenience operation.")
        
        XCTAssertTrue(JSProgressHUD.hideHUD(for: root_view, animated: true), "The HUD should be found and removed.")
        
        XCTAssertTrue(root_view?.subviews.contains(hud) ?? false, "The HUD should still be part of the view hierarchy.")
        XCTAssertEqual(hud.alpha, 1.0, "The hud should still be visible.")
        XCTAssertEqual(hud.superview, root_view, "The hud should be added to the view.")
        
        XCTAssertTrue(hud.bezelView.layer.animationKeys()?.contains("opacity") ?? false, "The opacity should be animated.")
        
        self.hide_handle = {
            self.js_hud_was_hidden_and_remove(hud, root_view: root_view!)
            XCTAssertFalse(JSProgressHUD.hideHUD(for: root_view, animated: true), "A subsequent HUD hide operation should fail.")
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func test_completion_handle() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        self.hide_expectation = self.expectation(description: "The hudWasHidden: delegate should have been called.")
        let completion_expectation = self.expectation(description: "The completionBlock: should have been called.")
        
        let hud = JSProgressHUD.showHUD(addTo: root_view, animated: true)
        hud.delegate = self
        hud.completionHandle = {
            completion_expectation.fulfill()
        }
        hud.hideAnimated(true)
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func test_bar_progress_mode() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD(with: root_view)
        hud.mode = .barProgress
        root_view?.addSubview(hud)
        hud.showAnimated(false)
        
        js_hud_was_visible(hud, root_view: root_view!)
    
        XCTAssertNotNil(self.js_helper(hud, first_subview_class: JSBarProgressView.self))
        
        XCTAssertTrue(JSProgressHUD.hideHUD(for: root_view, animated: false), "The HUD should be found and removed.")
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_ring_progress_mode() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD(with: root_view)
        hud.mode = .ringProgress
        root_view?.addSubview(hud)
        hud.showAnimated(false)
        
        js_hud_was_visible(hud, root_view: root_view!)
        
        XCTAssertNotNil(self.js_helper(hud, first_subview_class: JSRingProgressView.self))
        
        XCTAssertTrue(JSProgressHUD.hideHUD(for: root_view, animated: false), "The HUD should be found and removed.")
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_sector_progress_mode() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD(with: root_view)
        hud.mode = .sectorProgress
        root_view?.addSubview(hud)
        hud.showAnimated(false)
        
        js_hud_was_visible(hud, root_view: root_view!)
        
        XCTAssertNotNil(self.js_helper(hud, first_subview_class: JSSectorProgressView.self))
        
        XCTAssertTrue(JSProgressHUD.hideHUD(for: root_view, animated: false), "The HUD should be found and removed.")
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_effect_view_order_after_setting_blur_style() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD(with: root_view)
        
        for (index, view) in hud.bezelView.subviews.enumerated() {
            XCTAssert(!view.isKind(of: UIVisualEffectView.self) || index == 0, "Just the first subview should be a visual effect view.")
        }
        
        hud.bezelView.blurStyle = .dark
        
        for (index, view) in hud.bezelView.subviews.enumerated() {
            XCTAssert(!view.isKind(of: UIVisualEffectView.self) || index == 0, "Just the first subview should be a visual effect view even after changing the blurEffectStyle.")
        }
    }
    
    func test_delay_hide() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        self.hide_expectation = self.expectation(description: "The hudWasHidden: delegate should have been called.")
        
        let hud = JSProgressHUD.showHUD(addTo: root_view, animated: true)
        hud.delegate = self
        
        XCTAssertNotNil(hud, "A HUD should be created.")
        
        hud.hideAnimated(false, afterDelay: 2.0)
        
        js_hud_was_visible(hud, root_view: root_view!)
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.js_hud_was_visible(hud, root_view: root_view!)
        }
        
        let hide_check_expectation = self.expectation(description: "Hide check")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.js_hud_was_hidden_and_remove(hud, root_view: root_view!)
            hide_check_expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_delay_hide_did_not_race() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD(with: root_view)
        root_view?.addSubview(hud)
        
        hud.showAnimated(true)
        hud.hideAnimated(true, afterDelay: 0.3)
        
        js_hud_was_visible(hud, root_view: root_view!)
        
        let hide_check_expectation = self.expectation(description: "Hide check")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hud.showAnimated(true)
            hud.hideAnimated(true, afterDelay: 0.3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.js_hud_was_hidden(hud)
                hide_check_expectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        hud.removeFromSuperview()
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_non_animated_hud_reuse() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD(with: root_view)
        root_view?.addSubview(hud)
        hud.showAnimated(false)
        
        XCTAssertNotNil(hud, "A HUD should be created.")
        
        hud.hideAnimated(false)
        hud.showAnimated(false)
        
        js_hud_was_visible(hud, root_view: root_view!)
        
        hud.hideAnimated(false)
        
        hud.removeFromSuperview()
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_un_finished_hiding_animation() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hud = JSProgressHUD.showHUD(addTo: root_view, animated: false)
        
        hud.hideAnimated(true)
        
        hud.bezelView.layer.removeAllAnimations()
        hud.backgroundView.layer.removeAllAnimations()
        
        let hide_check_expectation = self.expectation(description: "Hide check")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.js_hud_was_hidden_and_remove(hud, root_view: root_view!)
            hide_check_expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_animated_immediate_hud_reuse() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        let hide_expectation = self.expectation(description: "The hud should have been hidden.")
        
        let hud = JSProgressHUD(with: root_view)
        root_view?.addSubview(hud)
        hud.showAnimated(true)

        XCTAssertNotNil(hud, "A HUD should be created.")
        
        hud.hideAnimated(true)
        hud.showAnimated(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.js_hud_was_visible(hud, root_view: root_view!)
            
            hud.hideAnimated(false)
            hud.removeFromSuperview()
            
            hide_expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_min_show_time() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        self.hide_expectation = self.expectation(description: "The hudWasHidden: delegate should have been called.")
        
        let hud = JSProgressHUD(with: root_view)
        hud.delegate = self
        hud.removeFromSuperViewWhenHide = true
        hud.minShowTime = 2.0
        root_view?.addSubview(hud)
        hud.showAnimated(true)
        
        XCTAssertNotNil(hud, "A HUD should be created.")
        
        hud.hideAnimated(true)
        
        var checked_after_one_second = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.js_hud_was_visible(hud, root_view: root_view!)
            checked_after_one_second = true
        }
        
        self.hide_handle = {
            XCTAssertTrue(checked_after_one_second)
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_grace_time() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        self.hide_expectation = self.expectation(description: "The hudWasHidden: delegate should have been called.")
        
        let hud = JSProgressHUD(with: root_view)
        hud.delegate = self
        hud.removeFromSuperViewWhenHide = true
        hud.graceTime = 2.0
        root_view?.addSubview(hud)
        hud.showAnimated(true)
        
        XCTAssertNotNil(hud, "A HUD should be created.")
        
        // The HUD should be added to the view but still hidden
        XCTAssertEqual(hud.superview, root_view, "The hud should be added to the view.")
        XCTAssertEqual(hud.alpha, 0.0, "The HUD should not be visible.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(hud.superview, root_view, "The hud should be added to the view.")
            XCTAssertEqual(hud.alpha, 0.0, "The HUD should not be visible.")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.js_hud_was_visible(hud, root_view: root_view!)
            hud.hideAnimated(true)
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    func test_hide_before_grace_time_elapsed() {
        let root_view_controller = UIApplication.shared.keyWindow?.rootViewController
        let root_view = root_view_controller?.view
        
        self.hide_expectation = self.expectation(description: "The hudWasHidden: delegate should have been called.")
        
        let hud = JSProgressHUD(with: root_view)
        hud.delegate = self
        hud.removeFromSuperViewWhenHide = true
        hud.graceTime = 2.0
        root_view?.addSubview(hud)
        hud.showAnimated(true)
        
        XCTAssertNotNil(hud, "A HUD should be created.")
        
        // The HUD should be added to the view but still hidden
        XCTAssertEqual(hud.superview, root_view, "The hud should be added to the view.")
        XCTAssertEqual(hud.alpha, 0.0, "The HUD should not be visible.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(hud.superview, root_view, "The hud should be added to the view.")
            XCTAssertEqual(hud.alpha, 0.0, "The HUD should not be visible.")
            hud.hideAnimated(true)
        }
        
        let hide_check_expectation = self.expectation(description: "Hide check")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.js_hud_was_hidden_and_remove(hud, root_view: root_view!)
            hide_check_expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        js_hud_was_hidden_and_remove(hud, root_view: root_view!)
    }
    
    // MARK: 私有方法
    private func js_hud_was_visible(_ hud: JSProgressHUD, root_view: UIView) {
        repeat {
            XCTAssertEqual(hud.superview, root_view, "The hud should be added to the view.")
            XCTAssertEqual(hud.alpha, 1.0, "The HUD should be visible.")
        }
        while false
    }
    
    private func js_hud_was_hidden(_ hud: JSProgressHUD) {
        repeat {
            XCTAssertEqual(hud.alpha, 0.0, "The hud should be faded out.")
        }
        while false
    }
    
    private func js_hud_was_hidden_and_remove(_ hud: JSProgressHUD, root_view: UIView) {
        repeat {
            XCTAssertFalse(root_view.subviews.contains(hud), "The HUD should not be part of the view hierarchy.")
            XCTAssertNil(hud.superview, "The HUD should not have a superview.")
            js_hud_was_hidden(hud)
        }
        while false
    }
    
    private func js_helper(_ view: UIView, first_subview_class subview_class: AnyClass) -> UIView? {
        for subview in view.subviews {
            if subview.isKind(of: subview_class) {
                return subview
            }
        }
        
        var this_view: UIView? = nil
        
        for subview in view.subviews {
            this_view = self.js_helper(subview, first_subview_class: subview_class)
            if let _ = this_view {
                break
            }
        }
        
        return this_view
    }
    
    // MARK: JSProgressHUDDelegate
    func hudWasHidden(_ hud: JSProgressHUD) {
        if let _hide_handle = self.hide_handle {
            _hide_handle()
        }
        self.hide_handle = nil
        
        self.hide_expectation?.fulfill()
        self.hide_expectation = nil
    }
}
