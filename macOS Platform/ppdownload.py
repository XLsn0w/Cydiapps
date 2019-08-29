#By:iblue http://iosre.com/u/iblue/summary 所下载的文件仅供逆向工程研究使用。
import urllib.request
import urllib.parse
import re
import ssl
import base64
import os

#关闭SSL验证
user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
headers = { 'User-Agent' : user_agent }
ssl._create_default_https_context = ssl._create_unverified_context
print("Close certificate verify...")

def getSearchResult():
    keyword = input("Input the search key word: ")

    #将中文转换成url编码
    keyword = urllib.parse.quote(keyword)

    searchUrl = "https://www.25pp.com/ios/search_app_0/" + keyword + "/"
    content = getHtmlStringByUrl(searchUrl)
    detailUrl = getSearchDetailUrl(content)
    content = getHtmlStringByUrl(detailUrl)
    downUrl = getAppdownUrlByHtmlContent(content)
    return downUrl


# 根据url 获取网页内容
def getHtmlStringByUrl(url):
    try:
        request = urllib.request.Request(url, headers=headers)
        response = urllib.request.urlopen(request)
        content = response.read().decode('utf-8')  # gbk
        return content

    except urllib.request.URLError as e:
        if hasattr(e, "code"):
            print(e.code)
        if hasattr(e, "reason"):
            print(e.reason)

    return ""

# 根据网页内容获取详情链接
def getSearchDetailUrl(content):
    pattern = re.compile('href="https://www.25pp.com/ios/detail_.*?"', re.S) #href = "https://www.25pp.com/ios/detail_3491226/"
    items = re.findall(pattern, content)
    for item in items:
        #print(item)
        values = item.split('"')
        result = values[1]
        print("Detail url: " + result)
        return result

    return ""

# 根据网页内容获取ipa的下载链接
def getAppdownUrlByHtmlContent(content):
    pattern = re.compile('appdownurl=".*?"', re.S)  # appdownurl="aHR0cDovL3IxMS4yNXBwLmNvbS9zb2Z0LzIwMTgvMDEvMDkvMjAxODAxMDlfNjI0NThfMjE1MDYwOTY4Nzc4LmlwYQ=="
    items = re.findall(pattern, content)
    for item in items:
        values = item.split('"')
        result = values[1]
        print("Orgin download url: " + result)

        # Base64Decode
        output = base64.standard_b64decode(result)
        output = output.__str__()
        return output

    return ""


downUrl = getSearchResult()
print("Down url: " + downUrl)

os.system('wget'+downUrl)