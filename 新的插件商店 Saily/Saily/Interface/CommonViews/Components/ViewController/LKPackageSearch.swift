//
//  LKPackageSearch.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/20.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import UIKit

class LKPackageSearch: UIViewController {
    
    let coll_layout = UICollectionViewFlowLayout()
    let collection_view = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
    var search_result = [String]()
    var search_bar: UISearchBar = UISearchBar()
    var last_search = ""
    var extSession = ""
    var searchSession = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LKRoot.settings?.use_dark_mode ?? false {
            navigationController?.navigationBar.barStyle = .blackOpaque
        } else {
            navigationController?.navigationBar.barStyle = .default
        }
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = LKRoot.ins_color_manager.read_a_color("main_tint_color")
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if LKRoot.settings?.use_dark_mode ?? false {
            navigationController?.navigationBar.barStyle = .blackTranslucent
        }
        
        view.backgroundColor = LKRoot.ins_color_manager.read_a_color("main_background")
        
        self.hideKeyboardWhenTappedAround()
        
        collection_view.backgroundColor = .clear
        collection_view.dataSource = self
        collection_view.delegate = self
        collection_view.clipsToBounds = false
        collection_view.register(cellWithClass: UICollectionViewCell.self)
        view.addSubview(collection_view)
        collection_view.snp.makeConstraints { (x) in
            x.edges.equalTo(self.view.snp.edges)
        }
        
        search_bar.searchBarStyle = .prominent
        search_bar.placeholder = " 在这里搜索".localized()
        search_bar.sizeToFit()
        search_bar.isTranslucent = false
        search_bar.backgroundImage = UIImage()
        
        if LKRoot.settings?.use_dark_mode ?? false {
            search_bar.barStyle = .black
        }
        search_bar.tintColor = LKRoot.ins_color_manager.read_a_color("main_text")
        let textFieldInsideSearchBar = search_bar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = LKRoot.ins_color_manager.read_a_color("main_text")
        search_bar.delegate = self
        navigationItem.titleView = search_bar
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        
        self.searchBar(self.search_bar, textDidChange: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.search_bar.becomeFirstResponder()
        }
        
    }
    
}

extension LKPackageSearch: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.last_search = searchText
        let session = UUID().uuidString
        searchSession = session
        LKRoot.queue_dispatch.asyncAfter(deadline: .now() + 0.123) { [weak self] in
            self?.do_search(session: session, text: searchText, use_id: false)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {search_result.removeAll()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        IHProgressHUD.show()
        
        LKRoot.queue_dispatch.async {
            let session = UUID().uuidString
            self.searchSession = session
            self.do_search(session: session, text: self.last_search, use_id: false, fullSearch: true)
            DispatchQueue.main.async { [weak self] in
                UIApplication.shared.endIgnoringInteractionEvents()
                IHProgressHUD.dismiss()
                self?.collection_view.reloadData {
                }
            }
        }
        
        
    }
    
    func do_search(session: String, text: String, use_id: Bool, fullSearch: Bool = false) {
        
        search_result.removeAll()
        for item in LKRoot.container_packages where do_they_match(pack: item.value, text: text, use_id: use_id) {
            search_result.append(item.key)
            if session != self.searchSession {
                return
            }
        }
        search_result.sort()
        DispatchQueue.main.async { [weak self] in
            self?.collection_view.reloadData()
        }
        let session = UUID().uuidString
        self.extSession = session
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.extraSearch(text: text, session: session)
        }
    }
    
    func do_they_match(pack: DBMPackage, text: String, use_id: Bool = false) -> Bool {
        
        let text = text.uppercased()
        
        if use_id {
            if pack.id.uppercased().hasPrefix(text) {
                return true
            }
        } else {
            if pack.one_of_the_package_name_lol.uppercased().hasPrefix(text) {
                return true
            }
        }
        
        
        let ver = LKRoot.ins_common_operator.PAK_read_newest_version(pack: pack)
        if text.uppercased().hasPrefix("r:".uppercased()) {
            // 搜索软件
            for obj in ver.1 where obj.key.uppercased().contains(text.dropFirst(2).to_String()) {
                return true
            }
        }
        
        if text.uppercased().hasPrefix("a:".uppercased()) {
            // 搜索作者
            for obj in ver.1 where obj.value["AUTHOR"]?.uppercased().contains(text.dropFirst(2).to_String()) ?? false {
                return true
            }
        }
        
        return false
    }
    
    func extraSearch(text: String, session: String) {
        LKRoot.queue_dispatch.async {
            var text = text
            if text.hasPrefix("a:") {
                text = text.dropFirst(2).to_String()
            }
            if text.hasPrefix("r:") {
                text = text.dropFirst(2).to_String()
            }
            var extraResult = [String]()
            for item in LKRoot.container_packages where self.do_they_match_extra_search(pack: item.value, text: text) {
                extraResult.append(item.key)
            }
            extraResult.sort()
            for item in extraResult where !self.search_result.contains(item) {
                if session != self.extSession {
                    return
                }
                self.search_result.append(item)
            }
            DispatchQueue.main.async { [weak self] in
                self?.collection_view.reloadData()
            }
        }
    }
    
    func do_they_match_extra_search(pack: DBMPackage, text: String) -> Bool {
        for v1 in pack.version {
            for v2 in v1.value {
                for v3 in v2.value {
                    if v3.value.uppercased().contains(text.uppercased()) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
}

extension LKPackageSearch: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: 0, height: 0)
        size.width = self.collection_view.bounds.width / 3 - 8
        if size.width < 200 {
            size.width = self.collection_view.bounds.width / 2 - 8
        }
        if size.width < 200 {
            size.width = self.collection_view.bounds.width / 1 - 8
        }
        
        size.height = 80
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = search_result[indexPath.row]
        if let pack = LKRoot.container_packages[name] {
            presentPackage(pack: pack)
        } else {
            presentStatusAlert(imgName: "Warning", title: "未知错误".localized(), msg: "请尝试在设置页面刷新软件包".localized())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return search_result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let ret = collectionView.dequeueReusableCell(withClass: UICollectionViewCell.self, for: indexPath)
        let cell = cell_views.LKPackageCLCell()
        
        for item in ret.contentView.subviews {
            item.removeFromSuperview()
        }
        
        let pack = (LKRoot.container_packages[search_result[indexPath.row]] ?? DBMPackage()).copy()
        
        let version = LKRoot.ins_common_operator.PAK_read_newest_version(pack: pack).1
        cell.title.text = LKRoot.ins_common_operator.PAK_read_name(version: version)
        cell.auth.text = LKRoot.ins_common_operator.PAK_read_auth_name(version: version)
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
        
        ret.contentView.addSubview(cell)
        cell.snp.makeConstraints { (x) in
            x.edges.equalTo(ret.contentView.snp.edges)
        }
        cell.isUserInteractionEnabled = false
        
        return ret
    }
    
}
