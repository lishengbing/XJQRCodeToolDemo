//
//  ScanQRCodeViewController.swift
//  二维码案例
//
//  Created by 李胜兵 on 16/11/12.
//  Copyright © 2016年 付公司. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController {
    
    @IBOutlet weak var scanBgView: UIView!
    @IBOutlet weak var scanLineView: UIImageView!
    @IBOutlet weak var scanBottomCons: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        starScanAnimation()
        QRCodeTool.shareInstance.starScanQRCode(inView: view, isDrawFrame: true) { (resultStrs) in
            print("--------",resultStrs)
        }
        QRCodeTool.shareInstance.setScanRectInterest(origenViewRect: scanBgView.frame)
    }

}

extension ScanQRCodeViewController {
    fileprivate func starScanAnimation() {
        scanBottomCons.constant = scanBgView.frame.size.height
        view.layoutIfNeeded()
        
        // 动画1
        let anim = CABasicAnimation(keyPath: "transform.translation.y")
        anim.fromValue = 0
        anim.toValue = scanBgView.frame.size.height
        anim.autoreverses = false
        anim.duration = 2
        anim.repeatCount = FLT_MAX
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        scanLineView.layer.add(anim, forKey: "transform.translation.y")

        
        // 动画2
//        scanBottomCons.constant = -scanBgView.frame.size.height
//        UIView.animate(withDuration: 2) {
//            // 设置无限制扫描
//            UIView.setAnimationRepeatCount(Float(CGFloat.greatestFiniteMagnitude))
//            self.view.layoutIfNeeded()
//            
//        }
    }
    

    fileprivate func stopScanAnimation() {
        scanLineView.layer.removeAllAnimations()
    }
}

