# -*- coding: utf-8 -*
import argparse
import re
import requests
import os
import shutil
import json
from shutil import copyfile
from ftplib import FTP


# ------------CONST DEFINE--------------
# App Bundle信息服务器地址
FILE_SERVER_URL = 'http://10.0.42.7:81/mergical/'
# 临时目录地址
TMP_DIR = './MergeTown/hotfix'
# 本地bundle信息配置文件
LOCAL_BUNDLE_INFO_FILE_PATH = "./MergeTown/Assets/StreamingAssets/assets/versions.csv"
LOCAL_BUNDLE_DIR = "./MergeTown/Res/bundles_md5"
FTP_HOST = "10.0.42.7"
FTP_ANDROID_PORT = 21
FTP_IOS_PORT = 25
PLATFORM_ANDROID = 'android'
PLATFORM_IOS = 'ios'
DIFF_FILE_NAME = 'diff.txt'

parser = argparse.ArgumentParser("Gen hotfix patch file")
parser.add_argument("target_version", help="target hotfix version", type=str)
parser.add_argument("platform", help="platform(android/ios)", type=str)
args = parser.parse_args()

target_version_dir = "%s/%s/%s" % (TMP_DIR, args.target_version, args.platform)


class Version:
    """版本信息"""
    x = 0
    y = 0
    z = 0
    w = 0

    def compare(self, target):
        return self.x == target.x and self.y == target.y and self.z == target.z

    def get_major_version(self):
        return '{}.{}.{}'.format(self.x, self.y, self.z)

    def __str__(self):
        return '{}.{}.{}.{}'.format(self.x, self.y, self.z, self.w)


# 解析版本
# 支持a.b.c.d a.b.c两种格式
def parse_version(txt):
    if re.match("\d+\.\d+\.\d+(\.\d+)?$", txt) is None:
        raise Exception("version formation error,version text:", txt)
    version_arr = str.split(txt, '.')
    if len(version_arr) < 3 or len(version_arr) > 4:
        raise Exception("version formation error,version text:", txt)
    version = Version()
    version.x = version_arr[0]
    version.y = version_arr[1]
    version.z = version_arr[2]
    if len(version_arr) == 4:
        version.w = version_arr[3]
    return version


# 解析version.csv
def parse_bunlde_info_config(content):
    content = str.replace(content, '\r', '')
    lines = content.split('\n')
    info = {}
    for line in lines:
        arr = str.split(line, ',')
        if len(arr) < 2:
            continue
        k = arr[0]
        v = arr[1]
        info[k] = v
    return info


# 根据版本号从服务器获取当前App资源信息
# 获取的是当前app包中的bundle信息
def get_app_bundles_info(version):
    url = "{url}{platform}/assetbundle/{version}/versions.csv".format(url=FILE_SERVER_URL, version=version.get_major_version(),
                                                                      platform=args.platform)
    print("[GET_SERVER_BUNDLES_INFO]get app info form: %s" % url)
    r = requests.get(url)
    if r.status_code != 200:
        raise Exception("[GET_SERVER_BUNDLES_INFO]request fail code: %s" % r.status_code)

    return parse_bunlde_info_config(r.text)


# 获取本地bundle信息
def get_local_version_info():
    if not os.path.isfile(LOCAL_BUNDLE_INFO_FILE_PATH):
        raise Exception("local bundle info file not found!")
    fo = open(LOCAL_BUNDLE_INFO_FILE_PATH, 'r+')
    content = fo.read()
    fo.close()
    return parse_bunlde_info_config(content)


# 对比bundle差异
def diff_bundles_info(major, minor):
    diff = {}
    for k , v in major.items():
        if k not in minor or major[k] != minor[k] or k.lower() == PLATFORM_ANDROID or k.lower() == PLATFORM_IOS:
            diff[k] = v
    return diff


# 生成热更版本配置文件
def gen_hotfix_config(version):
    config = {
        "version": str(version),
        "lua": "",
        "xmlandroid": "",
        "xmlios": "",
        "xmlpc": "",
        "xmlmac": ""
    }
    platform = args.platform
    if platform == 'android':
        config['xmlandroid'] = '{}.csv'.format(PLATFORM_ANDROID + str(version))
    elif platform == 'ios':
        config['xmlios'] = '{}.csv'.format(PLATFORM_IOS + str(version))
    else:
        raise Exception("gen hotfix config fail,platform:{} not support.".format(platform))
    fo = open("{}/{}.txt".format(target_version_dir, platform + str(version)), 'w')
    json.dump(config, fo, indent=4)
    fo.flush()
    fo.close()


# 复制需要更新bundle文件到临时目录
def copy_diff_bundles(files, version):
    fo = open("{}/{}".format(target_version_dir,DIFF_FILE_NAME), 'w')
    for k, v in files.items():
        print("[COPY BUNDLE]{}.unity3d".format(v))
        path = "{}/{}.unity3d".format(LOCAL_BUNDLE_DIR, v)
        if not os.path.isfile(path):
            raise Exception("can not find bundle:{}.unity3d in {}".format(v, LOCAL_BUNDLE_DIR))
        copyfile(path, "{}/{}.unity3d".format(target_version_dir, v))
        fo.write(k + '\n')
    
    copyfile(LOCAL_BUNDLE_INFO_FILE_PATH, "{}/{}/{}/{}.csv".format(TMP_DIR, str(version), args.platform, args.platform + str(version)))
    fo.flush()
    fo.close()


# 上传热更文件到服务器
def upload_hotfix_file_to_local_server(version):
    ftp = FTP()
    port = FTP_ANDROID_PORT if args.platform == PLATFORM_ANDROID else FTP_IOS_PORT
    ftp.connect(FTP_HOST, port=port)
    ftp.login()
    ftp.cwd("/assetbundle")
    ver_str = str(version)
    if ver_str in ftp.nlst():  # 版本目录已存在，删除目录内所有文件
        ftp.cwd(ver_str)
        names = ftp.nlst()
        for n in names:
            ftp.delete(n)
    else:
        ftp.mkd(ver_str)
        ftp.cwd(ver_str)
    files = os.listdir(target_version_dir)
    total_num = len(files)
    current = 0
    for f in files:
        with open(os.path.join(target_version_dir, f), 'rb') as fo:
            current = current + 1
            print('[上传本地服务器(%d/%d)]%s' % (current, total_num, f))
            ftp.storbinary("STOR %s" % f, fo)
    ftp.quit()


# 生成热更版本
def gen_hotfix_version(target_version):
    print("[STEP 1] 开始生成热更文件.")
    if target_version.w == 0:
        raise Exception("目标版本号错误.")
    if args.platform != PLATFORM_ANDROID and args.platform != PLATFORM_IOS:
        raise Exception("不支持的平台:%s" % args.platform)
    if os.path.isdir(TMP_DIR):
        shutil.rmtree(TMP_DIR, ignore_errors=True)
    # 根据版本号创建目录
    os.makedirs(target_version_dir)
    print("[STEP 2] 获取服务器Bundle信息.")
    server_bundles_info = get_app_bundles_info(target_version)
    print("[STEP 3] 获取本地Bundle信息.")
    local_bundles_info = get_local_version_info()
    print("[STEP 4] 对比Bundle差异.")
    diff_bundles = diff_bundles_info(local_bundles_info, server_bundles_info)
    print("[STEP 5] 复制差异Bundle到临时目录.")
    copy_diff_bundles(diff_bundles, target_version)
    print("[STEP 6] 生成热更配置")
    gen_hotfix_config(target_version)
    print("[STEP 7] 上传文件至本地服务器.")
    upload_hotfix_file_to_local_server(target_version)
    print("[STEP 8]热更生成结束!!!")


if __name__ == '__main__':
    print("目标热更版本号:", args.target_version)
    v = parse_version(args.target_version)
    gen_hotfix_version(v)

