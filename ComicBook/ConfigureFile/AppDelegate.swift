//
//  AppDelegate.swift
//  ComicBook
//
//  Created by Pavel Murzinov on 13/08/2019.
//  Copyright © 2019 Pavel Murzinov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupCache()
        return true
    }

    private func setupCache() {
        let cache = URLCache.shared
        cache.diskCapacity = 1024 * 1024 * 10
        cache.memoryCapacity = 1024 * 1024 * 5
    }
}

