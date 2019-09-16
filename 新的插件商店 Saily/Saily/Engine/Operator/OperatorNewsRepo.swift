//
//  OperatorNewsRepo.swift
//  Saily
//
//  Created by Lakr Aream on 2019/5/29.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

extension app_opeerator {
    
    func NR_sync_and_download(_ CallB: @escaping (Int) -> Void) {
        LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"] = ""
        // 从数据库读取列表
        guard let repos: [DBMNewsRepo] = try? LKRoot.root_db?.getObjects(on: [DBMNewsRepo.Properties.link, DBMNewsRepo.Properties.sort_id, DBMNewsRepo.Properties.content],
                                                                         fromTable: common_data_handler.table_name.LKNewsRepos.rawValue,
                                                                         orderBy: [DBMNewsRepo.Properties.sort_id.asOrder(by: .ascending)]) else {
            print("[E] 无法从 LKNewsRepos 中获得数据，终止同步。")
            LKRoot.container_news_repo.removeAll()
//            LKRoot.container_string_store["REFRESH_IN_POGRESS_NP"] = "FALSE"
            CallB(operation_result.failed.rawValue)
            return
        }
        // 重置内存数据
        LKRoot.container_news_repo.removeAll()
        inner_01: for item in repos where item.link != nil {
            let new = DMNewsRepo()
            if item.link!.hasSuffix("/") {
                new.link = item.link!
            } else {
                new.link = item.link! + "/"
            }
            // 下载数据 丢弃所有下载失败的源数据。
            let net_semaphore = DispatchSemaphore(value: 0)
            if let request_url = URL(string: (new.link + "Info")) {
                print("[*] 准备从 " + request_url.absoluteString + " 请求数据。")
                AF.request(request_url).response(queue: LKRoot.queue_alamofire) { (respond) in
                    switch respond.result {
                    case .success:
                        if respond.data == nil {
                            item.content = "LKRP-TITLE| |加载失败\nLKRP-SUBTITLE| |请重试\n".localized()
                            LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                            print("[E] 无法解压下载的 Info 数据，丢弃")
                        }
                        // 开始解码
                        var read: String?
                        read = String(data: respond.data!, encoding: .utf8)
                        if read == nil {
                            read = String(data: respond.data!, encoding: .ascii)
                        }
                        if read == nil {
                            item.content = "LKRP-TITLE| |加载失败\nLKRP-SUBTITLE| |请重试\n".localized()
                            LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                            print("[E] 无法解压下载的 Info 数据，丢弃")
                        } else {
                            item.content = read
                        }
                    default:
                        // 无法合成下载链接，丢弃数据
                        LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                        item.content = "LKRP-TITLE| |加载失败\nLKRP-SUBTITLE| |请重试\n".localized()
                    } // switch
                    net_semaphore.signal()
                } // AF
            } else {
                // 无法合成下载链接，丢弃数据
                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                item.content = "LKRP-TITLE| |加载失败\nLKRP-SUBTITLE| |请重试\n".localized()
            }
            var signal_ed_62 = false
            LKRoot.queue_dispatch.async {
                sleep(UInt32(LKRoot.settings?.network_timeout ?? 6))
                if signal_ed_62 {
                    return
                }
                item.content = "LKRP-TITLE| |加载失败\nLKRP-SUBTITLE| |请重试\n".localized()
                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                net_semaphore.signal()
                print("[*] 网络数据超时，放弃数据。")
            }
            net_semaphore.wait()
            signal_ed_62 = true
            // 务必检查是不是错误的地址！
            if !(item.content?.contains("LKRP-NAME") ?? false) {
                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                print("if !item.content?.contains(LKRP-NAME)")
                continue inner_01
            }
            // 更新数据库
            let new_update = DBMNewsRepo()
            new_update.content = item.content
            try? LKRoot.root_db?.update(table: common_data_handler.table_name.LKNewsRepos.rawValue,
                                        on: [DBMNewsRepo.Properties.content],
                                        with: new_update,
                                        where: DBMNewsRepo.Properties.link == item.link!)
            // 解包
            NR_content_invoker(content_str: item.content ?? "", target_RAM: new, master_link: new.link)
            // 下载卡片内容
            var dl_url_str = new.link
//            var got_a_link = false
//            for_preferred_languages: for item in Locale.preferredLanguages {
//                if item.split(separator: "-").count < 2 {
//                    print("[Resumable - fatalError] for_preferred_languages - split.count < 2 - DATA: " + item)
//                    continue for_preferred_languages
//                }
//                let read = item.split(separator: "-")[0].to_String() + "-" + item.split(separator: "-")[1].to_String()
//                if new.language.contains(read) {
//                    got_a_link = true
//                    dl_url_str += read
//                    break
//                }
//            }
//            if !got_a_link {
                dl_url_str += "Base"
//            }
            // 下载卡片内容
            var read_cards: String?
            let net_semaphore_2 = DispatchSemaphore(value: 0)
            if let dl_url = URL(string: dl_url_str) {
                print("[*] 准备从 " + dl_url.absoluteString + " 请求数据。")
                AF.request(dl_url).response { (respond) in
                    if respond.data != nil {
                        read_cards = String(data: respond.data!, encoding: .utf8)
                        if read_cards == nil {
                            read_cards = String(data: respond.data!, encoding: .ascii)
                        }
                        if read_cards == nil {
                            LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                            read_cards = """
                            --> Begin Card
                            LKCD-TYPE|                                      |photo_half_with_banner_down_light
                            LKCD-TITLE|                                     |无法解析新闻内容|请联系维护者尽快修复
                            LKCD-SUBTITLE|                                  |BAD NETWORK RESULT
                            LKCD-DESSTR|                                    |--- ERROR ---
                            LKCD-PHOTO|                                     |LKINTERNAL-ERROR-LOAD
                            
                            LKCD-TITLE-COLOR|                               |0x000000
                            LKCD-SUBTITLE-COLOR|                            |0x0AAADD
                            LKCD-DESSTR-COLOR|                              |0x999999
                            
                            ---> End Card
                            """.localized()
                        }
                    }
                    net_semaphore_2.signal()
                }
            } else {
                // 无法合成下载链接，丢弃数据
            }
            var signal_ed_130 = false
            LKRoot.queue_dispatch.async {
                sleep(UInt32(LKRoot.settings?.network_timeout ?? 6))
                if signal_ed_130 {
                    return
                }
                LKRoot.container_string_store["REFRESH_CONTAIN_BAD_REFRESH_NP"]?.append(item.link ?? "")
                read_cards = """
                --> Begin Card
                LKCD-TYPE|                                      |photo_half_with_banner_down_light
                LKCD-TITLE|                                     |无法下载新闻内容|请联系维护者尽快修复
                LKCD-SUBTITLE|                                  |BAD NETWORK RESULT
                LKCD-DESSTR|                                    |--- ERROR ---
                LKCD-PHOTO|                                     |LKINTERNAL-ERROR-LOAD
                
                LKCD-TITLE-COLOR|                               |0x000000
                LKCD-SUBTITLE-COLOR|                            |0x0AAADD
                LKCD-DESSTR-COLOR|                              |0x999999
                
                ---> End Card
                """.localized()
                net_semaphore_2.signal()
                print("[*] 网络数据超时，放弃数据。")
            }
            net_semaphore_2.wait()
            signal_ed_130 = true
            new.cards = NR_cards_content_invoker(content_str: read_cards ?? "", master_link: item.link ?? "")
            // 放内存
            LKRoot.container_news_repo.append(new)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if LKRoot.manager_reg.nr.initd {
                    LKRoot.manager_reg.nr.update_user_interface {
                    }
                }
            }
        } // for
//        LKRoot.container_string_store["REFRESH_IN_POGRESS_NP"] = "FALSE"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if LKRoot.manager_reg.nr.initd {
                LKRoot.manager_reg.nr.update_user_interface {
                }
            }
        }
        
        CallB(operation_result.success.rawValue)
    } // NR_sync_and_download

    func NR_content_invoker(content_str: String, target_RAM: DMNewsRepo, master_link: String) {
        for_sign: for line in content_str.split(separator: "\n") {
            // 写入可写属性
            var read_opt: String?
            // 分离诸注释
            if line.contains("#") {
                read_opt = line.split(separator: "#").first?.to_String()
                if read_opt == "" || read_opt == nil || line.to_String().hasPrefix("#") {
                    continue for_sign
                }
            } else {
                read_opt = line.to_String()
            }
            // 取头和身子
            let sp_read = (read_opt ?? "").split(separator: "|")
            if sp_read.count < 3 {
                // 无效行，丢弃 ouo
                continue for_sign
            }
            var name: String = sp_read.first?.to_String() ?? ""
            var body: String = ""
            for i in 3...sp_read.count {
                body += sp_read[i - 1] + "\n"
            }
            body = body.dropLast().to_String()
            name = name.drop_space()
            body = body.drop_space()
            // 写入数据咯
            switch name {
            case "LKRP-NAME": target_RAM.name = body
            case "LKRP-PROVIDE-LANGUAGE":
                target_RAM.language.removeAll()
                for language in body.split(separator: ",") {
                    target_RAM.language.append(language.to_String())
                }
            case "LKRP-ICON":
                var bodyy = body
                if bodyy.hasPrefix("./") {
                    bodyy = bodyy.dropFirst().to_String()
                    if master_link.hasSuffix("/") {
                        bodyy = master_link + bodyy.dropFirst().to_String()
                    } else {
                        bodyy = master_link + bodyy
                    }
                }
                target_RAM.icon = bodyy
            case "LKRP-TITLE": target_RAM.title = body
            case "LKRP-SUBTITLE": target_RAM.sub_title = body
            case "LKRP-TITLE-COLOR": target_RAM.title_color = body
            case "LKRP-SUBITLE-COLOR": target_RAM.subtitle_color = body
            default: print("[?] 这啥玩意？" + name)
            }
        }
    } // NR_content_invoker
    
    func NR_cards_content_invoker(content_str: String, master_link: String) -> [DMNewsCard] {
        
        var ins_card = DMNewsCard()
        var ret = [DMNewsCard]()
        
        for_sign: for line in content_str.split(separator: "\n") {
            // 写入可写属性
            var read_opt: String?
            // 分离诸注释
            if line.contains("#") {
                read_opt = line.split(separator: "#").first?.to_String()
                if read_opt == "" || read_opt == nil || line.to_String().hasPrefix("#") {
                    continue for_sign
                }
            } else {
                read_opt = line.to_String()
            }
            
            if read_opt!.contains("--> Begin Card") {
                ins_card = DMNewsCard()
                continue for_sign
            }
            
            if read_opt!.contains("---> End Card") {
                ret.append(ins_card)
                continue for_sign
            }
            
            // 取头和身子
            let sp_read = (read_opt ?? "").split(separator: "|")
            if sp_read.count < 3 {
                // 无效行，丢弃 ouo
                continue for_sign
            }
            var name: String = sp_read.first?.to_String() ?? ""
            var body: String = ""
            for i in 3...sp_read.count {
                body += sp_read[i - 1] + "\n"
            }
            body = body.dropLast().to_String()
            name = name.drop_space()
            body = body.drop_space()
            // 写入数据咯
            switch name {
            case "LKCD-TYPE":
                switch body {
                case "photo_full_with_banner_down_dark": ins_card.type = card_type.photo_full_with_banner_down_dark
                case "photo_half_with_banner_down_light": ins_card.type = card_type.photo_half_with_banner_down_light
                case "river_view_animate": ins_card.type = card_type.river_view_animate
                case "river_view_static": ins_card.type = card_type.river_view_static
                default: ins_card.type = card_type.photo_full
                }
            case "LKCD-TITLE": ins_card.main_title_string = body
            case "LKCD-SUBTITLE": ins_card.sub_title_string = body
            case "LKCD-DESSTR": ins_card.description_string = body
            case "LKCD-PHOTO":
                for photo in body.split(separator: ",") {
                    var photo = photo.to_String().drop_space()
                    if photo.hasPrefix("./") {
                        if master_link.hasSuffix("/") {
                            photo = master_link + photo.dropFirst().to_String()
                        } else {
                            photo = master_link + photo
                        }
                    }
                    ins_card.image_container.append(photo)
                }
            case "LKCD-TITLE-COLOR": ins_card.main_title_string_color = body
            case "LKCD-SUBTITLE-COLOR": ins_card.sub_title_string_color = body
            case "LKCD-DESSTR-COLOR": ins_card.description_string_color = body
            case "LKCD-CONTENTS":
                    var link = body.drop_space()
                    if link.hasPrefix("./") {
                        if master_link.hasSuffix("/") {
                            link = master_link + link.dropFirst().to_String()
                        } else {
                            link = master_link + link
                        }
                    }
                ins_card.content = link
            default: print("[?] 这啥玩意？" + name)
            }
        }
        return ret
    } // NR_cards_content_invoker
    
    func NR_download_card_contents(target: DMNewsCard, master_link: String, _ result_str: @escaping (String) -> Void) {
        guard let dl_url = URL(string: target.content ?? "") else {
            print("[Resumable - fatalError] 无法内容创建下载链接。")
            return
        }
        
        let network_semaphore = DispatchSemaphore(value: 0)
        var signaled_here = false
        var ret_str: String?
        
        print("[*] 准备从 " + dl_url.absoluteString + " 请求数据。")
        
        AF.request(dl_url).response(queue: LKRoot.queue_alamofire) { (ret) in
            guard ret.data != nil else {
                print("[Resumable - fatalError] 无下载内容。")
                signaled_here = true
                network_semaphore.signal()
                return
            }
            ret_str = String(data: ret.data!, encoding: .utf8)
            if ret_str == nil {
                ret_str = String(data: ret.data!, encoding: .ascii)
            }
            signaled_here = true
            network_semaphore.signal()
            return
        }
        
        LKRoot.queue_alamofire.async {
            sleep(UInt32(LKRoot.settings?.network_timeout ?? 6))
            if !signaled_here {
                print("[*] 网络数据超时，放弃数据。")
                network_semaphore.signal()
            }
        }
        
        network_semaphore.wait()
        
        if ret_str == "" || ret_str == nil {
            ret_str = "--> Begin Section |text_inherit_saying|错误|\n尝试下载卡片内容失败了。\n---> End Section".localized()
        }
    
        // 对软链接进行修复
        var ret_str_fixed = ""
        for item in (ret_str ?? "").split(separator: "\n") {
            var read = item.to_String()
            if read.hasPrefix("--> Begin Section |") && read.contains("|./") {
                read = ""
                for content in item.to_String().split(separator: "|") {
                    var read_inner = content.to_String()
                    if read_inner.hasPrefix("./") {
                        if master_link.hasSuffix("/") {
                            read_inner = master_link.dropLast().to_String() + read_inner.dropFirst().to_String()
                        } else {
                            read_inner = master_link + read_inner.dropFirst().to_String()
                        }
                    }
                    read += read_inner + "|"
                }
                ret_str_fixed += read + "\n"
            } else {
                ret_str_fixed += read + "\n"
            }
        }
        
        result_str(ret_str_fixed)
        
    } // NR_download_card_contents
    
}

