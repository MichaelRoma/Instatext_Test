//
//  Phot.swift
//  Instatext_Test
//
//  Created by Mykhailo Romanovskyi on 22.01.2022.
//

import Foundation
import UIKit

class Phot: UIViewController {
 var imageView = UIImageView ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)
        imageView.backgroundColor = .green
        
    }
}
