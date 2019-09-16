//
//  CardButton.swift
//  Saily
//
//  Created by Lakr Aream on 2019/6/2.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

class UICardButton: UIButton {
    
    var card_info: DMNewsCard
    var card_index: CGPoint
    
    var card_type: card_type
    var card_container: UIView
    var card_self: UIView
    
    public var start_postion_in_window = CGPoint()
    
    required init(info: DMNewsCard, index: CGPoint, type: card_type, container: UIView, selff: UIView) {
        card_info = info
        card_index = index
        card_type = type
        card_container = container
        card_self = selff
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("[Resumable - fatalError] UICardButton - init(coder:)")
        card_info = DMNewsCard()
        card_index = CGPoint()
        
        card_type = .photo_full
        card_container = UIView()
        card_self = UIView()
        super.init(coder: aDecoder)
    }
    
}
