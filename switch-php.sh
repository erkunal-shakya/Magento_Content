#!/bin/bash
# Usage: sudo ./switch-php.sh 8.2 or sudo ./switch-php.sh 8.4

PHP_VERSION=$1

if [ -z "$PHP_VERSION" ]; then
  echo "❌ Please provide a PHP version (example: 8.2 or 8.4)"
  exit 1
fi

echo "🔄 Switching to PHP $PHP_VERSION ..."

# Check if PHP version exists
if [ ! -f "/usr/bin/php$PHP_VERSION" ]; then
  echo "❌ PHP $PHP_VERSION is not installed on this system!"
  exit 1
fi

# Update PHP CLI version
sudo update-alternatives --set php /usr/bin/php$PHP_VERSION

# Disable all other PHP Apache modules
for ver in $(ls /etc/apache2/mods-enabled/ | grep -oP 'php\d+\.\d+' | sort -u); do
  if [ "$ver" != "php$PHP_VERSION" ]; then
    echo "🚫 Disabling $ver ..."
    sudo a2dismod $ver >/dev/null 2>&1
  fi
done

# Enable the selected PHP version for Apache
echo "✅ Enabling php$PHP_VERSION ..."
sudo a2enmod php$PHP_VERSION

# Restart Apache
echo "🔁 Restarting Apache..."
sudo systemctl restart apache2

# Display confirmation
echo "🎉 Switched successfully!"
php -v | head -n 1
