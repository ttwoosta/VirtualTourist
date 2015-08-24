//
//  VTImageCell.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/21/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit

class VTImageCell: UICollectionViewCell {
    
    var identifier: String!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // The property uses a property observer. Any time its
    // value is set it canceles the previous NSURLSessionTask
    weak var taskToCancelIfReused: NSURLSessionTask? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    override var selected: Bool {
        didSet {
            imageView.alpha = selected ? 0.5 : 1.0
        }
    }
}
