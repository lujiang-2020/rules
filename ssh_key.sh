#!/bin/bash

# 检查是否以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本必须以root权限运行" 1>&2
   exit 1
fi

# 设置变量
SSH_DIR="/root/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"
SSH_CONFIG="/etc/ssh/sshd_config"

# 创建.ssh目录(如果不存在)
mkdir -p $SSH_DIR
chmod 700 $SSH_DIR

# 生成新的SSH密钥对
ssh-keygen -t rsa -b 4096 -f "$SSH_DIR/id_rsa" -N ""

# 将公钥添加到authorized_keys
cat "$SSH_DIR/id_rsa.pub" >> $AUTH_KEYS
chmod 600 $AUTH_KEYS

# 修改SSH配置
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' $SSH_CONFIG
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG

# 重启SSH服务
systemctl restart sshd

echo "SSH密钥登录设置完成。请保存以下私钥:"
cat "$SSH_DIR/id_rsa"
echo "请确保您已经保存了私钥,然后按Enter键继续..."
read

# 删除私钥文件
rm "$SSH_DIR/id_rsa"

echo "私钥已从服务器删除。请使用保存的私钥进行future登录。"
