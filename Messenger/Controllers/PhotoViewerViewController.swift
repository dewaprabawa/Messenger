//
//  PhotoViewerViewController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 28/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

    private var url: URL?
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    init(url:URL){
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.sd_setImage(with: url, completed: nil)
        
        //Image Constraints
        view.addSubview(imageView)
        let sf = view.safeAreaLayoutGuide
        imageView.topAnchor.constraint(equalTo: sf.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: sf.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: sf.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: sf.bottomAnchor).isActive = true
    }

}
