//
//    TableTestViewController.swift
//  LightWalker
//
//  Created by Yoshinori Okamura on 2015/01/05.
//  Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit

class   TableTestViewController:ViewController , UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate {
    /**
     * ログで出すクラス名
     * NSLOGは ろぐ 辞書登録済
     * AppDelegateは でり で辞書登録済
     * 下記 ClassNameプロパティの記述は必須
     */
    let ClassName = __FILE__.componentsSeparatedByString("/").last!.componentsSeparatedByString(".swift").first!

    /**
     * tableViewオブジェクトはクラスのスコープ
     */
    var tableView = UITableView()

    /**
     * 広告動作確認タイマー
     * 
     */
    var LCTimer : NSTimer!

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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.autoresizesSubviews = true;
        // Do any additional setup after loading the view, typically from a nib.
        //appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        //NSLog(ClassName + "::" + __FUNCTION__ + "| ")

        //----------------------------------------------------------
        // 親Vireの定義
        //----------------------------------------------------------
        self.view.backgroundColor = UIColor.whiteColor()

        //----------------------------------------------------------
        // TableViewの生成する(status barの高さ分ずらして表示).
        //----------------------------------------------------------
        tableView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
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
//右ボタン
//self.navigationItem.rightBarButtonItem = UIBarButtonItem( title: "切替", style: UIBarButtonItemStyle.Plain, target: self, action: "KR_BetTableEditViewArraySet" )

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
        self.title = countElements(appDelegate.slideMenu.CurrentTitle) > 0 ? appDelegate.slideMenu.CurrentTitle :  ""
        self.navigationItem.titleView = TitleLabel(self.title! , Color : UIColor.hexStr("#FAFAFA", alpha: 1))

        //----------------------------------------------------------
        // 親Viewのレイアウト調整
        //----------------------------------------------------------
        self.view.frame = LayOutCyouSei()

        //----------------------------------------------------------
        // tableViewも親Viewに同調させる
        //----------------------------------------------------------
        self.tableView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height)

        //----------------------------------------------------------
        // 広告チェックタイマー ローカルスコープ
        //----------------------------------------------------------
        LCTimer = NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: "LayoutCheck", userInfo: nil, repeats: true)

        //----------------------------------------------------------
        // Viewに追加する.
        //----------------------------------------------------------
        self.view.addSubview(tableView)
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
        //NSLog(ClassName + "::" + __FUNCTION__ + "| ")
        LCTimer.invalidate()
        super.viewWillDisappear(animated)
        // Dispose of any resources that can be recreated.
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
        NSLog(ClassName + "::" + __FUNCTION__ + "| ")
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
        self.tableView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    }

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
            self.view.frame = LayOutCyouSei()
            //----------------------------------------------------------
            //  BetTableEditView内のtableViewも BetTableEditViewに同調させる
            //----------------------------------------------------------
            self.tableView.frame = CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }
    }

}//End Of Class

