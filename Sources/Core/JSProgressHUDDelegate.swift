//
//  JSProgressHUDDelegate.swift
//  JSProgressHUD
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import Foundation

@objc public protocol JSProgressHUDDelegate: NSObjectProtocol {

    @objc optional func hudWasHidden(_ hud: JSProgressHUD)
}
