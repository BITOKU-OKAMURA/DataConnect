//
// sshPtyViewController.swift
// LightWalker
//
// Created by Yoshinori Okamura on 2015/01/05.
// Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit

class sshPtyViewController: ViewController ,UIPickerViewDelegate,UIScrollViewDelegate,UITextViewDelegate {
    
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
     * キーボード入力補助
     *
     */
    let ScrollView = UIScrollView()
    let notificationCenter = NSNotificationCenter.defaultCenter()


    /**
    * 入力用ラベル
    * 
    */
    var label1 : UILabel?

    /**
    * コマンド用テキストフィールド
    *
    */
    var CommandField : UITextField?
        
    /**
    * コマンド用入力ボタン
    *
    */
    var CommandBtn : UIButton? //接続ボタン

    /**
     * コンソール用UITextView
     */
    var _textView = UITextView()
    var KeyHight : CGFloat = 0

    /**
    * 入力画面デザイン
    *
    */
    var DegianY : CGFloat = 35.0
    var DegianHeight : CGFloat  = 24.0

    /**
     * 入力フィールド用UIView
     */
    var InputView = UIView()
    let keyboardDoneButtonView = UIToolbar()

    /**
     * 文字列操作変数
     */
    var BeforeTxt : String!
    var RecivTxt : String = ""
    var Command : String!
    var BeforeLen : Int = 0

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
        //self.navigationItem.leftBarButtonItem =
            //UIBarButtonItem(image:UIImage(named: "icon_list_bullets.png")!, style: .Plain, target: appDelegate.slideMenu , action: "toggleMenu")
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
        //self.view.frame = LayOutCyouSei()

        //----------------------------------------------------------
        // UITextViewの定義
        //----------------------------------------------------------
        //_textView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-40.0)
        _textView.backgroundColor = UIColor.whiteColor()
        _textView.editable = false
        _textView.layer.borderColor = UIColor.blackColor().CGColor
        _textView.layer.borderWidth = 0
        _textView.clipsToBounds = true
        _textView.layer.cornerRadius = 0.0
        _textView.font = UIFont(name:"Cochin-Bold",size:12)
        _textView.delegate = self;
        //_textView.becomeFirstResponder()

        //----------------------------------------------------------
        // InputViewの定義
        //----------------------------------------------------------
        _textView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-40.0)
        InputView.frame = CGRectMake(0, self.view.bounds.height-40.0, self.view.bounds.width, 40.0)
        InputView.backgroundColor = UIColor.lightGrayColor()

        label1 = makeUILabel(CGRectMake(5, 7, 90, 24), text: "Command:")

        CommandField = makeTextField(CGRectMake(90, 7, 160, 24), text: "", tag:3)
        CommandField!.keyboardType = .ASCIICapable

        CommandBtn = makeButton(CGRectMake(254, 7, 40, 24), text: "実行", tag: 0)
        CommandBtn!.addTarget(self, action: "CommandBtnPush:", forControlEvents: UIControlEvents.TouchUpInside)
        InputView.addSubview(label1!)
        InputView.addSubview(CommandField!)
        InputView.addSubview(CommandBtn!)

        //----------------------------------------------------------
        // ViewとDoneボタンの作成
        //----------------------------------------------------------
        keyboardDoneButtonView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40.0)
        keyboardDoneButtonView.barStyle  = .Black
        keyboardDoneButtonView.translucent = true
        keyboardDoneButtonView.tintColor = nil
        self.keyboardDoneButtonView.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "Ctrl+C", style: .Bordered, target: self, action: "CtrlCBtnPush:")], animated: true)
        CommandField!.inputAccessoryView = keyboardDoneButtonView
        

        //----------------------------------------------------------
        // キーボード用のスクロール制御
        //----------------------------------------------------------
        ScrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        ScrollView.backgroundColor = UIColor.clearColor();
        ScrollView.delegate = self;
        
        //----------------------------------------------------------
        // モニター表示
        //----------------------------------------------------------
        self.view.addSubview(ScrollView);
        ScrollView.addSubview(_textView);
        ScrollView.addSubview(InputView);
        BeforeLen = countElements(_textView.text)

        //----------------------------------------------------------
        // 右ボタン
        //----------------------------------------------------------
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: "onClickCLSButton:")

        //----------------------------------------------------------
        // 最初のsshコネクト
        //----------------------------------------------------------
        self.sshPty("")

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
    func textView(textView: UITextView!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool{
        if text == "\n" {
            Command = _textView.text
            Command.removeRange(Command.startIndex..<advance(Command.startIndex, BeforeLen))
        }
        return true
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
        self.navigationItem.titleView = TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))

        //----------------------------------------------------------
        // 広告チェックタイマー ローカルスコープ
        //----------------------------------------------------------
        LCTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "LayoutCheck", userInfo: nil, repeats: true)

        //----------------------------------------------------------
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        PostLayout()

        //----------------------------------------------------------
        // キーボードのスクロール
        //----------------------------------------------------------
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
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
        BeforeTxt = _textView.text
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
        PostLayout()
    }

    /**
    *
    * レイアウトチェック時の微妙な調整
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func PostLayout() {
        self.view.frame = LayOutCyouSei()
        self.ScrollView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height - KeyHight + 40.0)
        self._textView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height - KeyHight-40.0)
        InputView.frame = CGRectMake(0, view.bounds.height - KeyHight-40.0, self.view.bounds.width, 40.0)

    }

    /**
    *
    * PTY通信を行う
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func sshPty(Command : String){
        let _sshWrapper = appDelegate.sshWrapper
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
        SVProgressHUD.showWithStatus("応答を待っています。")
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.RecivTxt = _sshWrapper.sshPtyRrecive(Command)
            NSOperationQueue.mainQueue().addOperationWithBlock(){
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self._textView.text = self._textView.text + self.RecivTxt
                self.BeforeTxt = self._textView.text
                SVProgressHUD.dismiss()
            }
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

            break;
        case 3:

            break;
        case 4:

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
    * 実行を押下した場合の処理
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func CommandBtnPush(btn: UIButton) {
        //----------------------------------------------------------
        // この時点で入力されているものを値の確定とする
        //----------------------------------------------------------
        self.sshPty(String(format: "%@ \n",CommandField!.text))
        CommandField!.text = ""
        CommandField!.resignFirstResponder()
    }

    func CtrlCBtnPush(btn: UIButton) {
        //----------------------------------------------------------
        // Ctrl＋Cを送信
        //----------------------------------------------------------
        self.sshPty("_vannira")
        CommandField!.text = ""
        CommandField!.resignFirstResponder()
    }

    /**
    *
    * クリアボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func onClickCLSButton(btn: UIButton) {
        _textView.text = ""
       self.sshPty("_vannira")
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
                PostLayout()
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
        var screenHeight : CGFloat = 0
        let YokoFLG = UIApplication.sharedApplication().statusBarOrientation.isPortrait 
        if(!YokoFLG){
            screenHeight = (self.view.bounds.width > self.view.bounds.height)  ? self.view.bounds.height : self.view.bounds.width
        } else {
            screenHeight = (self.view.bounds.width > self.view.bounds.height)  ? self.view.bounds.width : self.view.bounds.height
        }
        var txtLimit               = InputView.frame.origin.y + InputView.frame.height 
        let kbdLimit               = screenHeight - (keybordHeight)
        if txtLimit >= kbdLimit {
            ScrollView.contentOffset.y = txtLimit - kbdLimit
        }
        KeyHight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue().size.height
        PostLayout()
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
        KeyHight = 0
        PostLayout()
    }
}
