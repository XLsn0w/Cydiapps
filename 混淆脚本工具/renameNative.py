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

import sys 
reload(sys) 
sys.setdefaultencoding("utf-8")

script_path = os.path.split(os.path.realpath(sys.argv[0]))[0]
add_prefix = ""
old_prefix = "xxx"
new_prefix = "zzz"
ios_src_path = ""
project_file_path = ""

ignore_path_text = [".a", ".png", ".plist", ".storyboard", ".pch"]

#首字母大写
def isNeedIgnore(file_path):
    global ignore_path_text
    for ignore_text in ignore_path_text:
        if file_path.find(ignore_text) != -1:
            return True
    return False

def replaceStringInFile(full_path, old_text, new_text):
    with open(full_path, "r") as fileObj:
        all_text = fileObj.read()
        fileObj.close()

    all_text = all_text.replace(old_text, new_text)
    with open(full_path, "w") as fileObj:
        fileObj.write(all_text)
        fileObj.close()

def renameFileInXcodeProj(old_file_name, new_file_name):
    global project_file_path
    if os.path.exists(project_file_path):
        replaceStringInFile(project_file_path, old_file_name, new_file_name)

def renameInAllFile(old_text, new_text):
    global ios_src_path
    for parent, folders, files in os.walk(ios_src_path):
        for file in files:
            full_path = os.path.join(parent, file)
            replaceStringInFile(full_path, old_text, new_text)

def dealWithIos():
    print "开始重命名类名"
    global old_prefix, new_prefix, ios_src_path
    for parent, folders, files in os.walk(ios_src_path):
        for file in files:
            old_full_path = os.path.join(parent, file)
            if file.startswith(old_prefix) and not isNeedIgnore(old_full_path):
                new_file_name = file.replace(old_prefix, new_prefix)
                print "\t重命名文件: %s -> %s" %(file, new_file_name)

                new_full_path = os.path.join(parent, new_file_name)
                os.rename(old_full_path, new_full_path)
                #在项目工程中改名
                renameFileInXcodeProj(file, new_file_name)

                #在可能引用的地方替换
                old_file_base_name = os.path.splitext(file)[0]
                new_file_base_name = old_file_base_name.replace(old_prefix, new_prefix)
                renameInAllFile(old_file_base_name, new_file_base_name)

    for parent, folders, files in os.walk(ios_src_path):
        for folder in folders:
            old_full_path = os.path.join(parent, folder)
            if folder.startswith(old_prefix) and not isNeedIgnore(old_full_path):
                new_folder_name = folder.replace(old_prefix, new_prefix)
                print "\t重命名文件夹: %s -> %s" %(folder, new_folder_name)
                new_full_path = os.path.join(parent, new_folder_name)
                os.rename(old_full_path, new_full_path)
                #在项目工程中改名
                renameFileInXcodeProj(folder, new_folder_name)
    print "finish\n"

def addPreFix():
    print "开始添加前缀"
    global add_prefix, ios_src_path
    for parent, folders, files in os.walk(ios_src_path):
        for file in files:
            old_full_path = os.path.join(parent, file)
            if not isNeedIgnore(old_full_path):
                new_file_name = add_prefix + file
                print "\t重命名文件: %s -> %s" %(file, new_file_name)

                new_full_path = os.path.join(parent, new_file_name)
                os.rename(old_full_path, new_full_path)
                #在项目工程中改名
                renameFileInXcodeProj(file, new_file_name)

                #在可能引用的地方替换
                old_file_base_name = os.path.splitext(file)[0]
                new_file_base_name = os.path.splitext(new_file_name)[0]
                renameInAllFile(old_file_base_name, new_file_base_name)
                renameInAllFile(add_prefix+add_prefix, add_prefix)

    for parent, folders, files in os.walk(ios_src_path):
        for folder in folders:
            old_full_path = os.path.join(parent, folder)
            if not isNeedIgnore(old_full_path):
                new_folder_name = add_prefix + folder
                print "\t重命名文件夹: %s -> %s" %(folder, new_folder_name)
                new_full_path = os.path.join(parent, new_folder_name)
                os.rename(old_full_path, new_full_path)
                #在项目工程中改名
                renameFileInXcodeProj(folder, new_folder_name)
    print "finish\n"


#----------------------------------------------------main------------------------------------------------        
def parse_args():
    global script_path, proj_ios_path
    parser = argparse.ArgumentParser(description='修改类名前缀工具.\n')
    parser.add_argument('--add_prefix', dest='add_prefix', type=str, required=False, default="", help='添加类名前缀')
    parser.add_argument('--old_prefix', dest='old_prefix', type=str, required=False, help='原类名前缀')
    parser.add_argument('--new_prefix', dest='new_prefix', type=str, required=False, help='替换后类名前缀')
    parser.add_argument('--ios_path', dest='ios_path', type=str, required=True, help='OC文件目录')
    parser.add_argument('--proj_path', dest='proj_path', type=str, required=False, default="", help='xx.xcodeproj路径')
    args = parser.parse_args()
    return args

def main():
    global old_prefix, new_prefix, ios_src_path, project_file_path, add_prefix
    app_args = parse_args()

    add_prefix = app_args.add_prefix
    old_prefix = app_args.old_prefix
    new_prefix = app_args.new_prefix
    ios_src_path = app_args.ios_path
    project_file_path = os.path.join(app_args.proj_path, "project.pbxproj")
    if not os.path.exists(ios_src_path):
        print "ios_path not exists: " +  ios_src_path
        exit(0)
    if not os.path.exists(project_file_path):
        print "proj_path not exists: " +  project_file_path

    print "请提前备份文件夹或确认在版本管理软件中"
    raw_input("回车继续执行")
    if add_prefix and add_prefix != "":
        addPreFix()
        exit(0)
    dealWithIos()
 

if __name__ == "__main__":
    main()
