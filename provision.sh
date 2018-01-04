#!/bin/bash
set -e

NEXTCLOUD_URL="https://download.nextcloud.com/server/releases/latest.tar.bz2"
EFS_MOUNT_POINT=/mnt/efs

# Run updates
yum -y update

# Install dependencies
yum install -y httpd71 \
               php71 \
               php71-gd \
               php71-mbstring \
               php71-mysqlnd \
               php71-intl \
               php71-mcrypt \
               php71-opcache \
               php71-apcu

# Install nextcloud
wget "${NEXTCLOUD_URL}" -O /nextcloud.tar.bz2
tar -h -x -f /nextcloud.tar.bz2 -C /var/www/html/
rm -f /nextcloud.tar.bz2
rsync -av /tmp/configs/nextcloud/ /var/www/html/nextcloud/
ln -s "${EFS_MOUNT_POINT}"/nextcloud/apps2 /var/www/html/nextcloud/apps2

# Set Permissions
chown -R apache:apache /var/www/html/nextcloud

# Enable services (should happen last)
chkconfig httpd on

# Copy configs
chown -R root:root /tmp/configs
find /tmp/configs -type f -exec chmod 644 {} \+
find /tmp/configs -type d -exec chmod 755 {} \+
rsync -av /tmp/configs/etc/ /etc/

# Cleaning up
rm -rf /tmp/configs
