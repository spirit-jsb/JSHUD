//
//  JSHUDDelegate.swift
//  JSHUD
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import Foundation

@objc public protocol JSHUDDelegate: NSObjectProtocol {

    @objc optional func hudWasHidden(_ hud: JSHUD)
}
