//
//  Dispatcher.swift
//  Example-Swift
//
//  Created by Hiroshi Kimura on 10/27/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import UIKit
import Radical

public class Dispatcher: RadicalDispatcher {
    public override class var sharedInstance: Dispatcher {
        struct Singleton {
            static let instance = Dispatcher()
        }
        return Singleton.instance
    }
}
