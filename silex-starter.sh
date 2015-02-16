#!/bin/sh

echo "Checking composer";

# $1 destinazione
# $2 server name

composer >/dev/null 2>&1 || {
	echo >&2 "Composer is not installed, im gonna get it.";
	curl -sS https://getcomposer.org/installer | php
	echo >&2 "Moving to /usr/local/bin";
	sudo mv composer.phar /usr/local/bin/composer || echo >&2 "Composer installed"
}
sudo composer self-update

echo "Creating destination directory (if needed)";

mkdir -p $1 || { echo >&2 "cannot create destination directory"; }

echo "Creating web directory";
mkdir -p $1/web

index=$1/web/index.php
cp silexboot $index

echo "Creating src directory";
mkdir -p $1/src

current=`pwd`
cd $1

echo "Installing silex through composer..."
composer require silex/silex

read -p "Do you wish to install Twig Service Provider? [YyNn] " yn
case $yn in
    [Yy]* )
		echo "Installing twig through composer..."
		composer require twig/twig;
		cat <<EOT >> $index
\$app->register(new Silex\\Provider\\TwigServiceProvider(), array(
    'twig.path' => __DIR__.'/views',
));

EOT
break;;
	[Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
esac

read -p "Do you wish to install Twig Bridge? [YyNn] " yn
case $yn in
    [Yy]* )
		echo "Installing twig bridge through composer..."
		composer require symfony/twig-bridge; break;;
	[Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
esac

read -p "Do you wish to install Validator Service Provider? [YyNn] " yn
case $yn in
    [Yy]* )
		echo "Installing validator through composer..."
		composer require symfony/validator;
		cat <<EOT >> $index
\$app->register(new Silex\\Provider\\ValidatorServiceProvider());

EOT
break;;
	[Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
esac

read -p "Do you wish to install Form Service Provider? [YyNn] " yn
case $yn in
    [Yy]* )
		echo "Installing form through composer..."
		composer require symfony/form;
		cat <<EOT >> $index
\$app->register(new Silex\\Provider\\FormServiceProvider());

EOT
break;;
	[Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
esac

read -p "Do you wish to install Security Service Provider? [YyNn] " yn
case $yn in
    [Yy]* )
		echo "Installing security through composer..."
		composer require symfony/security;
		cat <<EOT >> $index
\$app->register(new Silex\\Provider\\SecurityServiceProvider(), array(
    'security.firewalls' => // SEE http://silex.sensiolabs.org/doc/providers/security.html
));

EOT
break;;
	[Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
esac

read -p "Do you wish to install Doctrine Service Provider? [YyNn] " yn
case $yn in
    [Yy]* )
		echo "Installing doctrine dbal through composer..."
		composer require "doctrine/dbal:~2.2";
		cat <<EOT >> $index
\$app->register(new Silex\\Provider\\DoctrineServiceProvider(), array(
    'db.options' => // SEE http://silex.sensiolabs.org/doc/providers/doctrine.html
));

EOT
break;;
	[Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
esac

cat <<EOT >> $index

\$app->run();
EOT

cd $current

echo "Preparing .htaccess"
cp apache_htaccess $1/web/.htaccess

echo "Preparing virtual host";
mkdir -p $1/log

sudo cp vh "/etc/apache2/sites-available/$2.conf"
sudo sed -i "s@DOCROOT@$1/web@" "/etc/apache2/sites-available/$2.conf"
sudo sed -i "s@BASE@$1@" "/etc/apache2/sites-available/$2.conf"
sudo sed -i "s@SERVERNAME@$2@" "/etc/apache2/sites-available/$2.conf"

echo "Enabling virtual host"
sudo a2ensite $2.conf

sudo service apache2 restart

echo "Do not forget to add $2 to your /etc/hosts file";




