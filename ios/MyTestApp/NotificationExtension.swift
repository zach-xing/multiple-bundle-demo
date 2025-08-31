//
//  NotificationExtension.swift
//  MyTestApp
//
//  Created by Zeekg on 2025/8/31.
//

import Foundation

extension Notification.Name {
  static let bundleLoadingComplete = Notification.Name("bundleLoadingComplete")
  static let rnPageLoaded = Notification.Name("rnPageLoaded")
  static let rnPageClosed = Notification.Name("rnPageClosed")
}
