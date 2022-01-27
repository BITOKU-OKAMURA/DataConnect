//
//  ViewTestController.swift
//  LightWalker
//
//  Created by Yoshinori Okamura on 2015/01/05.
//  Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit

class ViewTestController: ViewController {

    /**
     * ログで出すクラス名
     * NSLOGは ろぐ 辞書登録済
     * AppDelegateは でり で辞書登録済
     * 下記 ClassNameプロパティの記述は必須
     */
    let ClassName = __FILE__.componentsSeparatedByString("/").last!.componentsSeparatedByString(".swift").first!

    /**
     * swiftはヘッダファイルが無いのでここでプロパティを定義
     * アクセス装飾子の概念は不明だが恐らく何時でも定義可能かと思われる。
     */
    let label = UILabel()

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
        // 親Vireの定義
        //----------------------------------------------------------
        self.view.backgroundColor = UIColor.whiteColor()

        //----------------------------------------------------------
        //UILabel http://iphone-tora.sakura.ne.jp/uilabel.html
        //----------------------------------------------------------
        let label1 = UILabel()
        label1.frame = CGRectMake(0, 0, 100, 200)  //領域 x,y,width,hieight
        label1.text = "これはテストです"                                  //テキスト
        label1.font =  UIFont.systemFontOfSize(24)                                //フォント
        label1.textAlignment = NSTextAlignment.Left          //配置
        label1.lineBreakMode = NSLineBreakMode.ByWordWrapping//改行
        label1.numberOfLines = 0                             //行数
        label1.sizeToFit() //ラベルとテキストの幅と高さをあわせる(2)
        self.view.addSubview(label1)  //コンポーネントの配置(3)

        //----------------------------------------------------------
        //UIImage http://iphone-tora.sakura.ne.jp/uiimage.html
        //----------------------------------------------------------
        let imageView = UIImageView()
        imageView.frame = CGRectMake(0, 70, 80, 80) //領域
        imageView.image = UIImage(named: "image.png")!//イメージ
        self.view.addSubview(imageView)         //コンポーネントの配置
        

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
}

