//
//  VTBottomBar.swift
//  VirtualTourist
//
//  Created by Tu Tong on 8/23/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit


enum VTBottomBarStyle {
    case Fetching, TryAgain, NewCollection, DeletePhotos
}


class VTBottomBar: UIToolbar {
    
    var style: VTBottomBarStyle = .Fetching {
        didSet {
            switch style {
            case .Fetching:
                setItems([self.flex1, self.cancelItem, self.flex2], animated: true)
            case .TryAgain:
                setItems([self.flex1, self.tryAgainItem, self.flex2], animated: true)
            case .NewCollection:
                setItems([self.flex1, self.newCollectionItem, self.flex2], animated: true)
            case .DeletePhotos:
                setItems([self.flex1, self.removePhotoItem, self.flex2], animated: true)
            }
        }
    }
    
    
    
    lazy var flex1: UIBarButtonItem! = {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    }()
    
    lazy var flex2: UIBarButtonItem! = {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    }()
    
    lazy var newCollectionItem: UIBarButtonItem! = {
        return UIBarButtonItem(title: "New Collection", style: .Plain, target: nil, action: nil)
    }()
    
    lazy var removePhotoItem: UIBarButtonItem! = {
        return UIBarButtonItem(title: "Remove Selected Pictures", style: .Plain, target: nil, action: nil)
    }()
    
    lazy var cancelItem: UIBarButtonItem! = {
        return UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
    }()
    
    lazy var tryAgainItem: UIBarButtonItem! = {
        return UIBarButtonItem(title: "Try Again", style: .Plain, target: nil, action: nil)
    }()
    
}