#!/bin/sh

#清除assetbundle缓存

echo "开始AssetBundle清除缓存"
echo "==========="
rm -rf ./MergeTown/Res
echo "Res已删除"
rm -rf ./MergeTown/Assets/AssetGraph/UnityEngine.AssetGraph/Cache/AssetBundles
echo "AssetGraph/UnityEngine.AssetGraph/Cache/AssetBundles已删除"
rm -rf ./MergeTown/Assets/StreamingAssets/assets
echo "MergeTown/Assets/StreamingAssets/assets已删除"
rm -rf ./MergeTown/Assets/StreamingAssets/build_info
echo "MergeTown/Assets/StreamingAssets/build_info"
echo "清除缓存完成"
