#! /usr/bin/python
# -*- coding: UTF-8 -*-
# 添加OC垃圾代码
import os,sys
import random
import string
import re
import md5
import time
import json
import shutil
import hashlib 
import time
import argparse

import sys 
reload(sys) 
sys.setdefaultencoding("utf-8")

script_path = os.path.split(os.path.realpath(sys.argv[0]))[0]
#垃圾代码临时存放目录
target_ios_folder = os.path.join(script_path, "./target_ios")
#备份目录
backup_ios_folder = os.path.join(script_path, "./backup_ios")

#忽略文件列表，不给这些文件添加垃圾函数
ignore_file_list = ["main.m", "GNative.mm", "MobClickCpp.mm"]
#忽略文件夹列表，不处理这些文件夹下的文件
ignore_folder_list = ["thirdparty","Support",".svn","paycenter","UMMobClick.framework","UMessage_Sdk_1.5.0a","TencentOpenApi_IOS_Bundle.bundle",
                        "TencentOpenAPI.framework","Bugly.framework","AlipaySDK.framework","AlipaySDK.bundle"]

#创建函数数量范围
create_func_min = 2
create_func_max = 10
            
#创建垃圾文件数量范围
create_file_min = 10
create_file_max = 20
            
#oc代码目录
ios_src_path = ""

#确保添加的函数不重名
funcname_set = set()

#单词列表，用以随机名称
with open(os.path.join(script_path, "./word_list.json"), "r") as fileObj:
    word_name_list = json.load(fileObj)

#获取一个随机名称
def getOneName():
    global word_name_list
    return random.choice(word_name_list)

#oc代码头文件函数声明
def getOCHeaderFuncText():
    funcName = getOneName()
    text = "\n- (void)%s" %(funcName)
    return text

#oc代码函数实现模板
def getOCFuncText(header_text):
    arg1 = getOneName()
    text = [
        header_text + "\n",
        "{\n",
        "\tNSLog(@\"%s\");\n" %(arg1),
        "}\n"
    ]
    return "".join(text)

#oc代码以@end结尾，在其前面添加text
def appendTextToOCFile(file_path, text):
    with open(file_path, "r") as fileObj:
        old_text = fileObj.read()
        fileObj.close()
        end_mark_index = old_text.rfind("@end")
        if end_mark_index == -1:
            print "\t非法的结尾格式: " + file_path
            return
        new_text = old_text[:end_mark_index]
        new_text = new_text + text + "\n"
        new_text = new_text + old_text[end_mark_index:]

    with open(file_path, "w") as fileObj:
        fileObj.write(new_text)

#处理单个OC文件，添加垃圾函数。确保其对应头文件存在于相同目录
def dealWithOCFile(filename, file_path):
    global target_ios_folder,create_func_min,create_func_max,funcname_set
    funcname_set.clear()
    end_index = file_path.rfind(".")
    pre_name = file_path[:end_index]
    header_path = pre_name + ".h"
    if not os.path.exists(header_path):
        print "\t相应头文件不存在：" + file_path
        return

    new_func_num = random.randint(create_func_min, create_func_max)
    print "\t给%s添加%d个方法" %(filename, new_func_num)
    for i in range(new_func_num):
        header_text = getOCHeaderFuncText()
        # print "add %s to %s" %(header_text, header_path.replace(target_ios_folder, ""))
        appendTextToOCFile(header_path, header_text + ";\n")
        funcText = getOCFuncText(header_text)
        appendTextToOCFile(file_path, funcText)

#扫描parent_folder，添加垃圾函数，处理了忽略列表
def addOCFunctions(parent_folder):
    global ignore_file_list
    for parent, folders, files in os.walk(parent_folder):
        need_ignore = None
        for ignore_folder in ignore_folder_list:
            if parent.find("/" + ignore_folder) != -1:
                need_ignore = ignore_folder
                break
        if need_ignore:
            print "\t忽略文件夹" + ignore_folder
            continue

        for file in files:
            if file.endswith(".m") or file.endswith(".mm"):
                if file in ignore_file_list:
                    continue
                dealWithOCFile(file, os.path.join(parent, file))

#新创建的垃圾文件header模板
def getOCHeaderFileText(class_name):
    global funcname_set
    new_func_name = getOneName()
    while new_func_name in funcname_set:
        new_func_name = getOneName()
    funcname_set.add(new_func_name)

    text = [
        "#import <Foundation/Foundation.h>\n\n",
        "@interface %s : NSObject {\n" %(class_name),
        "\tint %s;\n" %(new_func_name),
        "\tfloat %s;\n" %(getOneName()),
        "}\n\n@end"
    ]
    return string.join(text)

#新创建的垃圾文件mm模板
def getOCMMFileText(class_name):
    text = [
        '#import "%s.h"\n\n' %(class_name),
        "@implementation %s\n" %(class_name),
        "\n\n@end"
    ]
    return string.join(text)

#添加垃圾文件到parent_folder/trash/
def addOCFile(parent_folder):
    global create_file_min, create_file_max
    file_list = []
    target_folder = os.path.join(parent_folder, "trash")
    if os.path.exists(target_folder):
        shutil.rmtree(target_folder)
    os.mkdir(target_folder)
    file_num = random.randint(create_file_min, create_file_max)
    for i in range(file_num):
        file_name = getOneName()
        file_list.append("#import \"" + file_name + ".h\"")
        print "\t创建OC文件 trash/" + file_name
        header_text = getOCHeaderFileText(file_name)
        full_path = os.path.join(target_folder, file_name + ".h")
        with open(full_path, "w") as fileObj:
            fileObj.write(header_text)
            fileObj.close()

        mm_text = getOCMMFileText(file_name)
        full_path = os.path.join(target_folder, file_name + ".mm")
        with open(full_path, "w") as fileObj:
            fileObj.write(mm_text)
    all_header_text = "\n".join(file_list)

    with open(os.path.join(parent_folder, "Trash.h"), "w") as fileObj:
        fileObj.write(all_header_text)
        fileObj.close()

#解析参数       
def parse_args():
    parser = argparse.ArgumentParser(description='oc垃圾代码生成工具.')
    parser.add_argument('--oc_folder', dest='oc_folder', type=str, required=True, help='OC代码所在目录')
    parser.add_argument('--replace', dest='replace_ios', required=False, help='直接替换oc源代码', action="store_true")

    args = parser.parse_args()
    return args

def main():
    app_args = parse_args()
    global ios_src_path, backup_ios_folder, target_ios_folder
    ios_src_path = app_args.oc_folder
    if not os.path.exists(ios_src_path):
        print "oc_folder path not exist."
        exit(0)

    print "拷贝OC代码到target_ios"
    if os.path.exists(target_ios_folder):
        shutil.rmtree(target_ios_folder)
    shutil.copytree(ios_src_path, target_ios_folder)

    print "开始创建oc文件到trash目录"
    addOCFile(target_ios_folder)
    print "\n开始添加oc方法"
    addOCFunctions(target_ios_folder)

    if app_args.replace_ios:
        print "\n用target_ios替换原目录"
        print "\t备份OC代码到" + os.path.abspath(backup_ios_folder)
        if os.path.exists(backup_ios_folder):
            shutil.rmtree(backup_ios_folder)
        shutil.copytree(ios_src_path, backup_ios_folder)

        print "\t开始替换"
        trash_folder = os.path.join(ios_src_path, "trash")
        if os.path.exists(trash_folder):
            shutil.rmtree(trash_folder)
        os.mkdir(trash_folder)

        for parent, folders, files in os.walk(target_ios_folder):
            for file in files:
                if file.endswith(".h") or file.endswith(".m") or file.endswith(".mm"):
                    full_path = os.path.join(parent, file)
                    target_path = full_path.replace(target_ios_folder, ios_src_path)
                    shutil.copy(full_path, target_path)
        print "替换成功\n需要在Xcode上重新添加trash文件下的oc文件"
    else:
        print "垃圾代码生成完毕，垃圾代码目录：" + os.path.abspath(target_ios_folder)

    print "\nfinished"

if __name__ == "__main__":
    main()
