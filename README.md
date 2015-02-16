destination as first parameter
servername as second parameter

this work with apache2 server, will ask your sudo password

this script:
* install/update composer (moving to /usr/local/bin)
* install silex
* prompt to install various Service provider (atm the services that I care)
* prepare a basic index.php registering the providers
* create .htaccess
* create and a2ensite
