//
//  LKOperationStatusTVCell.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/24.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

// 先偷个懒

extension cell_views {
    
    class LKOperationStatusTVCell: UITableViewCell {
        
        let icon = UIImageView()
        let title = UILabel()
        let link = UILabel()
        let sep = UIView()
        let prog = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            icon.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
            link.translatesAutoresizingMaskIntoConstraints = false
            sep.translatesAutoresizingMaskIntoConstraints = false
            prog.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(icon)
            contentView.addSubview(title)
            contentView.addSubview(link)
            contentView.addSubview(sep)
            contentView.addSubview(prog)
            
            icon.setRadiusINT(radius: 6)
            icon.contentMode = .scaleAspectFit
            icon.snp.makeConstraints { (x) in
                x.centerY.equalTo(contentView.snp.centerY)
                x.left.equalTo(contentView.snp.left).offset(24)
                x.height.equalTo(33)
                x.width.equalTo(33)
            }
            
            sep.backgroundColor = .lightGray
            sep.snp.makeConstraints { (x) in
                x.left.equalTo(icon.snp.right).offset(12)
                x.bottom.equalTo(contentView.snp.bottom)
                x.right.equalTo(contentView.snp.right)
                x.height.equalTo(0.5)
            }
            
            link.font = .boldSystemFont(ofSize: 12)
            link.textColor = LKRoot.ins_color_manager.read_a_color("table_view_link")
            link.snp.makeConstraints { (x) in
                x.bottom.equalTo(icon.snp.bottom).offset(2)
                x.left.equalTo(sep.snp.left).offset(4)
                x.right.equalTo(contentView.snp.right)
                x.height.equalTo(14)
            }
            
            title.font = .boldSystemFont(ofSize: 18)
            title.textColor = LKRoot.ins_color_manager.read_a_color("table_view_title")
            title.snp.makeConstraints { (x) in
                x.bottom.equalTo(link.snp.top).offset(0)
                x.left.equalTo(link.snp.left)
                x.right.equalTo(contentView.snp.right)
                x.top.equalTo(contentView.snp.top).offset(6)
            }
            
            prog.font = .boldSystemFont(ofSize: 12)
            prog.textColor = LKRoot.ins_color_manager.read_a_color("table_view_link")
            prog.snp.makeConstraints { (x) in
                x.centerY.equalTo(contentView.snp.centerY)
                x.right.equalTo(contentView.snp.right).offset(-12)
                x.height.equalTo(20)
                x.width.equalTo(55)
            }
        }
        
        var download: dld_info?
        
        func downloadMonitor(dldinfo: dld_info?) {
            download = nil
            download = dldinfo
            doMonitor()
        }
        
        func doMonitor() {
            if download?.succeed == .download_finished {
                prog.text = "就绪".localized()
                return
            }
            let progress = Int((download?.progress ?? 0) * 100)
            prog.text = String(progress) + "%"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.doMonitor()
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
}
