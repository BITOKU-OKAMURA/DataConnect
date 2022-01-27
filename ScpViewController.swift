//
// ScpViewController.swift
// LightWalker
//
// Created by Yoshinori Okamura on 2015/01/05.
// Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit

class ScpViewController: ViewController ,UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate {
    
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
     * tableView
     */
    var tableView = UITableView()

    /**
     * 多分使う変数
     */
    var DirectoryArrays : [String] = []
    var DitailArrays : [String] = []
    var userDocumentsPath : String!
    var ConnetcSlash : String!
    var DirectoryDataArrays : [String] = []
    var BackBottomFLG : Bool = false

    /**
    * 右メニューボタン
    *
    */
    var RightButton : UIBarButtonItem!
    var UpLoadButton : UIBarButtonItem!
    var EditModeFlag : Bool = false

    /**
    * バックボタンブラグ
    *
    */
    var BackBTN : Bool = false

    /**
    *
    * アップロードボタンのイベント
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventUpload() {
        //=========================================================================
        // アップロード
        //=========================================================================
        let UpLoadFile : String = String(format: "%@/%@",countElements(self.userDocumentsPath) == 0 ? "." : self.userDocumentsPath,self.userDefaults.stringForKey("SaveAdress")!.lastPathComponent)
        SVProgressHUD.showWithStatus("お待ちください。")
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            let Megs = self.appDelegate.sshWrapper.scpUpload(self.userDefaults.stringForKey("SaveAdress")!,SCP_FileName : UpLoadFile)
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.currentReload()
                if countElements(Megs) < 1 {
                    self.showAlert("アップロード完了", text:UpLoadFile.lastPathComponent)
                    //---------------------------------------------------------------------
                    // セーブのリセット
                    //---------------------------------------------------------------------
                    self.userDefaults.setObject("", forKey: "SaveAdress")
                    self.userDefaults.synchronize()
                    self.navigationItem.rightBarButtonItem = self.userDefaults.stringForKey("SaveAdress") == "" || self.userDefaults.stringForKey("SaveAdress") == nil ? self.RightButton : self.UpLoadButton
                } else {
                    self.showAlert("アップロード失敗", text:Megs)
                }
                SVProgressHUD.dismiss()
            }
        }))
        
    }

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
        let Taisyou = self.DirectoryArrays[btn.tag]
        SVProgressHUD.showWithStatus("お待ちください")
        var Ret = countElements(String(format: "%@",self.appDelegate.sshWrapper.executeCommand(String(format: "/bin/rm -Rf %@%@%@",self.userDocumentsPath,countElements(self.userDocumentsPath) == 0 ? "" : "/" ,self.DirectoryArrays[btn.tag])))) == 0 ? true : false
        NSOperationQueue().addOperation(NSBlockOperation(block: {
        //=========================================================================
        //  カレントディレクトリの再読み込み
        //=========================================================================
        NSOperationQueue.mainQueue().addOperationWithBlock(){
        self.currentReload()
        self.showAlert(Taisyou, text:
            Ret == true ? "削除しました。" : "削除に失敗しました。"
        )
        self.EditModeFlag = !self.EditModeFlag
                SVProgressHUD.dismiss()
            }
        }))
    }

    /**
    *
    * カレントディレクトリの再読み込み
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func currentReload(){
        //----------------------------------------------------------
        // ディレクトリ一覧を表示
        //----------------------------------------------------------
        self.ConnetcSlash = countElements(self.userDocumentsPath) == 0 ? "" : "/"
        self.DirectoryDataArrays = self.appDelegate.sshWrapper.executeCommand(String(format: "ls -aF %@",self.userDocumentsPath)).componentsSeparatedByString("\n")
        self.DirectoryDataArrays.removeLast()
        self.DirectoryArrays = []
        self.DitailArrays = []

        //=========================================================================
        //  カレントとアッパーは配列から除外
        //=========================================================================
        for line_args in self.DirectoryDataArrays {
            if( line_args != "./" && line_args != "../"){
                if(line_args.substringFromIndex(line_args.endIndex.predecessor()) == "/"){
                    self.DirectoryArrays.append(line_args.substringToIndex(advance(line_args.startIndex, countElements(line_args)-1)))
                    self.DitailArrays.append("")
                }else{
                    let FileName = (line_args.substringFromIndex(line_args.endIndex.predecessor()) != "*") ? line_args : line_args.substringToIndex(advance(line_args.startIndex, countElements(line_args)-1))
                    self.DirectoryArrays.append(FileName)
                    self.DitailArrays.append(self.appDelegate.sshWrapper.scpFileStat(String(format: "%@%@%@",self.userDocumentsPath,self.ConnetcSlash,FileName)))
                }
            }
        }
        self.tableView.reloadData()
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
        //self.view.backgroundColor = UIColor.blueColor() //Viewの背景色

        if(self.userDefaults.stringForKey("SaveAdress") == nil){
            //---------------------------------------------------------------------
            // セーブのリセット
            //---------------------------------------------------------------------
            self.userDefaults.setObject("", forKey: "SaveAdress")
            self.userDefaults.synchronize()
        }

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
        //  ナビゲーションタイトルは遷移前画面で決める
        //=========================================================================
        self.navigationItem.titleView = TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))
        

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
        tableView.reloadData()
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

        //=========================================================================
        //  右ボタン
        //=========================================================================
        RightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "UseEventDelete")
        UpLoadButton = UIBarButtonItem(image:UIImage(named: "icon_save.png")!, style: .Plain, target: self , action: "UseEventUpload")
        self.navigationItem.rightBarButtonItem = self.userDefaults.stringForKey("SaveAdress") == "" || self.userDefaults.stringForKey("SaveAdress") == nil ? RightButton : UpLoadButton

        //----------------------------------------------------------
        // 広告チェックタイマー ローカルスコープ
        //----------------------------------------------------------
        LCTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "LayoutCheck", userInfo: nil, repeats: true)

        //----------------------------------------------------------
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        self.view.frame = LayOutCyouSei()
        tableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        SVProgressHUD.dismiss()

        //----------------------------------------------------------
        // TOPディレクトリのみ再読み込み
        //----------------------------------------------------------
        if(countElements(userDocumentsPath) == 0){
            self.ConnetcSlash = ""
            if(!BackBTN){
                currentReload()
                BackBTN = true
            }
        } else {
            self.ConnetcSlash = "/"
        }

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
        self.view.frame = LayOutCyouSei()
        tableView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
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
        var CurrentImage :  UIImage!
        cell.textLabel?.text = Line
        cell.textLabel?.font = UIFont.systemFontOfSize(18.0)
        cell.detailTextLabel!.textAlignment = .Left
        cell.detailTextLabel!.font = UIFont.italicSystemFontOfSize(10.0)
        cell.detailTextLabel!.textColor = UIColor.grayColor()

        if countElements(DitailArrays[indexPath.row]) == 0  {
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
            CurrentImage = UIImage(named:"File.png")
            cell.accessoryType = UITableViewCellAccessoryType.None;
            cell.detailTextLabel!.text =  DitailArrays[indexPath.row];
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
        let ScpView = ScpViewController()
        if countElements(DitailArrays[indexPath.row]) == 0 {
            ScpView.userDocumentsPath = String(format: "%@%@%@",self.userDocumentsPath,self.ConnetcSlash,DirectoryArrays[indexPath.row])
            ScpView.title = ScpView.userDocumentsPath.lastPathComponent
            //navigationItem.backBarButtonItem = UIBarButtonItem(title: self.title, style: .Plain, target: nil, action: nil)
            SVProgressHUD.showWithStatus("お待ちください。")
            NSOperationQueue().addOperation(NSBlockOperation(block: {
                //----------------------------------------------------------
                // ディレクトリ一覧を表示
                //----------------------------------------------------------
                self.ConnetcSlash = countElements(ScpView.userDocumentsPath) == 0 ? "" : "/"
                ScpView.DirectoryDataArrays = self.appDelegate.sshWrapper.executeCommand(String(format: "ls -aF %@",ScpView.userDocumentsPath)).componentsSeparatedByString("\n")
                    
                    println(String(format: "%@",String(format: "ls -aF %@",ScpView.userDocumentsPath)))
                    
                ScpView.DirectoryDataArrays.removeLast()
                
                //=========================================================================
                //  カレントとアッパーは配列から除外
                //=========================================================================
                for line_args in ScpView.DirectoryDataArrays {
                    if( line_args != "./" && line_args != "../"){
                        if(line_args.substringFromIndex(line_args.endIndex.predecessor()) == "/"){
                            ScpView.DirectoryArrays.append(line_args.substringToIndex(advance(line_args.startIndex, countElements(line_args)-1)))
                            ScpView.DitailArrays.append("")
                        }else{
                            let FileName = (line_args.substringFromIndex(line_args.endIndex.predecessor()) != "*") ? line_args : line_args.substringToIndex(advance(line_args.startIndex, countElements(line_args)-1))
                            ScpView.DirectoryArrays.append(FileName)
                            ScpView.DitailArrays.append(self.appDelegate.sshWrapper.scpFileStat(String(format: "%@%@%@",ScpView.userDocumentsPath,self.ConnetcSlash,FileName)))
                        }
                    }
                }
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    self.navigationController.pushViewController(ScpView)
                }
            }))
        } else {
            //=========================================================================
            // ファイルの場合
            //=========================================================================
            SVProgressHUD.showWithStatus(String(format: "%@を\nダウンロードします。",DirectoryArrays[indexPath.row]))
            self.ConnetcSlash = countElements(self.userDocumentsPath) == 0 ? "" : "/" 
            NSOperationQueue().addOperation(NSBlockOperation(block: {
                let Megs = self.appDelegate.sshWrapper.scpDownload(String(format: "%@%@%@",self.userDocumentsPath,self.ConnetcSlash,self.DirectoryArrays[indexPath.row]))
                NSOperationQueue.mainQueue().addOperationWithBlock(){
                    if countElements(Megs) < 1 {
                        self.showAlert("ダウンロード完了", text:self.DirectoryArrays[indexPath.row])
                    } else {
                        self.showAlert("ダウンロードエラー", text:Megs)
                    }
                    SVProgressHUD.dismiss()
                }
            }))
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
