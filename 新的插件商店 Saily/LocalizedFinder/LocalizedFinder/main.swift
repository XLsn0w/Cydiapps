//
//  main.swift
//  LocalizedFinder
//
//  Created by Lakr Aream on 2019/7/21.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

import Foundation

//print("Searching...")
//
//let rdir = "/Users/ouo/Documents/GitHub/Tweak-Store/Saily"
//let lb = "\n"
//let quo = "\""
//
//let p = [".", "l", "o", "c", "a", "l", "i", "z", "e", "d", "(", ")"]
//
//var testBool: ObjCBool = false
//
//var outWithTag = [String]()
//
//func searchFile(_ path: String) {
//    if path.hasSuffix(".swift") {
//        if let string = try? String(contentsOfFile: path) {
//
//            let charas = Array(string)
//
//            var findquo = false
//            var quoEnd = false
//            var world = ""
//            var index = 0
//
//            for c in charas {
//                let cs = String(c)
//                if cs == lb {
//                    findquo = false
//                    quoEnd = false
//                    world = ""
//                    index = 0
//                } else {
//                    if quoEnd == true {
//                        if index >= p.count - 1 {
//                            if !outWithTag.contains(world) {
//                                outWithTag.append(world)
//                            }
//                            findquo = false
//                            quoEnd = false
//                            world = ""
//                            index = 0
//                        } else {
//                            if cs == p[index] {
//                                index += 1
//                            } else {
//                                index = 0
//                                findquo = false
//                                quoEnd = false
//                                world = ""
//                                index = 0
//                            }
//                        }
//                    } else {
//                        if cs == quo {
//                            if findquo {
//                                quoEnd = true
//                            } else {
//                                findquo = true
//                                world = ""
//                                quoEnd = false
//                            }
//                        } else if findquo {
//                            world += cs
//                        }
//                    }
//
//                }
//            }
//        }
//    }
//}
//
//func searchDir(_ dir: String) {
//
//    if let filenames = try? FileManager.default.contentsOfDirectory(atPath: dir) {
//        for filename in filenames {
//            let path = dir + "/" + filename
//            if FileManager.default.fileExists(atPath: path, isDirectory: &testBool) {
//                if testBool.boolValue {
//                    searchDir(path)
//                } else {
//                    searchFile(path)
//                }
//            }
//        }
//    }
//
//}
//
//searchDir(rdir)
//
//for item in outWithTag {
//    print(quo + item + quo + " = " + quo + "" + quo + ";")
//}

extension String {
    func cleanRN() -> String {
        var newString = self.replacingOccurrences(of: "\r\n", with: "\n", options: .literal, range: nil)
        newString = newString.replacingOccurrences(of: "\r", with: "\n", options: .literal, range: nil)
        return newString
    }
    func drop_space() -> String {
        var ret = self
        while ret.hasPrefix(" ") {
            ret = ret.dropFirst().to_String()
        }
        while ret.hasSuffix(" ") {
            ret = ret.dropLast().to_String()
        }
        return ret
    }
}

extension Substring {
    func to_String() -> String {
        return String(self)
    }
}

var read = try String(contentsOfFile: "/Users/ouo/Documents/GitHub/Saily-Store/Saily/vi.lproj/Localizable.strings")

var container = [String : String]()

for item in read.split(separator: "\n") {
    let r = item.to_String().drop_space()
    let left = r.split(separator: "\"").first?.to_String() ?? ""
    let right = r.dropLast().split(separator: "\"").last?.to_String() ?? ""
    container[left] = right
}

for item in container {
    print("\"" + item.key + "\"" + " = \"" + item.value + "\";")
}
