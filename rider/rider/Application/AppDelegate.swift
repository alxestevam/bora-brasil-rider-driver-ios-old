//
//  AppDelegate.swift
//  Rider
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import UIKit
import Kingfisher
import SocketIO
import FirebaseCore
import FirebaseInstanceID

@_exported import Firebase
@_exported import FirebaseUI
@_exported import GooglePlaces
@_exported import Reachability
@_exported import FirebaseCrashlytics


//MARK: Global Properties
let appD = UIApplication.shared.delegate as! AppDelegate


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var info : [String:Any] {
        get {
            let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
            return NSDictionary(contentsOfFile: path) as! [String: Any]
        }
    }
    static var singlePointMode : Bool {
        get {
            return AppDelegate.info["SinglePointMode"] as! Bool
        }
    }
    static var maximumDestinations : Int {
        get {
            return AppDelegate.info["MaximumDestinations"] as! Int
        }
    }
    var window: UIWindow?
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FUIAuth.defaultAuthUI()?.auth?.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        FUIAuth.defaultAuthUI()?.auth?.canHandleNotification(userInfo)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        if url.scheme?.localizedCaseInsensitiveCompare(Bundle.main.bundleIdentifier! + ".payments") == .orderedSame {
//            return BTAppSwitch.handleOpen(url, options: options)
//        }
        return (FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: nil))!
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.setupFirebase()
        self.setupGooglePlacesAPI()
        self.setupLanguage()
        self.setupMonitorConnection()
        self.launchOptions = launchOptions
        self.window?.tintColor = UIColor(hex: 0x0A0A32)
        //BTAppSwitch.setReturnURLScheme(Bundle.main.bundleIdentifier! + ".payments")
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        setupLayout()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        LoadingOverlay.shared.hideOverlayView()
        SocketNetworkDispatcher.instance.disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        guard let token = UserDefaultsConfig.jwtToken else {
            return
        }
        LoadingOverlay.shared.showOverlay(view: self.window?.rootViewController?.presentedViewController?.view)
        InstanceID.instanceID().instanceID { (result, error) in
            SocketNetworkDispatcher.instance.connect(namespace: .Rider, token: token, notificationId: result?.token ?? "") { result in
                LoadingOverlay.shared.hideOverlayView()
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: .connectedAfterForeground, object: nil)
                    
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    //MARK: Setup
    private func setupLayout() {
        #if DEBUG || STAG
            print("DEBUG OR STAG")
        #elseif PROD || RELEASE
            print("PROD OR RELEASE")
        #endif

    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupGooglePlacesAPI() {
        GMSPlacesClient.provideAPIKey("AIzaSyCXgycKGXvt1Su0zw6ZuPNICQJHfI-4Zc4")
    }
    
    private func setupLanguage() {
        UserDefaults.standard.set(["pt-br"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    private func setupMonitorConnection() {
        ConnectionUtil.shared.observeReachability()
    }
}


