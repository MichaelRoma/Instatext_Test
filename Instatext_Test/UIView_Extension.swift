//
//  UIView_Extension.swift
//  Instatext_Test
//
//  Created by Mykhailo Romanovskyi on 22.01.2022.
//

import Foundation
import UIKit 
//MARK: Make a screenshot
extension UIView {
    func takeScreenshot() -> UIImage {
        //begin
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        // draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        // get Image
        let  image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = image else {
            return UIImage()
        }
        return image
    }
}
