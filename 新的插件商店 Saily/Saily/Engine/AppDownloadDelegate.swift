//
//  AppDownloadDelegate.swift
//  Saily
//
//  Created by Lakr Aream on 2019/7/23.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//



class dld_info {
    
    var path: String    // 保存目录
    var repo: String
    var progress: Double
    
    var succeed: operation_result = .unkown
    
    var dlReq: DownloadRequest
    
    var sum5: String?
    var sha256: String?
    
    required init(fromRepo: String, to: String, dlins: DownloadRequest) {
        repo = fromRepo
        path = to
        progress = 0
        dlReq = dlins
    }
    
    required init(fromRepo: String, to: String, dlins: DownloadRequest, sha256str: String? = nil) {
        repo = fromRepo
        path = to
        progress = 0
        dlReq = dlins
        sha256 = sha256str
    }
}

class AppDownloadDelegate {
    
    
    var record = [String : dld_info]() // 软件包识别码 : 下载结构体
    
    func query_download_info(packID: String) -> (operation_result, dld_info?) {
        // 已经存在
        if let recordd = record[packID] {
            if recordd.succeed == .download_finished {
                return (.download_finished, recordd)
            }
            return (.download_exists, recordd)
        }
        return (.download_unknowd, nil)
    }
    
    func submit_download(packID: String, operation_info: DMOperationInfo, fromRepo: String, networkPath: String, UA_required: Bool = true, sha256: String? = nil) -> (operation_result, dld_info?) {
        
        let status = query_download_info(packID: packID)
        
        if status.0 != operation_result.download_unknowd {
            return (.download_exists, status.1)
        }
        
        let target = LKRoot.root_path! + "/daemon.call/download_cache/" + packID + ".deb"
        
        guard let nurl = URL(string: networkPath) else {
            return (.failed, nil)
        }
        
        var ret_dld: dld_info?
        
        let ss = DispatchSemaphore(value: 0)
        
        LKRoot.queue_alamofire.async {
            // 不存在 添加
            var h: HTTPHeaders?
            if UA_required {
                h = LKRoot.ins_networking.read_header()
            }
            let furl = URL(fileURLWithPath: target)
            let destination: DownloadRequest.Destination = { _, _ in
                return (furl, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            let dlreq = AF.download(nurl, method: .get, headers: h, to: destination)
            
            let struct_t = dld_info(fromRepo: fromRepo, to: target, dlins: dlreq, sha256str: sha256)
            self.record[packID] = struct_t
            ret_dld = struct_t
            operation_info.dowload = struct_t
            ss.signal()
            dlreq.downloadProgress(queue: LKRoot.queue_alamofire, closure: { (Progress) in
                struct_t.progress = Progress.fractionCompleted
            }).response(queue: LKRoot.queue_alamofire, completionHandler: { (respond) in
                if respond.error != nil {
                    struct_t.succeed = .failed
                } else {
                    struct_t.succeed = .download_finished
                }
            })
        }
        
        ss.wait()
        return (.success, ret_dld)
    }
    
    func submit_download_with_ticket() {
        fatalError("[E] submit_download_with_ticket not finished")
    }
    
    
}
