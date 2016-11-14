//
//  QRCodeTool.swift
//  二维码案例
//
//  Created by 李胜兵 on 16/11/13.
//  Copyright © 2016年 付公司. All rights reserved.
//

import UIKit
import AVFoundation

typealias ScanResultBlock = ([String]) -> ()
class QRCodeTool: NSObject {
    static let shareInstance = QRCodeTool()
    
    lazy fileprivate var input : AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input : AVCaptureDeviceInput?
        do {
            try input = AVCaptureDeviceInput(device: device)
            return input
        } catch {
            print(Error.self)
            return nil
        }
    }()
    
    lazy fileprivate var output : AVCaptureMetadataOutput? = {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        return output
    }()
    
    lazy fileprivate var session : AVCaptureSession? = {
        let session = AVCaptureSession()
        return session
    }()
    
    lazy fileprivate var vedioLayer : AVCaptureVideoPreviewLayer = {
        let vedioLayer = AVCaptureVideoPreviewLayer(session: self.session)
        return vedioLayer!
    }()
    
    fileprivate var resultBlock : ScanResultBlock?
    fileprivate var isDrawFrame : Bool = false
    fileprivate var origenViewRect : CGRect = CGRect.zero

    // MARK: - 扫描二维码方法
    func starScanQRCode(inView : UIView,isDrawFrame : Bool, resultBlock : @escaping (_ resultStrs : [String]) -> ()) {
        self.resultBlock = resultBlock
        self.isDrawFrame = isDrawFrame
    
        if session!.canAddInput(input), session!.canAddOutput(output) {
            session!.addInput(input)
            session!.addOutput(output)
        }

        output?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        if inView.layer.sublayers == nil {
            vedioLayer.frame = inView.layer.bounds
            inView.layer.insertSublayer(vedioLayer, at: 0)
        }else {
            let subLayers = inView.layer.sublayers
            if !(subLayers?.contains(vedioLayer))! {
                vedioLayer.frame = inView.layer.bounds
                inView.layer.insertSublayer(vedioLayer, at: 0)
            }
        }
        session?.startRunning()
    }
    
    func stopScan()
    {
        session?.stopRunning()
    }
    
    // MARK: - 设置扫描区域:外面必须是frame,不能是bounds
    func setScanRectInterest(origenViewRect : CGRect) {
        self.origenViewRect = origenViewRect
        let kScreenW  = UIScreen.main.bounds.width
        let kScreenH  = UIScreen.main.bounds.height
        let x : CGFloat = origenViewRect.origin.x / kScreenW
        let y : CGFloat = origenViewRect.origin.y / kScreenH
        let width : CGFloat = origenViewRect.size.width / kScreenW
        let height : CGFloat = origenViewRect.size.height / kScreenH
        output?.rectOfInterest = CGRect(x: y, y: x, width: height, height: width)
        addShapeLayer(origenViewRect: origenViewRect)
    }
    
    // MARK: - 识别二维码类方法
    class func detectorQRCode(image : UIImage, isDrawQRCodeFrame : Bool) -> (resultStrs : [String]?, resultImage : UIImage) {

        let imageCI = CIImage(image: image)
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        let features = dector?.features(in: imageCI!)
        var resultImage = image
        var results  = [String]()
        
        for feature in features! {
            let qrFeature = feature as! CIQRCodeFeature
            results.append(qrFeature.messageString!)

            if isDrawQRCodeFrame {
                resultImage = drawFrame(image: resultImage, feature: qrFeature)
            }
        }
        return (results,resultImage)
    
    }
    
    // MARK: - 生成二维码类方法
    class func generatorQRCode(inputStr : String, centerImage : UIImage?) -> UIImage {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = inputStr.data(using: String.Encoding.utf8)
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        var image = filter?.outputImage
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        image = image?.applying(transform)
        var resultImage = UIImage(ciImage: image!)
        if centerImage != nil {
            resultImage = getResultImage(sourceImage: resultImage, centerImage: centerImage!)
        }
        return resultImage
    }
}


// MARK: - 私有方法
extension QRCodeTool {
    class fileprivate func drawFrame(image : UIImage,feature : CIQRCodeFeature) -> UIImage {
        let size = image.size
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        let bounds = feature.bounds
        let path = UIBezierPath(rect: bounds)
        UIColor.orange.setStroke()
        path.lineWidth = 8
        path.stroke()
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }
    
     class fileprivate func getResultImage(sourceImage : UIImage, centerImage : UIImage) -> UIImage {
        let size = sourceImage.size
        UIGraphicsBeginImageContext(size)
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let width : CGFloat = 160
        let height : CGFloat = 160
        let x : CGFloat = (size.width - width) * 0.5
        let y : CGFloat = (size.height - height) * 0.5
        centerImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }

    fileprivate func addShapeLayer(origenViewRect : CGRect) {
        removeDrawFrame()
        
        let shepLayer = CAShapeLayer()
        let path = UIBezierPath(rect: origenViewRect)
        shepLayer.fillColor = UIColor.init(white: 0, alpha: 0.35).cgColor
        
        let shepLayerWidth : CGFloat = origenViewRect.size.width
        let startX : CGFloat = origenViewRect.origin.x + 10 ;
        let startY : CGFloat = -origenViewRect.origin.y;
        
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: startX+shepLayerWidth, y: startY))
        path.addLine(to: CGPoint(x: startX+shepLayerWidth, y: startY+shepLayerWidth))
        path.addLine(to: CGPoint(x: startX, y: startY+shepLayerWidth))
        
        path.addLine(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: 0, y: startY))
        
        path.addLine(to: CGPoint(x: 0, y: UIScreen.main.bounds.height))
        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height))
        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: startY))
        shepLayer.path = path.cgPath
        vedioLayer.addSublayer(shepLayer)
    }
}

extension QRCodeTool : AVCaptureMetadataOutputObjectsDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if isDrawFrame {
          removeDrawFrame()
        }
        addShapeLayer(origenViewRect: origenViewRect)
        var resultStrs = [String]()
        
        for obj in metadataObjects {
            if (obj as! NSObject).isKind(of: AVMetadataMachineReadableCodeObject.classForCoder()) {
                let resultObj = self.vedioLayer.transformedMetadataObject(for: obj as! AVMetadataObject)
                let qrCodeObj = resultObj as! AVMetadataMachineReadableCodeObject
                resultStrs.append(qrCodeObj.stringValue)
                
                if isDrawFrame {
                    drawFrame(qrCodeObj: qrCodeObj)
                }
            }
        }
        
        if resultBlock != nil {
            resultBlock!(resultStrs)
        }
    }
    
    fileprivate func drawFrame(qrCodeObj : AVMetadataMachineReadableCodeObject) {
        
        let corners = qrCodeObj.corners
        let shapLayer = CAShapeLayer()
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.strokeColor = UIColor.red.cgColor
        shapLayer.lineWidth = 1
        
        let path = UIBezierPath()
        var index = 0
        for corner in corners! {
            let pointDict = corner as! CFDictionary
            let point = CGPoint(dictionaryRepresentation: pointDict)
            if index == 0 {
                path.move(to: point!)
            }else {
                path.addLine(to: point!)
            }
            index += 1
        }
        path.close()
        shapLayer.path = path.cgPath
        vedioLayer.addSublayer(shapLayer)
    }
    
    fileprivate func removeDrawFrame() {
        guard let subLayers = vedioLayer.sublayers else { return }
        for subLayer in subLayers {
            if subLayer.isKind(of: CAShapeLayer.classForCoder()) {
                    subLayer.removeFromSuperlayer()
            }
        }
    }
}






