//
//  LKTVCellPutPackage.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/20.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension cell_views {
    
    static func LKTVCellPutPackage(cell: LKIconTVCell, pack: DBMPackage) {
        
        var pack = pack.copy()
        
        if let packer = LKRoot.container_packages[pack.id] {
            pack = packer
        }
        let version = LKRoot.ins_common_operator.PAK_read_newest_version(pack: pack).1
        cell.title.text = LKRoot.ins_common_operator.PAK_read_name(version: version)
        cell.link.text = LKRoot.ins_common_operator.PAK_read_description(version: version)
        let icon_link = LKRoot.ins_common_operator.PAK_read_icon_addr(version: version)
        if cell.link.text == "" {
            cell.link.text = "软件包无可用描述。".localized()
        }
        if icon_link.hasPrefix("http") {
            cell.icon.sd_setImage(with: URL(string: icon_link), placeholderImage: UIImage(named: "Gary")) { (img, err, _, _) in
                if err != nil || img == nil {
                    cell.icon.image = UIImage(named: "Error")
                }
            }
        } else if icon_link.hasPrefix("NAMED:") {
            let link = icon_link.dropFirst("NAMED:".count).to_String()
            cell.icon.sd_setImage(with: URL(string: link), placeholderImage: UIImage(named: "Gary")) { (img, err, _, _) in
                if err != nil || img == nil {
                    cell.icon.image = UIImage(named: "Error")
                }
            }
        } else {
            if let some = UIImage(contentsOfFile: icon_link) {
                cell.icon.image = some
            } else {
                cell.icon.image = UIImage(named: TWEAK_DEFAULT_IMG_NAME)
            }
        }
    }
    
}
