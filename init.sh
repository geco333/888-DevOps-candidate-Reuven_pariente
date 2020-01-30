cert="/etc/ssl/certs/hello.crt"
key="/etc/ssl/hello.key"

# disable SELinux.
sudo setenforce 0

# update yum.
echo "Updating yum..."
sudo yum -y update

# install apache.
echo "Installing apache server (httpd)..."
sudo yum -y install httpd

# install openssl apache mod.
sudo yum -y install mod_ssl

# install bind dns server.
sudo yum -y bind bind-utils

# install wireshark.
sudo yum -y install wireshark

# move index.html to apache document root folder.
echo "Moving index.html to default apache document root folder..."
sudo cp index.html /var/www/html

# generate a certificate and a private key.
echo "Generating certificate and key files..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $key -out $cert -subj "/C=--/ST=--/L=-/O=-/OU=-/CN=-"

# copy hello.conf to apache custom configurations folder.
echo "Moving virtual host file to apache server configuration folder..."
sudo cp hello.conf /etc/httpd/conf.d/

# start named dns service.
echo "Starting dns server..."
sudo systemctl start named

# start apache server.
echo "Starting apache server..."
sudo systemctl start httpd

# test server response on port 80.
echo "Testing index.html response on port 80..."
if [ $(curl -o /dev/null --silent --write-out '%{http_code}\n' localhost:80) = 200 ]
	then
		echo "curl test OK."
	else
		echo "curl test FAIL."
fi

# test server response on port 443.
echo "Testing index.html response on port 443..."
if [ $(curl -k -o /dev/null --silent --write-out '%{http_code}\n' https://localhost:443) = 200 ]
	then
		echo "curl test OK."
	else
		echo "curl test FAIL."
fi

# test server response as hello.as on port 80.
echo "Testing hello.as response on port 80..."
if [ $(curl -k -o /dev/null --silent --write-out '%{http_code}\n' http://hello.as:80) = 200 ]
	then
		echo "curl test OK."
	else
		echo "curl test FAIL."
fi

# test server response as hello.as on port 443.
echo "Testing hello.as response on port 443..."
if [ $(curl -k -o /dev/null --silent --write-out '%{http_code}\n' https://hello.as:443) = 200 ]
	then
		echo "curl test OK."
	else
		echo "curl test FAIL."
fi

# enable SELinux
sudo setenforce 1
