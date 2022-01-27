//
//  ViewController.swift
//  LightWalker
//
//  Created by Yoshinori Okamura on 2015/01/05.
//  Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//
/**
* クラス.
*
* <p>
* 汎用的な処理補助系のメンバ関数を格納。<br>
* ベースクラスはビルドして配布(クローズソース)<br>
* </p>
*
* @author (必須、クラス・インターフェースのみに使用)
* @version (必須、クラス・インターフェースのみに使用)
* @exception メソッドで発生しうる (throws に列挙してある) 例外の説明に使用する
*
* @see 関連項目へのリンクを示す ここでは他のクラスやメソッドを指定できる
* @since どのバージョンから追加されたかを記述する。
* @deprecated 使用が推奨されていない場合に記述する。
*/

import UIKit
import Darwin
@objc(ViewController)
class ViewController:  JWSlideMenuViewController , UITextFieldDelegate {
    
    /**
    * CommonFunctionのインスタンス
    */
    var Common = CommonFunction()
    
    /**
    * AppDelegateの記述省略。何故かprivateしかスコープがない。
    *
    */
    var appDelegate : AppDelegate!
    
    /**
    * userDefaultsの記述省略。
    *
    */    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    /**
    * NSFileManagerの記述省略。
    *
    */   
    let FileManager = NSFileManager.defaultManager()
    //var isDir : ObjCBool
    var isDir : ObjCBool = false
    var error: NSError?

    /**
    * TableViewCellIconの記述省略。
    *
    */    
    //let TableViewCellIconWidth : CGFloat = 35
    //let TableViewCellIconHeight : CGFloat = 40

    /**
    * 各部品の高さ
    * StatusBarhHeight 20.0
    * NavigationBarHeight 44.0
    * ToolBarHeight 44.0
    * TabBarHeight 49.0
    */
    enum BuhinHight {
        case StatusBarhHeight
        case NavigationBarHeight
        case ToolBarHeight
        case TabBarHeight
        func toCGFloat() -> CGFloat {
            switch self {
            case .StatusBarhHeight:
                return 20.0
            case .NavigationBarHeight:
                return 44.0
            case .ToolBarHeight:
                return 44.0
            case .TabBarHeight:
                return 49.0
            }
        }
    }

    /**
     * HTTP_USER_AGENT_ARRAYの取得
     * info.plistに登録して使用する
     */
    enum UserAgent {
        case iPhoneiPad
        case MacPC
        case MobilePhone
        func toNSString() -> NSString {
            var userAgent: Array<String> = ["Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_3 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B508 Safari/9537.53","Mozilla/1.0 (Macintosh; Intel Mac OS X 1_0_0) AppleWebKit/100.0.1 (KHTML, like Gecko) Version/1.0.1 Safari/100.0.1","DoCoMo/2.0 F901iC(c100;TB;W23H12)"]
            switch self {
            case .iPhoneiPad:
                return userAgent[0] as NSString
            case .MacPC:
                return userAgent[1] as NSString
            case .MobilePhone:
                return userAgent[2] as NSString
            }
        }
    }

    /**
    *
    * loadView()デリゲードのオーバーライド
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func loadView(){
        super.loadView()
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    }
    
    /**
    *
    * テキストフィールドの生成
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func makeTextField(frame: CGRect, text: NSString, tag: Int) -> UITextField {
        let textField = UITextField()
        textField.frame = frame
        textField.text = text
        textField.tag = tag
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.keyboardType = UIKeyboardType.Default
        textField.returnKeyType = UIReturnKeyType.Done
        textField.delegate = self
        return textField
    }
    
    /**
    *
    * テキストボタンの生成 アクションコントロールは自分で書く(下記見本)
    * addTarget(self, action: "test", forControlEvents: UIControlEvents.TouchUpInside)
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func makeButton(frame: CGRect, text: NSString, tag: Int) -> UIButton {
        let button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        // ボタンのフレーム
        button.frame = frame

        // ボタンのタグ
        button.tag = tag

        // ボタンのアール
        button.layer.cornerRadius = 5

        // ボタンの枠線
        button.layer.borderWidth = 0

        // ボタンの背景色
        button.backgroundColor = UIColor.hexStr("#1E90FF", alpha: 1.0)

        // ボタンの影
        button.layer.shadowOffset = CGSizeMake(1.5, 1.5)
        button.layer.shadowOpacity = 0.5

        // ボタンの文字
        button.setTitle(text, forState: UIControlState.Normal)

        // ボタンの文字の色
        button.setTitleColor(UIColor.hexStr("#F8F8F8", alpha: 1), forState: UIControlState.Normal)

        // ボタンの文字の影 (影の位置を変更しないと影は表示されないので注意)
        button.setTitleShadowColor(UIColor.hexStr("#1C1C1C", alpha: 1.0), forState: UIControlState.Normal)

        // ボタンの文字の影の位置
        button.titleLabel!.shadowOffset = CGSize(width: 1.2, height: 1.2)

        // ボタンが押された時の文字色
        button.setTitleColor(UIColor.hexStr("#1E90FF", alpha: 1), forState: UIControlState.Highlighted)

        // ボタンのフォント
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)

        //利用不可時の色設定
        button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        button.setTitleShadowColor(UIColor.grayColor(), forState: UIControlState.Disabled)

        return button
    }
    
    /**
    *
    * ラベルの生成
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func makeUILabel(frame: CGRect, text: NSString) -> UILabel {
        let label1 = UILabel()
        label1.frame = frame
        label1.text = text                                  //テキスト
        label1.font = UIFont.boldSystemFontOfSize(16)                                //フォント
        label1.textAlignment = NSTextAlignment.Left          //配置
        label1.lineBreakMode = NSLineBreakMode.ByWordWrapping//改行
        label1.numberOfLines = 0                             //行数
        label1.sizeToFit() //ラベルとテキストの幅と高さをあわせる(2)
        return label1
    }
    
    /**
    *
    * セグメントコントロールの生成 アクションコントロールは自分で書く(下記見本)
    * addTarget(self, action: "test", forControlEvents: UIControlEvents.TouchUpInside)
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func makeSegmentedControl(frame: CGRect, myArray: NSArray ) -> UISegmentedControl {
        let mSegcon: UISegmentedControl = UISegmentedControl(items: myArray)
        mSegcon.frame = frame
        mSegcon.backgroundColor = UIColor.whiteColor()
        mSegcon.tintColor =  UIColor.hexStr("#1E90FF", alpha: 1)
        return mSegcon
    }
    
    /**
    *
    * ナビゲーションバーのタイトルを生成する
    *
    * @param
    * @return UILabel
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func TitleLabel(Message : String , Color : UIColor) -> UILabel {
        var title_label = UILabel()
        title_label.backgroundColor = UIColor.clearColor()
        title_label.numberOfLines = 0
        title_label.font = UIFont.boldSystemFontOfSize(16)
        //title_label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        title_label.shadowColor = UIColor.hexStr("#1C1C1C", alpha: 1)
        title_label.shadowOffset = CGSizeMake(1, 1);
        title_label.textColor = Color
        title_label.text = Message
        title_label.sizeToFit()
        //title_label.frame = CGRectMake(0, BuhinHight.StatusBarhHeight.toCGFloat(),title_label.bounds.size.width,title_label.bounds.size.height)
        title_label.textAlignment = NSTextAlignment.Center
        return title_label
    }
    
    /**
    *
    * viewDidLoad()デリゲードのオーバーライド
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
    }
    
    /**
    *
    * didReceiveMemoryWarning()デリゲードのオーバーライド
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
    *
    * レイアウトの位置や幅を調整する
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated  ლ(´ڡ`ლ)
    */
    func LayOutCyouSei()  -> CGRect {
        var AdMobView_height : CGFloat
        let myBounds = UIScreen.mainScreen().bounds
        let YokoMukiFLG : Bool = UIApplication.sharedApplication().statusBarOrientation.isPortrait ? false : true;
        var sc_x : CGFloat
        var sc_y : CGFloat
        if(myBounds.size.width > myBounds.size.height){
            sc_x = YokoMukiFLG ? myBounds.size.width : myBounds.size.height
            sc_y = YokoMukiFLG ? myBounds.size.height : myBounds.size.width
        } else {
            sc_x = YokoMukiFLG ? myBounds.size.height : myBounds.size.width
            sc_y = YokoMukiFLG ? myBounds.size.width : myBounds.size.height
        }
        
        //----------------------------------------------------------
        // 広告表示の判定
        //----------------------------------------------------------
        if appDelegate.slideMenu.AdMobView.hidden && !appDelegate.slideMenu.actInd.isAnimating() {
            AdMobView_height = 0
        } else {
            AdMobView_height = appDelegate.slideMenu.AdMobView.bounds.size.height
        }
        return CGRectMake(
            0,
            AdMobView_height,
            sc_x,
            sc_y-AdMobView_height - BuhinHight.NavigationBarHeight.toCGFloat() - BuhinHight.StatusBarhHeight.toCGFloat()
        )
    }
    /**
    *
    * アラートの表示
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated  ლ(´ڡ`ლ)
    */
    func showAlert(title: NSString?, text: NSString?) {
    NSOperationQueue.mainQueue().addOperationWithBlock(){
        SVProgressHUD.dismiss()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if(atof(UIDevice.currentDevice().systemVersion) >= 8.0){
            let alert = UIAlertController(title: title, message:text,preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK",style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else {
            let alert = UIAlertView()
            alert.title = title!
            alert.message = text
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
        }
}
