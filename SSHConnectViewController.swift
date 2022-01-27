//
// SSHConnectViewController.swift
// LightWalker
//
// Created by Yoshinori Okamura on 2015/01/05.
// Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit

class SSHConnectViewController: ViewController ,UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate {
    
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
    * ラベル
    *
    */
    var label2 : UILabel?
    var label3 : UILabel?
    var label4 : UILabel?
    
    /**
    * ベットテーブル項目名称テキストフィールド
    *
    */
    var _ipField : UITextField?
    var _userField : UITextField?
    var _passwordField : UITextField?

    var _ipValue = ""
    var _userValue = ""
    var _passwordValue = ""

    /**
    * 入力ボタン
    *
    */
    var ConnectBtn : UIButton? //接続ボタン
    var DisableBtn : UIButton? //切断ボタン
    var TunnelBtn : UIButton? //トンネリングボタン

    /**
    * 入力画面デザイン
    *
    */
    var DegianY : CGFloat = 35.0
    var DegianHeight : CGFloat  = 200.0

    /**
     * SCP,Pty遷移用tableView
     */
    var tableView = UITableView()

    /**
     * トルネル用入力欄
     */
    var _remote_hostField : UITextField?
    var _local_listenportField : UITextField?
    var mySegcon: UISegmentedControl?
    var mySegconIndex : Int = 0
    var TunnelBtnTag : Int = 0

    /**
     * キーボード入力補助
     *
     */
    let ScrollView = UIScrollView();
    let notificationCenter = NSNotificationCenter.defaultCenter()

    /**
     * SSHコンソールコントローラ
     *
     */
    let sshPtyView = sshPtyViewController()

    /**
     * SCPビューワ
     *
     */
    let ScpView = ScpViewController()

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
        
        //----------------------------------------------------------
        // メニューボタン
        //----------------------------------------------------------
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "icon_list_bullets.png")!, style: .Plain, target: appDelegate.slideMenu , action: "toggleMenu")
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
        // キーボード用のスクロール制御
        //----------------------------------------------------------
        ScrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        ScrollView.backgroundColor = UIColor.clearColor();
        ScrollView.delegate = self;
        self.view.addSubview(ScrollView);

        //----------------------------------------------------------
        // ラベルの定義
        //----------------------------------------------------------
        label2 = makeUILabel(CGRectMake(5, 5, 80, 24), text: "Host/IP:")
        ScrollView.addSubview(label2!)
        label3 = makeUILabel(CGRectMake(5, 34, 80, 24), text: "User:")
        ScrollView.addSubview(label3!)
        label4 = makeUILabel(CGRectMake(5, 63, 80, 24), text: "Password:")
        ScrollView.addSubview(label4!)
        
        //----------------------------------------------------------
        // テキストフィールド
        //----------------------------------------------------------
        _ipField = makeTextField(CGRectMake(90, 5, 160, 24), text: _ipValue, tag:2)
        _ipField!.keyboardType = .URL
        ScrollView.addSubview(_ipField!)
        
        _userField = makeTextField(CGRectMake(90, 34, 160, 24), text: _userValue, tag:3)
        _userField!.keyboardType = .ASCIICapable
        ScrollView.addSubview(_userField!)
        
        _passwordField = makeTextField(CGRectMake(90, 63, 160, 24), text: _passwordValue, tag:4)
        _passwordField!.keyboardType = .ASCIICapable
        _passwordField!.secureTextEntry = true
        ScrollView.addSubview(_passwordField!)
        
        //----------------------------------------------------------
        // 入力ボタン
        //----------------------------------------------------------
        ConnectBtn = makeButton(CGRectMake(5, 94, 40, 24), text: "接続", tag: 0)
        ConnectBtn!.addTarget(self, action: "ConnectBtnPush:", forControlEvents: UIControlEvents.TouchUpInside)
        ScrollView.addSubview(ConnectBtn!)

        //----------------------------------------------------------
        // 切断ボタン
        //----------------------------------------------------------
        DisableBtn = makeButton(CGRectMake(50, 94, 40, 24), text: "切断", tag: 0)
        DisableBtn!.addTarget(self, action: "DisableBtnPush:", forControlEvents: UIControlEvents.TouchUpInside)
        DisableBtn!.enabled = false;
        DisableBtn!.alpha = 0.3;
        ScrollView.addSubview(DisableBtn!)

        //----------------------------------------------------------
        // TableViewの生成する(status barの高さ分ずらして表示).
        //----------------------------------------------------------
        tableView.frame = CGRectMake(0, DegianY, self.view.bounds.width, DegianHeight)
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
    override func viewDidAppear(animated: Bool) {
        //NSLog(ClassName + "::" + __FUNCTION__ + "| ")
        super.viewDidAppear(animated)
        
        //----------------------------------------------------------
        // タイトルと色を定義
        //----------------------------------------------------------
        self.title = ConnectBtn!.enabled ? countElements(appDelegate.slideMenu.CurrentTitle) > 0 ? appDelegate.slideMenu.CurrentTitle : "" : String(format: "接続:%@",_ipValue)
        self.navigationItem.titleView = TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))

        //----------------------------------------------------------
        // 広告チェックタイマー ローカルスコープ
        //----------------------------------------------------------
        LCTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "LayoutCheck", userInfo: nil, repeats: true)
        
        //----------------------------------------------------------
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        self.view.frame = LayOutCyouSei()
        ScrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        tableView.frame = CGRectMake(0, DegianY, self.view.bounds.width, DegianHeight)

        //----------------------------------------------------------
        // キーボードのスクロール
        //----------------------------------------------------------
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)

        //----------------------------------------------------------
        // 履歴のセットと内部のリセット
        //----------------------------------------------------------
        _ipField!.text = self.userDefaults.stringForKey("_ipField")? == nil ? "" : self.userDefaults.stringForKey("_ipField")!
        _userField!.text = self.userDefaults.stringForKey("_userField")? == nil ? "" : self.userDefaults.stringForKey("_userField")!
        _passwordField!.text = ""
        //self.userDefaults.setObject("", forKey: "_ipField")
        //self.userDefaults.setObject("", forKey: "_userField")
        //self.userDefaults.synchronize()
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
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
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
        ScrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        tableView.frame = CGRectMake(0, DegianY, self.view.bounds.width, DegianHeight)
    }

    //*********************************************** 以下、能動画面制御 ***********************************************

    /**
    *
    * 切断を押下した場合の処理
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func DisableBtnPush(btn: UIButton) {
        appDelegate.sshWrapper.closeConnection()
        showAlert(_ipValue, text:"SSH接続を切断しました。")
        //----------------------------------------------------------
        // 切断に成功したのでタイトルを変更
        //----------------------------------------------------------
        self.title = "ssh 接続"
        self.navigationItem.titleView = TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))
        DisableBtn!.enabled = false;
        DisableBtn!.alpha = 0.3;
        ConnectBtn!.enabled = true;
        ConnectBtn!.alpha = 1.0;
        tableView.reloadData()
        tableView.removeFromSuperview()
        //----------------------------------------------------------
        // ラベルの定義
        //----------------------------------------------------------
        ScrollView.addSubview(label2!)
        ScrollView.addSubview(label3!)
        ScrollView.addSubview(label4!)
        //----------------------------------------------------------
        // テキストフィールド
        //----------------------------------------------------------
        ScrollView.addSubview(_ipField!)
        ScrollView.addSubview(_userField!)
        ScrollView.addSubview(_passwordField!)
        ConnectBtn!.frame = CGRectMake(5, 94, 40, 24)
        DisableBtn!.frame = CGRectMake(50, 94, 40, 24)

        //----------------------------------------------------------
        // 変数リセット
        //----------------------------------------------------------
        self.userDefaults.setObject("", forKey: "ConnectServer")
        self.userDefaults.synchronize()
    }

    /**
    *
    * 接続を押下した場合の処理
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func ConnectBtnPush(btn: UIButton) {
        //----------------------------------------------------------
        // この時点で入力されているものを値の確定とする
        //----------------------------------------------------------
        _ipValue = _ipField!.text
        _userValue = _userField!.text
        _passwordValue = _passwordField!.text
        var Megs : String!
        //----------------------------------------------------------
        // 入力チェック
        //----------------------------------------------------------
        if countElements(_ipValue) < 1 || countElements(_userValue) < 1 || countElements(_passwordValue) < 1  {
            let alert = UIAlertView()
            alert.title = "以下項目を入力"
            alert.message = String(format: "%@%@%@" , countElements(_ipValue) > 0 ? "" : "Host\n" , countElements(_userValue) > 0 ? "" : "Username\n" ,countElements(_passwordValue) > 0 ? "" : "Password\n" )
            alert.addButtonWithTitle("OK")
            alert.show()
            return;
        }

        //----------------------------------------------------------
        // 接続動作と接続判定
        //----------------------------------------------------------
        SVProgressHUD.showWithStatus(String(format: "%@に\nログインします。",self._ipValue))
        NSOperationQueue().addOperation(NSBlockOperation(block: {
        Megs = self.appDelegate.sshWrapper.connectToHost(self._ipValue,port:22,user:self._userValue,password:self._passwordValue,error:nil)
        NSOperationQueue.mainQueue().addOperationWithBlock(){
        if countElements(Megs) < 1 {
            //Ptyモード
            //self.sshPty()
            //----------------------------------------------------------
            // トンネリングボタンの復活
            //----------------------------------------------------------
            //TunnelBtn!.enabled = true;
            //TunnelBtn!.alpha = 1.0;

            //----------------------------------------------------------
            // 接続に成功したのでタイトルを変更
            //----------------------------------------------------------
            self.title = String(format: "接続:%@",self._ipValue)
            self.navigationItem.titleView = self.TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))
            self.ConnectBtn!.enabled = false;
            self.ConnectBtn!.alpha = 0.3;
            self.DisableBtn!.enabled = true;
            self.DisableBtn!.alpha = 1.0;
            //----------------------------------------------------------
            // ラベルの定義
            //----------------------------------------------------------
            self.label2!.removeFromSuperview()
            self.label3!.removeFromSuperview()
            self.label4!.removeFromSuperview()
            //----------------------------------------------------------
            // テキストフィールド
            //----------------------------------------------------------
            self._ipField!.removeFromSuperview()
            self._userField!.removeFromSuperview()
            self._passwordField!.removeFromSuperview()
            self.ConnectBtn!.frame = CGRectMake(5, 5, 40, 24)
            self.DisableBtn!.frame = CGRectMake(50, 5, 40, 24)
            self.tableView.reloadData()
            self.ScrollView.addSubview(self.tableView)

            //----------------------------------------------------------
            // サーバアドレスの共有
            //----------------------------------------------------------
            // キー: "ConnectServer" , 値: "<_ipValueの入力値>" を格納。（idは任意）
            self.userDefaults.setObject(self._ipValue, forKey: "ConnectServer")
            self.userDefaults.synchronize()

            //----------------------------------------------------------
            // 履歴テーブルの登録
            //----------------------------------------------------------
            if ( CommonFunction().DB_SSHConnect(self._ipValue,Title:self._userValue) == true ){
                self.showAlert(self._ipValue, text: "SSH接続履歴に\n登録ました。")
            }

        } else {
            self.showAlert("接続エラー", text:Megs)
        }
        SVProgressHUD.dismiss()
        }
        }))
    }

    /**
    *
    * トンネリングを確立する
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func TunnelBtnPush(btn: UIButton) {
        let LPort  = Int32(_local_listenportField!.text.toInt()!)
        self.sshTunnering(_ipValue,local_host: "127.0.0.1",local_listenport: LPort,remote_host:_remote_hostField!.text ,remote_destport: LPort ,direct:Int32(mySegconIndex))
        self.showAlert("Info", text:"トンネリング接続\n開始しました。")
        TunnelBtn!.enabled = false;
        _remote_hostField!.enabled = false;
        _local_listenportField!.enabled = false;
        mySegcon!.enabled = false;
        TunnelBtn!.alpha = 0.3;
        _remote_hostField!.alpha = 0.7;
        _local_listenportField!.alpha = 0.7;
        mySegcon!.alpha = 0.3;

    }

    /**
    *
    * トンネリングを確立する
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func sshTunnering(server:String , local_host:String , local_listenport:Int32 , remote_host:String , remote_destport:Int32 , direct:Int32) {
        //textField.resignFirstResponder()
        self.view.endEditing(true);
        let _sshWrapper = appDelegate.sshWrapper
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            if(!_sshWrapper.portForward(server,
                local_host: local_host,
                local_listenport: local_listenport,
                remote_host: remote_host,
                remote_destport: remote_destport , aport:direct)){
                //----------------------------------------------------------
                // 接続断
                //----------------------------------------------------------
                //self.appDelegate.sshWrapper.closeConnection()
                self.showAlert("通信エラー", text:"トンネリングの通信内容に\n問題が発生。\nチャネルを切断しました。")
            }
        }))
    }

    /**
    *
    * 編集完了後（完了直後）
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func textFieldDidEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField.tag{
        case 1:
            break;
        case 2:
            _ipValue = textField.text
            break;
        case 3:
            _userValue = textField.text
            break;
        case 4:
            _passwordValue = textField.text
            break;
        default:
            // 上記以外
            break;
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     *
     * ["双方","片方"]
     *
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func mySegconChanged(segcon: UISegmentedControl){
        mySegconIndex = segcon.selectedSegmentIndex

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
        return 2
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
        
        switch(section) {
            case 0:
                return ConnectBtn!.enabled ? "" : String(format: "・%@の操作",_ipValue)
            case 1:
                return ConnectBtn!.enabled ? "" : "・トンネリング"
            case 2:
                return " タイトル"
            case 3:
                return " タイトル"
            case 4:
                return " タイトル"
            default:
            break
        }
        
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
        switch(section) {
            case 0:
                return 2;
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
    return 1
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

        //----------------------------------------------------------
        // 項目の表示
        //----------------------------------------------------------
        switch ( indexPath.section ) {
            case 0:
                switch ( indexPath.row ) {
                case 0:
                    cell.textLabel?.text = "SCP Viewer"
                    cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                break
                case 1:
                    cell.textLabel?.text = "Command Terminal"
                    cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                break
                default:
                break
                }
                break
                case 1:
                switch ( indexPath.row ) {
                case 0:
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    //----------------------------------------------------------
                    // 入力ボタン
                    //----------------------------------------------------------
                    _remote_hostField = makeTextField(CGRectMake(5, 5, 140, 24), text: "127.0.0.1", tag:6)
                    _remote_hostField!.keyboardType = .URL
                    cell.contentView.addSubview(_remote_hostField!)
                    _local_listenportField = makeTextField(CGRectMake(147, 5, 55, 24), text: "139", tag:5)
                    _local_listenportField!.keyboardType = .NumberPad
                    cell.contentView.addSubview(_local_listenportField!)
                    TunnelBtn = makeButton(CGRectMake(275, 5, 40, 24), text: "接続", tag: TunnelBtnTag)
                    TunnelBtn!.addTarget(self, action: "TunnelBtnPush:", forControlEvents: UIControlEvents.TouchUpInside)
                    mySegcon = makeSegmentedControl(CGRectMake(206, 5, 66, 24), myArray: ["双方","片方"])
                    mySegcon!.addTarget(self, action: "mySegconChanged:", forControlEvents: UIControlEvents.ValueChanged)
                    mySegcon!.selectedSegmentIndex = mySegconIndex
                    cell.contentView.addSubview(mySegcon!)
                    cell.contentView.addSubview(TunnelBtn!)
                break
                default:
                break
                }
            default:
            break
        }
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
        switch ( indexPath.section ) {
            case 0:
                switch ( indexPath.row ) {
                case 0:
                    ScpView.title=self.title
                    //----------------------------------------------------------
                    // 次の画面のバックボタン
                    //----------------------------------------------------------
                    ScpView.userDocumentsPath = ""
                    ScpView.title=self.title
                    ScpView.BackBTN = false
                    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
                    SVProgressHUD.showWithStatus("お待ちください。")
                    NSOperationQueue().addOperation(NSBlockOperation(block: {
                    /*
                        //----------------------------------------------------------
                        // ディレクトリ一覧を表示
                        //----------------------------------------------------------
                        let ConnetcSlash = countElements(self.ScpView.userDocumentsPath) == 0 ? "" : "/"
                        self.ScpView.DirectoryDataArrays = self.appDelegate.sshWrapper.executeCommand(String(format: "ls -aF ~",self.ScpView.userDocumentsPath)).componentsSeparatedByString("\n")
                        self.ScpView.DirectoryDataArrays.removeLast()
                        //=========================================================================
                        //  カレントとアッパーは配列から除外
                        //=========================================================================
                        for line_args in self.ScpView.DirectoryDataArrays {
                            if( line_args != "./" && line_args != "../"){
                                if(line_args.substringFromIndex(line_args.endIndex.predecessor()) == "/"){
                                    self.ScpView.DirectoryArrays.append(line_args.substringToIndex(advance(line_args.startIndex, countElements(line_args)-1)))
                                    self.ScpView.DitailArrays.append("")
                                }else{
                                    let FileName = (line_args.substringFromIndex(line_args.endIndex.predecessor()) != "*") ? line_args : line_args.substringToIndex(advance(line_args.startIndex, countElements(line_args)-1))
                                    self.ScpView.DirectoryArrays.append(FileName)
                                    self.ScpView.DitailArrays.append(self.appDelegate.sshWrapper.scpFileStat(String(format: "%@%@%@",self.ScpView.userDocumentsPath,ConnetcSlash,FileName)))
                                }
                            }
                        }
                    */
                        NSOperationQueue.mainQueue().addOperationWithBlock(){
                            self.navigationController.pushViewController(self.ScpView)
                        }
                    }))

                break
                case 1:
                    sshPtyView.title=self.title
                    //----------------------------------------------------------
                    // 次の画面のバックボタン
                    //----------------------------------------------------------
                    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
                    self.navigationController.pushViewController(sshPtyView)
                break
                default:
                break
                }
                break
                case 1:
                switch ( indexPath.row ) {
                case 0:
                break
                default:
                break
                }
            default:
            break
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
            ScrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
            tableView.frame = CGRectMake(0, DegianY, self.view.bounds.width, DegianHeight)
        }
    }

    /**
    *
    * キーボードと入力欄が被らないようにする
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        let userInfo               = notification.userInfo!
        let keybordHeight = (self.view.bounds.width > self.view.bounds.height) ? (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue().size.width :  (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue().size.height
        let screenHeight = (self.view.bounds.width > self.view.bounds.height)  ? UIScreen.mainScreen().bounds.width : UIScreen.mainScreen().bounds.height
        var txtLimit               = ConnectBtn!.enabled ? _passwordField!.frame.origin.y + _passwordField!.frame.height  : tableView.frame.origin.y + tableView.frame.height
        let kbdLimit               = screenHeight - keybordHeight
        if txtLimit >= kbdLimit {
            //println(String(format: "移動量=%d",Int(txtLimit - kbdLimit)))
            ScrollView.contentOffset.y = txtLimit - kbdLimit + 44
        }
    }
    /**
    *
    * キーボード入力後元に戻す
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        ScrollView.contentOffset.y = 0
    }
}
 