//
//  DetecorQRCodeViewController.swift
//  二维码案例
//
//  Created by 李胜兵 on 16/11/12.
//  Copyright © 2016年 付公司. All rights reserved.
//

import UIKit

class DetecorQRCodeViewController: UIViewController {
    
    @IBOutlet weak var sourceImageView: UIImageView!
    
    @IBAction func DetecorQRCodeClick() {
        
        guard let image = sourceImageView.image else { return }
        let result = QRCodeTool.detectorQRCode(image: image, isDrawQRCodeFrame: true)
        let strArr = result.resultStrs
        let resultImage = result.resultImage
        sourceImageView.image = resultImage
    
        let alertVC = UIAlertController(title: "结果", message: strArr?.description, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "关闭", style: .default) { (action : UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)

    }
}
