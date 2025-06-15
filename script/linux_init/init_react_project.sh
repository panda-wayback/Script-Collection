#!/bin/bash

# 定义函数，接受文件夹名称作为参数
setup_strapi_project() {
    folder_name=$1
    
    # 检查文件夹是否存在
    if [ -d "$folder_name" ]; then
        echo "进入 $folder_name 项目目录"
        
        # 保存当前工作目录并进入目标文件夹
        pushd "$folder_name" > /dev/null || exit
        
        # 删除 node_modules 和 yarn.lock
        # echo "清理 node_modules 和 yarn.lock..."
        # rm -rf node_modules
        # rm -f yarn.lock

        # # 清理 yarn 缓存
        # echo "清理 yarn 缓存..."
        # yarn cache clean

        # 安装依赖
        echo "安装依赖..."
        yarn install

        # 构建项目
        echo "构建项目..."
        # yarn build

        # 启动 pm2
        echo "启动 pm2..."
        pm2 startup

        echo "$folder_name 项目设置完成！"

        # 返回到初始目录
        popd > /dev/null
    else
        echo "文件夹 $folder_name 不存在，请检查路径。"
    fi
}

# 调用函数并传入文件夹名称作为参数
setup_strapi_project "strapi"
setup_strapi_project "ant-website"
