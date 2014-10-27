//
//  ImageUploadRequest.swift
//  Example-Swift
//
//  Created by Hiroshi Kimura on 10/27/14.
//  Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com). All rights reserved.
//

import UIKit

class ImageUploadRequest: Request {
    init() {
        super.init(url: NSURL(string: "https://app.couples.lv/api/")!)
    }
    class func image(handlers: Handlers) {
        var component = Component(method: .POST, path: "/photos.php")
        component.parameters = ["name":"Muukii"]
        component.taskType = TaskType.Upload
        let image = UIImage(named: "sample.png")
        if let imageData = UIImagePNGRepresentation(image) {
            component.data = UploadData.Data(imageData)
        }
        let shotRequest = ImageUploadRequest()
        shotRequest.component = component
        shotRequest.handlers = handlers
        Dispatcher.sharedInstance.dispath(shotRequest, sessionType: .Default)
    }
    
    class func image2(handlers: Handlers) {
        var component = Component(method: .POST, path: "/photos/create")
        component.parameters = ["session_id":"81048ec8f2d8b69dbb8f7797606911e365bc3cd9",]
        component.taskType = TaskType.Upload
        let image = UIImage(named: "sample.png")
        if let imageData = UIImagePNGRepresentation(image) {
            component.data = UploadData.Data(imageData)
        }
        let shotRequest = ImageUploadRequest()
        shotRequest.component = component
        shotRequest.handlers = handlers
        Dispatcher.sharedInstance.dispath(shotRequest, sessionType: .Background)
    }
}
