//
//  AppDelegate.swift
//  LightWalker
//
//  Created by Yoshinori Okamura on 2015/01/05.
//  Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

//http://IPADORESS
//smb://IPADORESS/
//ssh://username:passwd@IPADORESS

    /**
     * UIWindowのプロパティ
     * アクセス装飾子の概念は不明だが恐らく何時でも定義可能かと思われる。
     */
    var window: UIWindow?

    /**
     * プレコード:多階層ビューのプロパティ
     * アクセス装飾子の概念は不明だが恐らく何時でも定義可能かと思われる。
     * 実際に扱うのはViewController配下のクラスだが、appDelegateのスコープで扱う
     */
    let ViewTest = ViewTestController()
    let TableTestView = TableTestViewController()
    let DocView = DocViewController()

    /**
     * サンドボクスのパス関連(末尾 / 無し)
     */
    var Document : String!
    var databasePath : String!
    var CachePath : String!
    var UserTMP : String!



    /**
     * スライドメニュー
     */
    let slideMenu  = JWSlideMenuController()

    /**
     * SMBツリービュー
     */
    let _headVC = TreeViewController()

    /**
     * SSH接続 Connectを制御するため試験的にエンジンもDelegateする
     */
    let sshWrapper = SSHWrapper()
    let SSHConnectView = SSHConnectViewController()

    /**
     * お気に入り
     */
    let FavoriteView = FavoriteViewController()

    /**
     * カスタムキャッシュ
     * 
     */
    let customCache = CustomURLCache()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        //----------------------------------------------------------
        // NSUserDefaultsをリセット
        //----------------------------------------------------------
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)

        Document = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        databasePath = Document + "/.database"   //データベース用の領域
        CachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
        UserTMP = NSTemporaryDirectory() + "DConeect"
        let FileManager = NSFileManager.defaultManager()

    //let FileDetail = FileDetailViewController()//作成後、メニューから除外
        //----------------------------------------------------------
        // ビュー生成前に行う処理を実施する場合がインスタンスを定義する
        //----------------------------------------------------------
        //var BL = BL_【プロジェクト名】()
println(String(format: "databasePath:%@",databasePath))
        //----------------------------------------------------------
        // データーベース専用フォルダが無ければ作成し、データベースを初期化
        //----------------------------------------------------------
        if !FileManager.fileExistsAtPath(databasePath) {
            //----------------------------------------------------------
            // フォルダ(Documents/.database)の作成
            //----------------------------------------------------------
            FileManager.createDirectoryAtPath(databasePath, withIntermediateDirectories: true, attributes: nil, error: nil)

            //----------------------------------------------------------
            // リソースに置いているひな形をデータベース領域へコピー
            //----------------------------------------------------------
            let cullentDB : String = "/current.sqlite" as String
            NSData(contentsOfFile:(NSBundle.mainBundle().resourcePath! as String) + cullentDB)!.writeToFile(databasePath + cullentDB , atomically: true)
        }

        //----------------------------------------------------------
        // NSURLCacheと一時ファイルの定義
        //----------------------------------------------------------
        NSURLCache.setSharedURLCache(customCache)
        FileManager.removeItemAtPath(UserTMP, error:nil)
        if !FileManager.fileExistsAtPath(UserTMP) {
            //----------------------------------------------------------
            // フォルダ(Documents/.database)の作成
            //----------------------------------------------------------
            FileManager.createDirectoryAtPath(UserTMP, withIntermediateDirectories: true, attributes: nil, error: nil)
        } else {
            println("TMPフォルダ存在")
        }
        //----------------------------------------------------------
        // iphone6の黒いstatus bar対策
        //----------------------------------------------------------
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)

        //----------------------------------------------------------
        // フロートメニュー
        //----------------------------------------------------------
        slideMenu.addViewController( FavoriteView , withTitle : "お気に入り/接続履歴" , andImage: UIImage(named: "icon_star.png")!)
        slideMenu.addViewController( SSHConnectView , withTitle : "ssh 接続" , andImage: UIImage(named: "icon_lock.png")!)
        slideMenu.addViewController( _headVC , withTitle : "SMB/共有" , andImage: UIImage(named: "icon_display_on.png")!)
        slideMenu.addViewController( DocView , withTitle : "ストレージ" , andImage: UIImage(named: "icon_folder.png")!)

        //----------------------------------------------------------
        // アプリケーション・ウィンドウの定義
        //----------------------------------------------------------
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds) // ウィンドウの幅高さ
        self.window?.backgroundColor = UIColor.grayColor() // ウィンドウの色

        //----------------------------------------------------------
        // 各画面はこのRootViewControllerが基点として制御する。
        //----------------------------------------------------------
        //self.window!.rootViewController = RootViewController()
        self.window!.rootViewController  = slideMenu 
        self.window?.makeKeyAndVisible() // 追加
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        NSFileManager.defaultManager().removeItemAtPath(UserTMP, error:nil)
        self.saveContext()
        self.sshWrapper.closeConnection()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Gate-Web.LightWalker" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("LightWalker", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("LightWalker.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

