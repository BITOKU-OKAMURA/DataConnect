//
// DocViewController.swift
// LightWalker
//
// Created by Yoshinori Okamura on 2015/01/05.
// Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit

class DocViewController: ViewController ,UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate {
    
    /**
    * ログで出すクラス名
    * NSLOGは ろぐ 辞書登録済
    * AppDelegateは でり で辞書登録済
    * 下記 ClassNameプロパティの記述は必須
    */
    let ClassName = __FILE__.componentsSeparatedByString("/").last!.componentsSeparatedByString(".swift").first!
    
    /**
    * 広告動作確認タイマー
    *
    */
    var LCTimer : NSTimer!
    
    /**
    * メニューボタン
    *
    */
    var menuButton : UIBarButtonItem!
    
    /**
    * tableView
    */
    var tableView = UITableView()
    
    /**
    * 多分使う変数
    */
    var DirectoryArrays : [String] = []
    var DitailArrays : [Bool] = []
    var userDocumentsPath : String?
    var ConnetcSlash : String!
    var DirectoryDataArrays : [String]!
    var BackBottomFLG : Bool?
    var DataViewArrays : [String] = []

    /**
    * 右メニューボタン
    *
    */
    var RightButton : UIBarButtonItem!
    var EditModeFlag : Bool = false

    /**
    *
    * 削除ボタンのイベント
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventDelete() {
        EditModeFlag = !EditModeFlag
        tableView.reloadData()
    }
    func PushDeleteBtn(btn: UIButton) {
        self.showAlert(DirectoryArrays[btn.tag], text:
            FileManager.removeItemAtPath(String(format: "%@/%@",userDocumentsPath!,DirectoryArrays[btn.tag]), error: nil) ? 
            "削除しました。" : "削除に失敗しました。"
        )
        EditModeFlag = !EditModeFlag
        MakeDirectoryArrays()
    }

    /**
    *
    * ディレクトリ一覧の表示
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func MakeDirectoryArrays(){
        self.DirectoryDataArrays = FileManager.contentsOfDirectoryAtPath(userDocumentsPath!, error: &error) as [String]
        //self.DirectoryDataArrays.removeLast()
        DitailArrays    = []
        DirectoryArrays = []
        DataViewArrays  = []
        //=========================================================================
        //  カレントとアッパーは配列から除外
        //=========================================================================
        for line_args in DirectoryDataArrays {
            let FilePath = String(format: "%@/%@",userDocumentsPath!,line_args)
            if(NSString(string: line_args).substringToIndex(1) != "."){
                FileManager.fileExistsAtPath(FilePath, isDirectory: &isDir)
                DitailArrays.append(Bool(isDir))
                DirectoryArrays.append(line_args)
            }
            if(Bool(isDir) == false){
                DataViewArrays.append(FilePath)
            }
        }
        tableView.reloadData()
    }

    /**
    *
    * loadViewデリゲードのオーバーライド
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func loadView(){
        //----------------------------------------------------------
        // 初期設定
        //----------------------------------------------------------
        //NSLog(ClassName + "::" + __FUNCTION__ + "| ")
        super.loadView()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"// 日付フォーマットの設定
        
        //----------------------------------------------------------
        // TableViewの生成する(status barの高さ分ずらして表示).
        //----------------------------------------------------------
        //tableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.bounces = false
        tableView.separatorColor =  UIColor.hexStr("#F2F2F2", alpha: 1)
        
        //----------------------------------------------------------
        // Cell名の登録をおこなう.
        //----------------------------------------------------------
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //----------------------------------------------------------
        // DataSourceの設定をする.
        //----------------------------------------------------------
        tableView.dataSource = self
        
        //----------------------------------------------------------
        // Delegateを設定する.
        //----------------------------------------------------------
        tableView.delegate = self

        //----------------------------------------------------------
        // 区切り線の幅を調整
        //----------------------------------------------------------
        if self.tableView.respondsToSelector("separatorInset") || self.tableView.respondsToSelector("layoutMargins")  {
            self.tableView.separatorInset = UIEdgeInsetsZero;
        }

        //=========================================================================
        //  右ボタン
        //=========================================================================
        RightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "UseEventDelete")
        self.navigationItem.rightBarButtonItem = RightButton

    }

    func PreLayoutCyousei(){
        self.view.frame = LayOutCyouSei()
        tableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        //----------------------------------------------------------
        // メニューボタン
        //----------------------------------------------------------
        menuButton = UIBarButtonItem(image: UIImage(named: "icon_list_bullets.png"), style: UIBarButtonItemStyle.Plain, target: appDelegate.slideMenu, action: Selector("toggleMenu"))
        self.navigationItem.leftBarButtonItem = (BackBottomFLG == false || self.view.frame.size.width > self.view.frame.size.height) ? menuButton : nil
        self.navigationItem.leftItemsSupplementBackButton  = self.view.frame.size.width > self.view.frame.size.height;
    }
    
    /**
    *
    * viewDidAppearデリゲードのオーバーライド
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func viewDidLoad() {
        //NSLog(ClassName + "::" + __FUNCTION__ + "| ")
        super.viewDidLoad()
        //----------------------------------------------------------
        // 親Virewの定義
        //----------------------------------------------------------
        self.view.backgroundColor = UIColor.whiteColor()

        //----------------------------------------------------------
        // テーブル情報を更新して表示
        //----------------------------------------------------------
        self.view.addSubview(self.tableView)

    }
    
    /**
    *
    * viewDidAppearデリゲードのオーバーライド
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func viewDidAppear(animated: Bool) {
        //NSLog(ClassName + "::" + __FUNCTION__ + "| ")
        super.viewDidAppear(animated)
        
        //----------------------------------------------------------
        // 広告チェックタイマー ローカルスコープ
        //----------------------------------------------------------
        LCTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "LayoutCheck", userInfo: nil, repeats: true)
        

        //----------------------------------------------------------
        // 配列初期設定
        //----------------------------------------------------------
        DitailArrays = []
        DirectoryArrays = []
        DataViewArrays = []

        //=========================================================================
        //  初期呼び出し時の処理
        //=========================================================================
        if (userDocumentsPath == nil) {
            self.title =  "iphoneストレージ"
            userDocumentsPath = appDelegate.Document
            BackBottomFLG = false
        }
        
        //=========================================================================
        //  タイトルの表示
        //=========================================================================
        self.navigationItem.titleView = TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))

        //----------------------------------------------------------
        // ディレクトリ一覧を表示
        //----------------------------------------------------------
        MakeDirectoryArrays()

        //----------------------------------------------------------
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        PreLayoutCyousei()

        SVProgressHUD.dismiss()
    }

    /**
    *
    * viewWillDisappearのオーバーライド
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func viewWillDisappear(animated:Bool) {
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            SVProgressHUD.showWithStatus("お待ちください")
        }))
        super.viewWillDisappear(animated)
        LCTimer.invalidate()
    }
    
    /**
    *
    * didReceiveMemoryWarningのオーバーライド
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func didReceiveMemoryWarning() {
        //NSLog(ClassName + "::" + __FUNCTION__ + "| ")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    *
    * 縦横の回転時に呼び出される
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //----------------------------------------------------------
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        PreLayoutCyousei()
    }
    
    //*********************************************** 以下、UITableView 制御 ***********************************************
    /*
    セクションの数を返す.
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    /*
    セクションのタイトルを返す.
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*
        switch(section) {
        case 0:
        return " タイトル"
        case 1:
        return " タイトル"
        case 2:
        return " タイトル"
        case 3:
        return " タイトル"
        case 4:
        return " タイトル"
        default:
        break
        }
        */
        return ""
    }
    
    /**
    *
    * セクションのごとの列数を決定
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        switch(section) {
        case 0:
        return 1;
        case 1:
        return 1;
        case 2:
        return 1;
        case 3:
        return 1;
        case 4:
        return 1;
        default:
        break;
        }
        */
        return DirectoryArrays.count
    }
    
    /**
    *
    * Cellに値を設定する.
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //----------------------------------------------------------
        // Cellの.を取得する.
        //----------------------------------------------------------
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        //----------------------------------------------------------
        // 区切り線の幅を調整
        //----------------------------------------------------------
        if cell.respondsToSelector("separatorInset") {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        if cell.respondsToSelector("preservesSuperviewLayoutMargins") {
            cell.preservesSuperviewLayoutMargins = false;
        }
        if cell.respondsToSelector("layoutMargins") {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        //----------------------------------------------------------
        // Cellに値を設定する.
        //----------------------------------------------------------
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        //=========================================================================
        // 削除ボタンの作成
        //=========================================================================
        if(EditModeFlag){
            var DeleteBtn : UIButton = makeButton(CGRectMake(self.view.frame.size.width - 44, 8, 40, 24), text: "削除", tag: indexPath.row)
            DeleteBtn.addTarget(self, action: "PushDeleteBtn:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.contentView.addSubview(DeleteBtn)
        }

        //=========================================================================
        // セルの大きさを指定
        //=========================================================================
        let Line = DirectoryArrays[indexPath.row]
        let RequestFilePath = String(format: "%@/%@",userDocumentsPath!,Line)
        let PathExtension = Line.pathExtension
        var CurrentImage :  UIImage!
        cell.textLabel?.text = Line
        cell.textLabel?.font = UIFont.systemFontOfSize(18.0)
        cell.detailTextLabel!.textAlignment = .Left
        cell.detailTextLabel!.font = UIFont.italicSystemFontOfSize(10.0)
        cell.detailTextLabel!.textColor = UIColor.grayColor()
        
        if(DitailArrays[indexPath.row]){
            //=========================================================================
            // フォルダの場合
            //=========================================================================
            CurrentImage = UIImage(named:"Foruda.png")
            cell.accessoryType = EditModeFlag ? UITableViewCellAccessoryType.None : UITableViewCellAccessoryType.DisclosureIndicator
            cell.detailTextLabel!.text =  "";
        } else {
            //=========================================================================
            // ファイルの場合
            //=========================================================================
            if(PathExtension.lowercaseString.rangeOfString("html|htm",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
                CurrentImage = UIImage(named:"WWW5.png")
            } else if(PathExtension.lowercaseString.rangeOfString("gif|jpeg|jpg|bmp|png|tiff",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
                CurrentImage = UIImage(named:"image.png")
            } else  if(PathExtension.lowercaseString.rangeOfString("xls|xlsx",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
                CurrentImage = UIImage(named:"XLS1.png")
            } else  if(PathExtension.lowercaseString.rangeOfString("doc|docx",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
                CurrentImage = UIImage(named:"DOC1.png")
            }else  if(PathExtension.lowercaseString.rangeOfString("ppt|pptx",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
                CurrentImage = UIImage(named:"PPT1.png")
            } else  if(PathExtension.lowercaseString == "pdf"){
                CurrentImage = UIImage(named:"PDF1.png")
            } else if(PathExtension.lowercaseString == "zip"){
                CurrentImage = UIImage(named:"winzip.png")
            } else if(PathExtension.lowercaseString.rangeOfString("m4v|mp4|3gp|mov|qt",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
                CurrentImage = UIImage(named:"Movie.png")
            } else {
                CurrentImage = UIImage(named:"File.png")
            }
            cell.accessoryType = UITableViewCellAccessoryType.None;
            if let attr: NSDictionary = FileManager.attributesOfItemAtPath(RequestFilePath, error:nil) {
                cell.detailTextLabel!.text = String(format: "%@ %@Byte", dateFormatter.stringFromDate(attr.fileModificationDate()!) , Common.KMByteStrings(attr.fileSize()) )
            } else {
                cell.detailTextLabel!.text = ""
            }
        }
        
        //=========================================================================
        // アイコンを整形して表示
        //=========================================================================
        //UIGraphicsBeginImageContext(CGSizeMake(35, 40))
        //CurrentImage.drawInRect(CGRectMake(0, 0, 35, 40))
        //cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        //UIGraphicsEndImageContext()
        cell.imageView?.image = CurrentImage
        return cell
    }
    
    /**
    *
    * Cellをクリックした場合の処理
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath,animated:true)
        //=========================================================================
        // 削除モード中は処理しない
        //=========================================================================
        if(EditModeFlag){
            return
        }
        let RequestFilePath = String(format: "%@/%@",userDocumentsPath!,DirectoryArrays[indexPath.row])
        if(DitailArrays[indexPath.row]){
            let DocView = DocViewController()
            DocView.userDocumentsPath = RequestFilePath
            DocView.title = DirectoryArrays[indexPath.row]
            DocView.BackBottomFLG = true;
            navigationItem.backBarButtonItem = UIBarButtonItem(title: self.title, style: .Plain, target: nil, action: nil)
            self.navigationController.pushViewController(DocView)
        } else {
            //=========================================================================
            // ファイルの場合
            //=========================================================================
            let DetailView = FileDetailViewController()
            DetailView.title = DirectoryArrays[indexPath.row]
            DetailView.NaviWebURL = RequestFilePath

            //=========================================================================
            // 明らかなアーカイブは処理しない
            //=========================================================================
            if(RequestFilePath.pathExtension.lowercaseString == "zip"){
                println(String(format: "Path=%@",RequestFilePath))
                println(String(format: "Dist=%@",userDocumentsPath!))
                SVProgressHUD.showWithStatus("解凍を実施しています。\nしばらくお待ち下さい。")
                //![SSZipArchive unzipFileAtPath:ZipCheckDirectoryPwd toDestination:bl.path]
                NSOperationQueue().addOperation(NSBlockOperation(block: {
                let ZipFLG=SSZipArchive.unzipFileAtPath(RequestFilePath , toDestination:self.userDocumentsPath!)
                    NSOperationQueue.mainQueue().addOperationWithBlock(){
                        if(ZipFLG){
                            self.FileManager.removeItemAtPath(RequestFilePath,error:nil)
                            self.MakeDirectoryArrays()
                            self.showAlert("正常終了", text: "解凍が完了しました。")
                        } else {
                            self.showAlert("エラー", text: "解凍が失敗しました。")
                        }
                        SVProgressHUD.dismiss()
                    }
                }))
                return
            }
            
            
            if(RequestFilePath.pathExtension.lowercaseString.rangeOfString("xz|lzh|zip|cab|tar|gz|tgz|targz|hqx|sit|Z|uu",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
                showAlert("Info:表示/再生不可", text: "ファイル書庫の\n拡張子です")
                return;
            }

            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
                DetailView.DataViewArrays = self.DataViewArrays
            self.navigationController.pushViewController(DetailView)
        }
    }
    
    //*********************************************** 以下、補助画面制御 ***********************************************
    /**
    *
    * 広告読み込み状況の変化を確認してメインスクリーンを調整する
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func LayoutCheck() {
        if (Double(self.view.frame.origin.y) > 0 && !appDelegate.slideMenu.ADactive) ||
            (Double(self.view.frame.origin.y) == 0 && appDelegate.slideMenu.ADactive) {
                //----------------------------------------------------------
                // BetTableEditViewの定義
                //----------------------------------------------------------
                self.view.frame = LayOutCyouSei()
                tableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        }
    }
    
}
