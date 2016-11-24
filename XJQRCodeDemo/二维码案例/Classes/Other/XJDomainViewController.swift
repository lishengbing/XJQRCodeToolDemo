//
//  XJDomainViewController.swift
//  二维码案例
//
//  Created by 李胜兵 on 2016/11/24.
//  Copyright © 2016年 付公司. All rights reserved.
//

import UIKit
private let timeValue : Int = 18

class XJDomainViewController: UIViewController {

    @IBOutlet weak var bgVIew: UIView!
    @IBOutlet weak var rightItem: UIBarButtonItem!
    fileprivate lazy var webView : UIWebView = UIWebView()
    fileprivate var cycyleTimer : Timer?
    static var timeinterval : Int = 0
    static var isClick : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeCycleTimer()
    }
}


extension XJDomainViewController {
    
    fileprivate func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGes(tapG:)))
        bgVIew.addGestureRecognizer(tap)
    }
    
    @IBAction func rightClick(_ sender: Any) {
        if XJDomainViewController.isClick {
            let alertVc = UIAlertController(title: "不要急,\(timeValue)后出现", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default) { (_) in
                self.starClick()
            }
            alertVc.addAction(okAction)
            present(alertVc, animated: true, completion: nil)
        }else {
            let alertVc = UIAlertController(title: "还在计时当中...稍等", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .default) { (_) in}
            alertVc.addAction(okAction)
            present(alertVc, animated: true, completion: nil)
        }
    }

    @IBAction func starClick() {
        webView.isHidden = false
        bgVIew.isHidden = false
        loadWebView()
    }
    
    fileprivate func removeView() {
        webView.isHidden = true
        bgVIew.isHidden = true
    }
}


extension XJDomainViewController  {
    @objc fileprivate func tapGes(tapG : UITapGestureRecognizer) {
        loadWebView()
    }
    
    fileprivate func loadWebView() {
        webView.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)
        webView.delegate = self
        view.addSubview(webView)
        let url : URL = URL(string: "https://github.com/lishengbing/XJQRCodeToolDemo")!
        let request = URLRequest(url: url)
        webView.loadRequest(request)
        
        XJDomainViewController.isClick = false
    }
}



extension XJDomainViewController : UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        navigationItem.title = "正在前往Github star的路上...稍等..."
         addCycleTimer()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        navigationItem.title = "请star一下"
       
    }
    
    
}



extension XJDomainViewController {
    fileprivate func addCycleTimer() {
        removeCycleTimer()
        cycyleTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.scrollToNext), userInfo: nil, repeats: true)
        RunLoop.main.add(cycyleTimer!, forMode:RunLoopMode.commonModes)
    }
    fileprivate func removeCycleTimer() {
        cycyleTimer?.invalidate()
        cycyleTimer = nil
        rightItem.title = "技术计时入口"
        navigationItem.title = "点下面star可重来"
    }
    @objc fileprivate func scrollToNext() {
         XJDomainViewController.isClick = false
        rightItem.title = "\(timeValue)s后看技术"
        XJDomainViewController.timeinterval = XJDomainViewController.timeinterval + 1
        navigationItem.title = "\(XJDomainViewController.timeinterval)s后扫描"
        if XJDomainViewController.timeinterval == timeValue {
            removeCycleTimer()
            removeView()
            XJDomainViewController.timeinterval = 0
            XJDomainViewController.isClick = true
            return
        }
    }
}

