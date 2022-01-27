//
// FavoriteViewController.swift
// LightWalker
//
// Created by Yoshinori Okamura on 2015/01/05.
// Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit

class FavoriteViewController: ViewController ,UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate {
    
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
    var FavoriteArrays : [String] = []
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

    //var DeleteBtn : UIButton? //トンネリングボタン

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
        self.showAlert(Common.favorite_titleArray[btn.tag], text:
            Common.DEL_Favorite(Common.favorite_idArray[btn.tag]) ? 
            "削除しました。" : "削除に失敗しました。"
        )
        EditModeFlag = !EditModeFlag
        LocalArray_Favorite()
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
        BackBottomFLG = false

        //=========================================================================
        //  タイトルの表示
        //=========================================================================
        self.navigationItem.titleView = TitleLabel((self.title == nil) ? "お気に入り/接続履歴" : self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))

        //=========================================================================
        //  右ボタン
        //=========================================================================
        RightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "UseEventDelete")
        self.navigationItem.rightBarButtonItem = RightButton

        //----------------------------------------------------------
        // テーブル情報を更新して表示
        //----------------------------------------------------------
        self.view.addSubview(self.tableView)
        
    }
    
    /**
    *
    * Common.Array_Favorite()を呼び出す
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func LocalArray_Favorite(){
        Common.Array_Favorite()
        tableView.reloadData()
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
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        PreLayoutCyousei()

        //----------------------------------------------------------
        // 配列を取得
        //----------------------------------------------------------
        LocalArray_Favorite()

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
        return Common.favorite_titleArray.count
        
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
        // セルの文字を設定
        //=========================================================================
        var Line : String!
        switch(Common.favorite_kubunArray[indexPath.row]) {
        case 0:
            Line = Common.favorite_titleArray[indexPath.row]
            break
        case 1:
            Line =  String(format: "%@@%@",Common.favorite_titleArray[indexPath.row],Common.favorite_uriArray[indexPath.row])
            break
        case 2:
            Line = Common.favorite_titleArray[indexPath.row]
            break
        default:
            Line = Common.favorite_titleArray[indexPath.row]
            break
        }

        //=========================================================================
        // セルの大きさを指定
        //=========================================================================
        let PathExtension = Common.favorite_uriArray[indexPath.row].pathExtension
        var CurrentImage :  UIImage!
        cell.textLabel?.text = Line
        cell.textLabel?.font = UIFont.systemFontOfSize(countElements(Line) > 15 ? 12.0 : 18.0)
        cell.detailTextLabel!.textAlignment = .Left
        cell.detailTextLabel!.font = UIFont.italicSystemFontOfSize(10.0)
        cell.detailTextLabel!.textColor = UIColor.grayColor()
        
        switch(Common.favorite_kubunArray[indexPath.row]) {
        case 0:
            //=========================================================================
            // ファイルの場合
            //=========================================================================
            if(PathExtension.lowercaseString.rangeOfString("html|htm",options: NSStringCompareOptions.RegularExpressionSearch) != nil ||  !Common.MakeFileFLG(Common.favorite_uriArray[indexPath.row])) {
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
            } else {
                CurrentImage = UIImage(named:"File.png")
            }
        case 1:
            CurrentImage = UIImage(named:"SSH1.png")
            break
        case 2:
            CurrentImage = UIImage(named:"Foruda.png")
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }

        //=========================================================================
        // アイコンを整形して表示
        //=========================================================================
        cell.imageView?.image = CurrentImage
        cell.detailTextLabel!.textAlignment = .Left
        cell.detailTextLabel!.font = UIFont.italicSystemFontOfSize(10.0)
        cell.detailTextLabel!.textColor = UIColor.grayColor()
        cell.accessoryType = UITableViewCellAccessoryType.None;
        cell.detailTextLabel!.text =  Common.favorite_uriArray[indexPath.row] 

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

        switch(Common.favorite_kubunArray[indexPath.row]) {
        case 0:
            //=========================================================================
            // ファイルの場合
            //=========================================================================
            let RequestFilePath = Common.MakeFileFLG(Common.favorite_uriArray[indexPath.row]) ? String(format: "%@%@",appDelegate.Document,Common.favorite_uriArray[indexPath.row]) : Common.favorite_uriArray[indexPath.row]
            let DetailView = FileDetailViewController()
            DetailView.title = Common.favorite_titleArray[indexPath.row]
            DetailView.NaviWebURL = RequestFilePath
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
            //ToDo :DataViewArraysを作成する
            
            DetailView.DataViewArrays = []
            self.navigationController.pushViewController(DetailView)
        case 1:
            //----------------------------------------------------------
            // SSH接続情報をセット
            //----------------------------------------------------------
            self.userDefaults.setObject(Common.favorite_uriArray[indexPath.row], forKey: "_ipField")
            self.userDefaults.setObject(Common.favorite_titleArray[indexPath.row], forKey: "_userField")
            self.userDefaults.synchronize()
            self.showAlert("", text: "SSH接続情報を\nセットしました。")
            break
        case 2:
            //----------------------------------------------------------
            // SMB接続情報をセット
            //----------------------------------------------------------
            self.userDefaults.setObject(Common.favorite_uriArray[indexPath.row], forKey: "LastServer")
            self.userDefaults.synchronize()
            self.showAlert("", text: "SMB/共有接続情報を\nセットしました。")
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }


        /*
        let RequestFilePath = String(format: "%@/%@",userDocumentsPath!,FavoriteArrays[indexPath.row])
        if(DitailArrays[indexPath.row]){
        let FavoriteView = FavoriteViewController()
        FavoriteView.userDocumentsPath = RequestFilePath
        FavoriteView.title = FavoriteArrays[indexPath.row]
        FavoriteView.BackBottomFLG = true;
        navigationItem.backBarButtonItem = UIBarButtonItem(title: self.title, style: .Plain, target: nil, action: nil)
        self.navigationController.pushViewController(FavoriteView)
        } else {

        }
        */
    }
    
    //*********************************************** 以下、補助画面制御 ***********************************************

    /**
    *
    * レイアウト調整の処理を一括
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
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
