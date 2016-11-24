//
//  XJDomainViewController.swift
//  二维码案例
//
//  Created by 李胜兵 on 2016/11/24.
//  Copyright © 2016年 付公司. All rights reserved.
//

import UIKit

class XJDomainViewController: UIViewController {

    @IBOutlet weak var bgVIew: UIView!
    fileprivate lazy var webView : UIWebView = UIWebView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


}

extension XJDomainViewController {
    fileprivate func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGes(tapG:)))
        bgVIew.addGestureRecognizer(tap)
    }
}

extension XJDomainViewController  {
    @objc fileprivate func tapGes(tapG : UITapGestureRecognizer) {
        print("-------")
        webView.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)
        webView.delegate = self
        view.addSubview(webView)
        let url : URL = URL(string: "https://github.com/lishengbing/XJQRCodeToolDemo")!
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
}


extension XJDomainViewController : UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        navigationItem.title = "正在前往Github star的路上...稍等..."
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        navigationItem.title = "star了就可以获取更多技术..."
        UIView.animate(withDuration: 0.6, delay: 30, options: [], animations: {
            self.webView.removeFromSuperview()
            self.bgVIew.removeFromSuperview()
        }, completion: { (_) in
            //
            UIView.animate(withDuration: 0.6, delay: 20, options: [], animations: {
            }, completion: { (_) in
                self.navigationItem.title = "谢谢您的star..."
            })
        })
    }
}
