//
//  GeneratorQRCodeViewController.swift
//  二维码案例
//
//  Created by 李胜兵 on 16/11/12.
//  Copyright © 2016年 付公司. All rights reserved.
//

import UIKit
import CoreImage

class GeneratorQRCodeViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeTextTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let str = qrCodeTextTV.text ?? "XJDomain"
        let resultImage =  QRCodeTool.generatorQRCode(inputStr: str, centerImage: UIImage(named: "default_header"))
        qrCodeImageView.image = resultImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrCodeTextTV.becomeFirstResponder()
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        let str = qrCodeTextTV.text ?? "123"
        let resultImage =  QRCodeTool.generatorQRCode(inputStr: str, centerImage: UIImage(named: "default_header"))
        qrCodeImageView.image = resultImage
    }

}
