//
//  CustomFlyout.swift
//  AddressMap
//
//  Created by Md. Arifuzzaman Arif on 7/16/14.
//  Copyright (c) 2014 md arifuzzaman. All rights reserved.
//

import UIKit

class CustomFlyout: UIView {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblPosition: UILabel!
    @IBOutlet var lblIcon: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */

}
