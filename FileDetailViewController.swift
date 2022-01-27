//
//  FileDetailViewController.swift
//  LightWalker
//
//  Created by Yoshinori Okamura on 2015/01/05.
//  Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit
class FileDetailViewController: ViewController,UIWebViewDelegate,UIScrollViewDelegate,UISearchBarDelegate,UITextViewDelegate{
    
    /**
    * ログで出すクラス名
    * NSLOGは ろぐ 辞書登録済
    * AppDelegateは でり で辞書登録済
    * 下記 ClassNameプロパティの記述は必須
    */
    let ClassName = __FILE__.componentsSeparatedByString("/").last!.componentsSeparatedByString(".swift").first!
    
    /**
    * 最終呼び出しURL
    *
    */
    var NaviWebURL : String!
    
    /**
    * HOMEサイトURL(フォームロード時に決定)
    *
    */
    var HOMEURL : String!
    
    /**
    * 前回リクエストしたURLを記載(Referer用)
    *
    */
    var RefererAdress : String?
    
    /**
    * Webビュー
    *
    */
    let _webView = UIWebView() //Webビュー
    
    /**
    * ローディングフラグ
    *
    */
    var LoadFLAG : Bool?
    
    /**
    * 広告動作確認タイマー
    *
    */
    var LCTimer : NSTimer!
    
    /**
    * 右メニューボタン
    *
    */
    var RightButton : UIBarButtonItem!
    var SaveButton  : UIBarButtonItem!
    
    /**
    * 下部ツールバー
    *
    */
    let NaviWebToolBar = UIToolbar()
    var reload_btn : UIBarButtonItem!
    var home_btn   : UIBarButtonItem!
    var cancel_btn : UIBarButtonItem!
    var modoru_btn : UIBarButtonItem!
    var susumu_btn   : UIBarButtonItem!
    var up_btn : UIBarButtonItem!
    var down_btn : UIBarButtonItem!
    var favorite_btn : UIBarButtonItem!
    
    /**
    * ヒストリーテーブル
    *
    */
    var HistoryTable : [String] = []
    var history_args : Int = 0
    var HistoryFLAG : Bool = false
    var AsciiString : NSString?
    
    
    /**
    * データビューテーブル
    *
    */
    var DataViewArrays : [String]!
    var dataview_args : Int = 0
    var FileViewTable : [String] = []
    
    /**
    * UIScrollView
    *
    */
    //var scrollView : UIScrollView?
    var scrollBeginingPoint: CGPoint!
    var ScrollFLG : Bool?
    
    /**
    * 検索バー
    *
    */
    var searchBar = UISearchBar()
    var serchText : String?
    var serchFLG : Bool?

    /**
     * キーボード入力補助
     *
     */
    let ScrollView = UIScrollView()
    let notificationCenter = NSNotificationCenter.defaultCenter()

    /**
     * コンソール用UITextView
     */
    var _textView = UITextView()
    let keyboardDoneButtonView = UIToolbar()
    var KeyHight : CGFloat = 0
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
        // self.view.backgroundColor = UIColor.blueColor() //Viewの背景色
    }
    
    /**
    *
    * ストップボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventWebCancel(){
        HistoryFLAG = false
        LoadingStop()
        _webView.stopLoading()
    }
    
    /**
    *
    * ホームボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventWebHome() {
        UseEventWebCancel()
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.HOMEURL)
        }))
    }
    
    /**
    *
    * リロードボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventWebReload(){
        UseEventWebCancel()
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.NaviWebURL)
        }))
    }
    
    /**
    *
    * フォワードボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventWebForward(){
        let rows = self.history_args
        if(HistoryTable.count  < (rows + 1) ) {
            return
        }
        UseEventWebCancel()
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.HistoryTable[rows])
            self.history_args++
        }))
    }
    
    /**
    *
    * バックボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventWebBack(){
        let rows = self.history_args-2
        if(rows < 0) {
            return
        }
        UseEventWebCancel()
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.HistoryTable[rows])
            self.history_args--
            if (self.history_args < 0){
                self.history_args = 0
            }
        }))
    }
    
    /**
    *
    * アップボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventFileUp(){
        let rows = dataview_args + 1
        if(FileViewTable.count  < rows + 1 ) {
            return
        }
        UseEventWebCancel()
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.FileViewTable[rows])
            self.dataview_args++
        }))
    }

    /**
    *
    * ダウンボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventFileDown(){
        let rows = self.dataview_args - 1
        if(rows < 0) {
            return
        }
        UseEventWebCancel()
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.FileViewTable[rows])
            self.dataview_args--
            if (self.dataview_args < 0){
                self.dataview_args = 0
            }
        }))
    }

    /**
    *
    * お気に入りボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventFavorite(){
        let SetTitle = (countElements(self.title!) < 1) ? NaviWebURL.lastPathComponent : self.title!
        if ( Common.DB_Favorite(NaviWebURL,Title:SetTitle) == false ){
            showAlert("登録エラー", text: "お気に入り登録\n失敗しました。")
        } else {
            showAlert(SetTitle, text: "お気に入りに\n登録ました。")
        }
    }

    /**
    *
    * 検索ボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func NaviSearchBarView() {
        if(serchFLG == true){
            serchFLG = false
            self.title = searchBar.text!
            self.navigationItem.titleView = TitleLabel(countElements(self.title!) < 13 ? self.title! : String((self.title! as NSString).substringToIndex(12)) , Color : UIColor.hexStr("#FAFAFA", alpha: 1))
            self.navigationItem.rightBarButtonItems = Common.MakeFileFLG(NaviWebURL) ? [RightButton,SaveButton] : [RightButton]
        } else {
            serchFLG = true
            searchBar.frame = CGRectMake(0, 12, self.view.bounds.width * 0.65, 32.0);
            self.navigationItem.titleView = searchBar;
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "NaviSearchBarView")
        }
    }

    /**
    *
    * セーブボタン
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func UseEventSavePath() {
        if(self.AsciiString != nil && self._textView.text != AsciiString && !self._textView.hidden){
            if(NSFileManager.defaultManager().createFileAtPath(NaviWebURL,contents:self._textView.text.dataUsingEncoding(NSUTF8StringEncoding), attributes:nil)){
                showAlert("保存完了", text: "上書き保存しました。")
                AsciiString = self._textView.text
            } else {
                showAlert("保存失敗", text: "変更は反映されません。")
            }
                return 
            }
        // キー: "ConnectServer" , 値: "<_ipValueの入力値>" を格納。（idは任意）
        self.userDefaults.setObject(NaviWebURL, forKey: "SaveAdress")
        self.userDefaults.synchronize()
        showAlert("アップロード予約", text: "任意のフォルダで右上の\n同じアイコンをタップ")
    }

    /**
    *
    * 検索バー
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        serchText = searchText
    }

    /**
    *
    * Cancelボタンが押された時に呼ばれる
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        serchText = ""
        
    }

    /**
    *
    * Searchボタンが押された時に呼ばれる
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if serchText == nil || countElements(serchText!) < 1 {
            return
        }
        //----------------------------------------------------------
        // (WebContentsLoading)能動コンテンツロードを実施。要バックグラウンド
        //----------------------------------------------------------
        appDelegate.customCache.RefererAdress = ""
        HistoryFLAG = true
        self.searchBar.resignFirstResponder()

        NaviWebURL = Common.MakeFileFLG(self.serchText!) ? String(format: "http://www.google.co.jp/m/search?q=%@",self.serchText!).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)! : self.serchText!
        SVProgressHUD.showWithStatus(String(format: "%@\nから読み込んでいます。",NaviWebURL.componentsSeparatedByString("://")[1].componentsSeparatedByString("/")[0]))
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.NaviWebURL)

        }))
    }

    /**
    *
    * 完了ボタンが押された時に呼ばれる
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func doneBtnClicked() {
        _textView.resignFirstResponder()
    }

    /**
    *
    * キーボードの編集終了
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
        // UITextViewの定義
        //----------------------------------------------------------
        //_textView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height-40.0)
        _textView.backgroundColor = UIColor.whiteColor()
        _textView.editable = true
        _textView.layer.borderColor = UIColor.blackColor().CGColor
        _textView.layer.borderWidth = 0
        _textView.clipsToBounds = true
        _textView.layer.cornerRadius = 0.0
        _textView.delegate = self

        //----------------------------------------------------------
        // ViewとDoneボタンの作成
        //----------------------------------------------------------
        keyboardDoneButtonView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40.0)
        keyboardDoneButtonView.barStyle  = .Black
        keyboardDoneButtonView.translucent = true
        keyboardDoneButtonView.tintColor = nil
        self.keyboardDoneButtonView.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),UIBarButtonItem(title: "完了", style: .Plain, target: self, action: "doneBtnClicked")], animated: true)
        _textView.inputAccessoryView = keyboardDoneButtonView

        //----------------------------------------------------------
        // キーボード用のスクロール制御
        //----------------------------------------------------------
        ScrollView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        ScrollView.backgroundColor = UIColor.clearColor();
        ScrollView.delegate = self;
        ScrollView.addSubview(_textView)
        self.view.addSubview(ScrollView)

        //----------------------------------------------------------
        // キーボード用のオブザーバー定義
        //----------------------------------------------------------
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)

        //----------------------------------------------------------
        // ホームURLを決定
        //----------------------------------------------------------
        HOMEURL = NaviWebURL
        
        //----------------------------------------------------------
        // データビューテーブルの作成
        //----------------------------------------------------------
        if (Common.MakeFileFLG(HOMEURL!) == true){
            for line_args in DataViewArrays {
                if( line_args.pathExtension == HOMEURL.pathExtension ){
                    FileViewTable.append(line_args)
                }
            }
            var i = 0
            for line_args in FileViewTable {
                if( line_args == HOMEURL ){
                    dataview_args = i
                    break
                }
                i++
            }
        }
        
        //----------------------------------------------------------
        // 検索バーの作成
        //----------------------------------------------------------
        searchBar.barStyle = .Default
        searchBar.showsCancelButton = false
        serchFLG = false
        //searchBar.tintColor = bl.selfcolor;
        //searchBar.placeholder = "検索語句/URL"
        searchBar.keyboardType = .Default
        searchBar.delegate = self
        searchBar.text = self.title!;
        self.navigationItem.titleView = TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))

        //----------------------------------------------------------
        // 親Vireの定義
        //----------------------------------------------------------
        self.view.backgroundColor = UIColor.whiteColor()
        
        //----------------------------------------------------------
        // _webViewの生成する(status barの高さ分ずらして表示).
        //----------------------------------------------------------
        //_webView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
        _webView.backgroundColor = UIColor.whiteColor()
        _webView.scrollView.bounces = true
        _webView.scalesPageToFit = true
        //_webView.autoresizingMask =     //ビューサイズの自動調整
        //    UIViewAutoresizing.FlexibleRightMargin |
        //    UIViewAutoresizing.FlexibleTopMargin |
        //    UIViewAutoresizing.FlexibleLeftMargin |
        //    UIViewAutoresizing.FlexibleBottomMargin |
        //    UIViewAutoresizing.FlexibleWidth |
        //    UIViewAutoresizing.FlexibleHeight
        _webView.dataDetectorTypes = .None
        _webView.delegate = self
        _webView.scrollView.delegate = self
        _webView.scrollView.contentOffset = CGPointMake(0, 0)
        scrollBeginingPoint = _webView.scrollView.contentOffset
        ScrollFLG = false
        //self._webView.hidden = true
        self._textView.hidden = true
        
        //----------------------------------------------------------
        // WebViewの表示
        //----------------------------------------------------------
        self.view.addSubview(_webView)
        
        //----------------------------------------------------------
        // (WebContentsLoading)能動コンテンツロードを実施。要バックグラウンド
        //----------------------------------------------------------
        appDelegate.customCache.RefererAdress = ""
        SVProgressHUD.showWithStatus(String(format: "%@",NaviWebURL.lastPathComponent))
        HistoryFLAG = true
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            self.WebContentsLoading(self.NaviWebURL)
            //self.WebContentsLoading("http://blog.livedoor.jp/ponpokonwes/")
            //self.WebContentsLoading("http://www.google.co.jp/")
        }))

        //----------------------------------------------------------
        // メニューボタン
        //----------------------------------------------------------
        RightButton = UIBarButtonItem(image:UIImage(named: "icon_magnifier.png")!, style: .Plain, target: self , action: "NaviSearchBarView")
        SaveButton = UIBarButtonItem(image:UIImage(named: "icon_save.png")!, style: .Plain, target: self , action: "UseEventSavePath")
        self.navigationItem.rightBarButtonItems = Common.MakeFileFLG(NaviWebURL) ? [RightButton,SaveButton] : [RightButton]

        //----------------------------------------------------------
        // 下部バーのボタン
        //----------------------------------------------------------
        reload_btn = UIBarButtonItem(image:UIImage(named: "icon_reload.png")!,    style: .Plain, target: self , action: "UseEventWebReload")
        home_btn =   UIBarButtonItem(image:UIImage(named: "icon_home.png")!,       style: .Plain, target: self , action: "UseEventWebHome")
        cancel_btn = UIBarButtonItem(image:UIImage(named: "icon_cancel.png")!,     style: .Plain, target: self , action: "UseEventWebCancel")
        
        modoru_btn = UIBarButtonItem(image:UIImage(named: "icon_arrow_left.png")!, style: .Plain, target: self , action: "UseEventWebBack")
        susumu_btn = UIBarButtonItem(image:UIImage(named: "icon_arrow_right.png")!,style: .Plain, target: self , action: "UseEventWebForward")
        up_btn     = UIBarButtonItem(image:UIImage(named: "icon_arrow_up.png")!,   style: .Plain, target: self , action: "UseEventFileUp")
        down_btn   = UIBarButtonItem(image:UIImage(named: "icon_arrow_down.png")!, style: .Plain, target: self , action: "UseEventFileDown")
        favorite_btn = UIBarButtonItem(image:UIImage(named: "icon_bookmark_add.png")!, style: .Plain, target: self , action: "UseEventFavorite")
        
        //----------------------------------------------------------
        // 下部バーコンソール
        //----------------------------------------------------------
        NaviWebToolBar.barStyle = .BlackTranslucent
        NaviWebToolBar.translucent = true
        NaviWebToolBar.backgroundColor = UIColor.clearColor()
        NaviWebToolBar.items =  [modoru_btn,susumu_btn,up_btn,down_btn,UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),favorite_btn,reload_btn,cancel_btn,home_btn]
        self.view.addSubview(NaviWebToolBar)

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
        LCTimer = NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: "LayoutCheck", userInfo: nil, repeats: true)
        
        //----------------------------------------------------------
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        PostLayout()
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
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        //NSOperationQueue().addOperation(NSBlockOperation(block: {
        //    SVProgressHUD.showWithStatus("お待ちください")
        //}))
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        super.viewWillDisappear(animated)
        self.UseEventWebCancel()
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
    
    //*********************************************** 以下、UIWebView制御 ***********************************************
    
    /**
    *
    * HTML読み込み開始時に呼ばれる(4)
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest,navigationType: UIWebViewNavigationType) -> Bool {
        //---------------------------------------------------------------------
        // 変数の定義
        //---------------------------------------------------------------------
        let UrlStr = request.URL.absoluteString
        let FileFLG = Common.MakeFileFLG(UrlStr!)
        let Domain = FileFLG ? "" : UrlStr!.componentsSeparatedByString("://")[1].componentsSeparatedByString("/")[0]
        
        //if(countElements(Domain)<1){
        //    return FileFLG
        //}
        
        //---------------------------------------------------------------------
        // クリックしたかどうかの判定
        //---------------------------------------------------------------------
        if navigationType == UIWebViewNavigationType.LinkClicked || navigationType == UIWebViewNavigationType.FormSubmitted {
            //通信中の時は再度URLジャンプさせない(5)
            if LoadFLAG == true {
                //LoadingStop()
                return false
            }
            HistoryFLAG = true
            SVProgressHUD.showWithStatus(String(format: "%@\nから読み込んでいます",countElements(Domain)<1 ? "保存領域" : Domain))
            NSOperationQueue().addOperation(NSBlockOperation(block: {
                self.WebContentsLoading(UrlStr!)
            }))
            return false
        } else {
            if (String(UrlStr!).rangeOfString("about:blank") != nil){
                return false
            }
            //---------------------------------------------------------------------
            // ここで広告を判別して読み込みを弾くことが出来る
            //---------------------------------------------------------------------
        }
        
        //---------------------------------------------------------------------
        // ここはとりあえず true
        //---------------------------------------------------------------------
        //SVProgressHUD.showWithStatus(String(format: "%@\nから読み込んでいます",countElements(Domain)<1 ? "保存領域" : Domain))
        return true
    }
    
    /**
    *
    * HTML読み込み成功時に呼ばれる
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func webViewDidFinishLoad(webView: UIWebView) {
        //---------------------------------------------------------------------
        // ツールバー表示
        //---------------------------------------------------------------------
        if(self.NaviWebToolBar.hidden == true){
            self.NaviWebToolBar.hidden = false
        }

        //---------------------------------------------------------------------
        // 本体HTMLファイルの処理
        //---------------------------------------------------------------------
        if NaviWebURL == webView.stringByEvaluatingJavaScriptFromString("location.href")! || appDelegate.customCache.BaseURL == webView.stringByEvaluatingJavaScriptFromString("location.pathname")! {
            self.title = countElements(webView.stringByEvaluatingJavaScriptFromString("document.title")!) < 1 ? NaviWebURL.lastPathComponent : webView.stringByEvaluatingJavaScriptFromString("document.title")!
            self.navigationItem.titleView = TitleLabel(countElements(self.title!) < 13 ? self.title! : String((self.title! as NSString).substringToIndex(12)) , Color : UIColor.hexStr("#FAFAFA", alpha: 1))
            searchBar.text = self.title!
            if UIApplication.sharedApplication().networkActivityIndicatorVisible {
                _webView.stopLoading()
            }
        }
        self.navigationItem.rightBarButtonItems = Common.MakeFileFLG(NaviWebURL) ? [RightButton,SaveButton] : [RightButton]

        //---------------------------------------------------------------------
        // セーブのリセット
        //---------------------------------------------------------------------
        self.userDefaults.setObject("", forKey: "SaveAdress")
        self.userDefaults.synchronize()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.UseEventWebCancel()
        }
    }
    
    /**
    *
    * HTML読み込み失敗時に呼ばれる
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func webView(webView: UIWebView,didFailLoadWithError error: NSError) {
        
        //=========================================================================
        // インジケーターの非表示
        //=========================================================================
        let current_url : String = _webView.stringByEvaluatingJavaScriptFromString("document.URL")!
        
        //=========================================================================
        // インジケーターの非表示
        //=========================================================================
        UseEventWebCancel()
        
        //=========================================================================
        // インターネット接続完了不良
        //=========================================================================
        if (Common.isConnectedToNetwork() == false) {
            showAlert("", text: "ネットワークに接続出来ません")
            return
        }
        
        //=========================================================================
        // キャンセル処理につき正常処理
        //=========================================================================
        if (error.code == NSURLErrorCancelled || current_url.rangeOfString("about:blank") != nil) {
            return
        }

        //=========================================================================
        // 動画再生
        //=========================================================================
        if (error.code == 204) {
            //showAlert(String(format: "コード:%d\n",error.code), text: "原因切り分け未実施のエラー")
            return
        }
        showAlert(String(format: "コード:%d\n",error.code), text: "原因切り分け未実施のエラー")
    }
    
    
    /**
    *
    * Urlの読み込み
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func WebContentsLoading(UrlStr: String){

        //----------------------------------------------------------
        // タイトルと色を定義
        //----------------------------------------------------------
        if (self.HOMEURL != UrlStr){
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.title = UrlStr.lastPathComponent
                self.navigationItem.titleView = self.TitleLabel(UrlStr.lastPathComponent , Color : UIColor.hexStr("#FAFAFA", alpha: 1))
            }
        }

        //-----------------------------------------------------------------------------
        // ナビゲーションバーの右ボタンをリセット
        //-----------------------------------------------------------------------------
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            self._webView.hidden = false
            self._textView.hidden = true
        }
        LoadFLAG = true
        //-----------------------------------------------------------------------------
        // エンコード・エラーチェック用変数
        //-----------------------------------------------------------------------------
        let enc_arr = [
            NSUTF8StringEncoding,
            NSShiftJISStringEncoding,
            NSJapaneseEUCStringEncoding,
            NSISO2022JPStringEncoding,
            NSUnicodeStringEncoding,
            NSASCIIStringEncoding
        ]
        
        //-----------------------------------------------------------------------------
        // リクエストの拡張子
        //-----------------------------------------------------------------------------
        let PathExtension = UrlStr.pathExtension
        
        //-----------------------------------------------------------------------------
        // ロードしたNSData
        //-----------------------------------------------------------------------------
        var LoadData : NSData?

        //-----------------------------------------------------------------------------
        // ファイルかURLかを判別
        //-----------------------------------------------------------------------------
        let FileFLG = (UrlStr.rangeOfString("^((http)s?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+)",options: NSStringCompareOptions.RegularExpressionSearch) != nil) ? false : true

        //-----------------------------------------------------------------------------
        // AsciiかBinaryかを判別
        //-----------------------------------------------------------------------------
        var AsciiFLAG = false
        
        //-----------------------------------------------------------------------------
        // NSURLを定義(ファイルとURLで違う)
        //-----------------------------------------------------------------------------
        let reqURL = (FileFLG == false) ? NSURL(string:UrlStr) : NSURL(fileURLWithPath:UrlStr)
        
        //-----------------------------------------------------------------------------
        // HTTPヘッダ文字列
        //-----------------------------------------------------------------------------
        var HeaderString : String = ""
        
        
        
        
        //-----------------------------------------------------------------------------
        // エラーメッセージ
        //-----------------------------------------------------------------------------
        var ErrMSG : String = ""
        
        //-----------------------------------------------------------------------------
        // ファイルキャッシュ
        //-----------------------------------------------------------------------------
        let SaveFileName = UrlStr.stringByReplacingOccurrencesOfString("/", withString: " ", options: nil, range: nil)
        let tmpPath = String(format: "%@/%@",NSTemporaryDirectory() + "DConeect",SaveFileName)
        
        //-----------------------------------------------------------------------------
        // customCacheのパラメータ
        //-----------------------------------------------------------------------------
        appDelegate.customCache.BaseURL = Common.BaseUrlEcho(UrlStr)
        appDelegate.customCache.RefererAdress = RefererAdress == nil ? "" : RefererAdress
        appDelegate.customCache.UserAgent = UserAgent.iPhoneiPad.toNSString()
        
        //-----------------------------------------------------------------------------
        // 拡張子が明らかにバイナリチックなブラウザファイルは loadRequest
        //-----------------------------------------------------------------------------
        if(PathExtension.lowercaseString.rangeOfString("gif|bmp|tiff|png|jpg|jpeg|pdf|xls|xlsx|ppt|pptx|doc|docx|m4v|mp4|3gp|mov|qt",options: NSStringCompareOptions.RegularExpressionSearch) != nil) {
            self.NaviWebURL = UrlStr
            _webView.loadRequest(NSURLRequest(URL:reqURL!))
            LoadFLAG = false
            return;
        }

        //-----------------------------------------------------------------------------
        // プロトコルを確認してデータをロードして LoadDataにNSDataとして格納
        //-----------------------------------------------------------------------------
        if (FileFLG == false){
            if(NSFileManager.defaultManager().fileExistsAtPath(tmpPath, isDirectory: nil)){
                LoadData = NSData(contentsOfFile: tmpPath)
                RefererAdress = UrlStr
                HeaderString = "text/html"
            } else {
                if(Common.isConnectedToNetwork()){
                    let request = ASIHTTPRequest.requestWithURL(reqURL ,
                        username : "" , password:  "" ,  referer: RefererAdress == nil ? "" : RefererAdress ,
                        userAgent:appDelegate.customCache.UserAgent) as ASIHTTPRequest
                    request.delegate = self
                    request.startSynchronous()
                    HeaderString = String(format: "%@",request.responseHeaders as Dictionary).lowercaseString
                    if(request.responseStatusCode > 399 || request.responseStatusCode < 200){
                        LoadData = nil
                        RefererAdress = ""
                        ErrMSG = String(format: "レスポンスコード:%d",request.responseStatusCode)
                    } else {
                        LoadData = request.responseData()
                        RefererAdress = UrlStr
                    }
                } else {
                    LoadData = nil
                    RefererAdress = ""
                    ErrMSG = "ネットワークに接続出来ません。"
                }
            }
        } else {
            let FilePath = UrlStr.stringByReplacingOccurrencesOfString("file:/", withString: "", options: nil, range: nil)
            LoadData = NSFileManager.defaultManager().fileExistsAtPath(FilePath, isDirectory: &isDir) ? NSData(contentsOfFile:FilePath) : nil
            RefererAdress = ""
            HeaderString = (PathExtension.lowercaseString.rangeOfString("html|htm",options: NSStringCompareOptions.RegularExpressionSearch) != nil) ? "text/html" : HeaderString
        }
        
        //-----------------------------------------------------------------------------
        // NSDataが取得出来なければエラー
        //-----------------------------------------------------------------------------
        if(LoadData == nil) {
            showAlert("Dataエラー", text: String(format: "通信に失敗しました。\n%@",ErrMSG))
            LoadingStop()
            return;
        }

        //-----------------------------------------------------------------------------
        // ASCIIかどうか判定し、NSStringにデコード
        //-----------------------------------------------------------------------------
        for line_args in enc_arr {
            if(NSString(data:LoadData!, encoding:line_args)? != nil){
                AsciiString = NSString(data:LoadData!, encoding:line_args)!
                AsciiFLAG = true
                break
            }
        }
        
        //-----------------------------------------------------------------------------
        // ここの段階でバイナリならば、再生対応していない拡張子なので、エラー処理
        //-----------------------------------------------------------------------------
        if( AsciiFLAG == false ){
            showAlert("Info:表示/再生不可", text: "対応していない\n拡張子です")
            LoadingStop()
            return;
        }

        //-----------------------------------------------------------------------------
        // ヘッダが取れているものはブラウザで処理
        //-----------------------------------------------------------------------------
        self.NaviWebURL = UrlStr
        if(HeaderString.rangeOfString("text/html") != nil) {
            _webView.loadHTMLString(AsciiString, baseURL: (FileFLG == false) ? reqURL : NSURL(fileURLWithPath:appDelegate.customCache.BaseURL!))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self._textView.text = ""
            }
            if (FileFLG == false){
                NSFileManager.defaultManager().createFileAtPath(tmpPath,contents:LoadData, attributes:nil)
            }
            //LoadingStop()
            SVProgressHUD.showWithStatus("レタリングをしています。\nお待ちください。")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.LoadingStop()
            }
            
        } else {
            //-----------------------------------------------------------------------------
            // TextViewの処理
            //-----------------------------------------------------------------------------
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self._textView.text = self.AsciiString
                self._textView.hidden = false
                self._webView.hidden = true
            }
            LoadingStop()
        }
        if(HistoryTable.count == history_args && HistoryFLAG == true) {
            HistoryTable.append(UrlStr)
            history_args++
        }
        HistoryFLAG = false
        return;
    }
    
    /**
    *
    * Loading動作を停止する
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func LoadingStop(){
        NSOperationQueue.mainQueue().addOperationWithBlock(){
            SVProgressHUD.dismiss()
        }
        LoadFLAG = false
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
                //  BetTableEditViewの定義
                //----------------------------------------------------------
                PostLayout()
        }
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
    func PostLayout() {
        self.view.frame = LayOutCyouSei()
        self._webView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.NaviWebToolBar.frame = CGRect(x: 0 , y: self.view.bounds.height - 44.0, width: self.view.bounds.width, height: 44.0)
        TextRect()
    }
    
    /**
    *
    * スクロール関係の関数
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollBeginingPoint = _webView.scrollView.contentOffset
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(ScrollFLG == true){
            return
        }
        ScrollFLG = true
        var currentPoint = _webView.scrollView.contentOffset
        //self.NaviWebToolBar.hidden = true
        if(scrollBeginingPoint.y > currentPoint.y){
            //self.NaviWebToolBar.hidden = false
            self.NaviWebToolBar.hidden = true
            self._webView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }else{
            ScrollFLG = true
            self.NaviWebToolBar.hidden = false
            self._webView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 44.0)
        }
        TextRect()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        ScrollFLG = false
        if(self.NaviWebToolBar.hidden == true){
            self.NaviWebToolBar.hidden = false
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
        KeyHight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue().size.height
        TextRect()
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
        KeyHight = 0
        TextRect()
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
    func TextRect(){
        self.ScrollView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height - KeyHight)
        self._textView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height - KeyHight)
    }

}
