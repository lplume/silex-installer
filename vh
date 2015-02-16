<VirtualHost *:80>
  DocumentRoot DOCROOT
  ServerName SERVERNAME
  CustomLog BASE/log/access.log combined
  ErrorLog BASE/log/error.log
  <Directory "DOCROOT">
    AllowOverride All
  </Directory>
</VirtualHost>