//
//  AppDelegate.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 27/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

var pushtoken = "unknown"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		UINavigationBar.appearance().tintColor = UIColor(hex: 0x2C3E50)

        let upvoteAction = UIMutableUserNotificationAction()
        upvoteAction.identifier = Vote.up.rawValue
        upvoteAction.title = "👍"
        upvoteAction.activationMode = .background

        let downvoteAction = UIMutableUserNotificationAction()
        downvoteAction.identifier = Vote.down.rawValue
        downvoteAction.title = "👎"
        downvoteAction.activationMode = .background

        let quoteCategory = UIMutableUserNotificationCategory()
        quoteCategory.identifier = "quote_category"
        quoteCategory.setActions([upvoteAction, downvoteAction], for: .default)

        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: [quoteCategory])
        application.registerUserNotificationSettings(notificationSettings)

		return true
	}

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        defer { completionHandler() }

        guard
            let identifier = identifier,
            let voteAction = Vote(rawValue: identifier),
            let voteIdStr = userInfo["quote_id"] as? String,
            let voteId = Int(voteIdStr)
        else { return }

        Bash.voteQuote(voteId, type: voteAction) { _ in
            application.applicationIconBadgeNumber = 0
        }
    }

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        application.applicationIconBadgeNumber = 0
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		switch shortcutItem.type {
		case "io.kilian.bash.fsr.add":
			let mainVC = self.window?.rootViewController?.childViewControllers[0] as? BashViewController
			mainVC?.performSegue(withIdentifier: "showAddQuote", sender: nil)
			completionHandler(true)
		default:
			completionHandler(false)
		}
	}

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        pushtoken = tokenString
//        print("Device Token: \(tokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register:", error)
    }
}
