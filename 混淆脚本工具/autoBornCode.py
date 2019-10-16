#! /usr/bin/python
# -*- coding: UTF-8 -*-
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

script_path = os.path.split(os.path.realpath(sys.argv[0]))[0]

resource_path = ""
target_path = os.path.join(script_path, "target_resource")

#匹配规则，路径包含path_include且不包含path_exclude的才会创建对应类型的文件
match_rule = {
    ".png": {
        "path_include": os.path.sep + "res",
    },
    ".lua": {
        # "path_include": "src",
        "path_exclude": os.path.sep + "res",
    },
}
#确保添加的函数不重名
funcname_set = set()

#单词列表，用以随机名称
with open(os.path.join(script_path, "./word_list.json"), "r") as fileObj:
    word_name_list = json.load(fileObj)

#获取一个随机名称
def getOneName():
    global word_name_list
    return random.choice(word_name_list)

# 获取lua垃圾方法
def getLuaFuncText():
    global funcname_set
    new_func_name = getOneName()
    while new_func_name in funcname_set:
        new_func_name = getOneName()
    funcname_set.add(new_func_name)

    argv_name = getOneName()
    text = [
        '\nlocal function '+new_func_name+'()\n',
        '\tlocal %s = %d + %d\n' %(argv_name, random.randint(1, 1000), random.randint(1, 1000)),
        '\treturn %s\n' %(argv_name),
        'end\n'
    ]
    return string.join(text)

#获取png内容
def getPngText():
    text = str(random.randint(1, 100)) * random.randint(1024, 10240)
    text = text + "0000000049454e44ae426082".decode('hex')
    return text

#添加单个文件
def addSingleFile(file_path):
    global target_path
    print "add file " + file_path.replace(target_path, "")
    _, file_type = os.path.splitext(file_path)
    if file_type == ".lua":
        with open(file_path, "w") as fileObj:
            func_num = random.randint(2, 5)
            for j in range(0, func_num):
                func_text = getLuaFuncText()
                fileObj.write(func_text)
            fileObj.close()
    elif file_type == ".png":
        with open(file_path, "wb") as fileObj:
            fileObj.write(getPngText())
            fileObj.close()
    
def addFileTo(parent_folder, level, min_file_num = 0):
    global match_rule, target_path
    create_folder_list = []
    for parent, folders, files in os.walk(parent_folder):
        target_file_type = ""
        relative_path = parent.replace(target_path, "")
        for file_type, match_config in match_rule.items():
            if match_config.has_key("path_exclude") and relative_path.find(match_config["path_exclude"]) != -1:
                continue
            if not match_config.has_key("path_include") or relative_path.find(match_config["path_include"]) != -1:
                target_file_type = file_type
                break
        if target_file_type == "":
            continue

        #创建文件数量
        new_file_num = random.randint(len(files) / 2, len(files)) + min_file_num
        for i in range(0, new_file_num):
            file_path = os.path.join(parent, getOneName() + target_file_type)
            addSingleFile(file_path)

        #防止创建太多层的文件夹
        if level > 2:
            continue
        #创建文件夹数量
        new_fold_num = random.randint(len(folders) / 2, len(folders))
        for i in range(0, new_fold_num):
            target_folder = os.path.join(parent, getOneName())
            #为了不阻断os.walk,延后创建文件夹
            create_folder_list.append(target_folder)

    for folder_path in create_folder_list:
        try:
            print "create folder " + folder_path.replace(target_path, "")
            os.mkdir(folder_path)
            addFileTo(folder_path, level + 1, random.randint(2, 5))
        except Exception as e:
            print e
#----------------------------------------ended add file----------------------
def changeSingleFileMD5(file_path):
    _, file_type = os.path.splitext(file_path)
    with open(file_path, "ab") as fileObj:
        if file_type == ".png":
            text = "".join(random.sample(string.ascii_letters, 11))
        elif file_type == ".jpg":
            text = "".join(random.sample(string.ascii_letters, 20))
        elif file_type == ".lua":
            text = "\n--#*" + "".join(random.sample(string.ascii_letters, 10)) + "*#--"
        else:
            text = " "*random.randint(1, 100)
        fileObj.write(text)
        fileObj.close()

#改变文件md5
def changeFolderMD5(target_path):
    type_filter = set([".png", ".jpg", ".lua", ".json", ".plist", ".fnt"])
    for parent, folders, files in os.walk(target_path):
        for file in files:
            full_path = os.path.join(parent, file)
            _, file_type = os.path.splitext(full_path)
            if file_type in type_filter:
                changeSingleFileMD5(full_path)

#----------------------------------------------------main------------------------------------------------
        
def parse_args():
    global res_path
    parser = argparse.ArgumentParser(description='资源变异工具')
    parser.add_argument('--res', dest='res_dir', type=str, required=True, help='资源目录')
    parser.add_argument('--target', dest='target_dir', type=str, required=False, default=target_path, help='资源导出目录')

    args = parser.parse_args()
    return args

def main():
    global resource_path, target_path
    app_args = parse_args()
    resource_path = app_args.res_dir
    target_path = app_args.target_dir

    if not os.path.exists(resource_path):
        print "res path not exists: " + resource_path
        exit(0)
    if target_path != resource_path:
        if os.path.exists(target_path):
            shutil.rmtree(target_path)
        shutil.copytree(resource_path, target_path)
    
    addFileTo(target_path, 0)
    print "\n\nstart modify file md5"
    changeFolderMD5(target_path)
    print "finish!"

if __name__ == "__main__":
    main()