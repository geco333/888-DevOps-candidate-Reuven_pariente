# immediatley exit if error occur.
set -e

cert="/etc/ssl/certs/hello.crt"
key="/etc/ssl/hello.key"

# disable SELinux.
sudo setenforce 0

# update yum.
echo -e "\e[32mUpdating yum...\e[0m"
sudo yum -y update && echo -e "\e[32mDone.\e[0m "

# install apache.
echo -e "\e[32mInstalling apache server (httpd)...\e[0m"
sudo yum -y install httpd && echo -e "\e[32mDone.\e[0m "

# install openssl apache mod.
echo -e "\e[32mInstalling openssl apache mod...\e[0m"
sudo yum -y install mod_ssl && echo -e "\e[32mDone.\e[0m "

# install bind dns server.
echo -e "\e[32mInstalling bind dns server...\e[0m"
sudo yum -y bind bind-utils && echo -e "\e[32mDone.\e[0m "

# updating resolve.conf to use localhost as dns server.
echo -e "\e[32mUpdating local dns resolve file...\e[0m"
sudo cp resolve.conf /etc && echo -e "\e[32mDone.\e[0m "

# move index.html to apache document root folder.
echo -e "\e[32mCopying index.html to default apache document root folder...\e[0m"
sudo cp index.html /var/www/html && echo -e "\e[32mDone.\e[0m "

# generate a certificate and a private key.
echo -e "\e[32mGenerating certificate and key files...\e[0m"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $key -out $cert -subj "/C=--/ST=--/L=-/O=-/OU=-/CN=-" && echo -e "\e[32mDone.\e[0m "

# copy hello.conf to apache custom configurations folder.
echo -e "\e[32mCopying virtual host file to apache server configuration folder...\e[0m"
sudo cp hello.conf /etc/httpd/conf.d/ && echo -e "\e[32mDone.\e[0m "

# start named dns service.
echo -e "\e[32mStarting dns server...\e[0m"
sudo systemctl start named && echo -e "\e[32mDone.\e[0m "

# start apache server.
echo -e "\e[32mStarting apache server...\e[0m"
sudo systemctl start httpd && echo -e "\e[32mDone.\e[0m "

# test server response on port 80.
echo -e "\e[32mTesting index.html response on port 80...\e[0m"
if [ $(curl -o /dev/null --silent --write-out '%{http_code}\n' localhost:80) = 200 ]
	then
		echo -e "curl test \e[32mOK.\e[0m"
	else
		echo -e "curl test \e[31mFAIL.\e[0m"
fi

# test server response on port 443.
echo -e "\e[32mTesting index.html response on port 443...\e[0m"
if [ $(curl -k -o /dev/null --silent --write-out '%{http_code}\n' https://localhost:443) = 200 ]
	then
		echo -e "curl test \e[32mOK.\e[0m"	
	else
		echo -e "curl test \e[31mFAIL.\e[0m"
fi

# test server response as hello.as on port 80.
echo -e "\e[32mTesting hello.as response on port 80...\e[0m"
if [ $(curl -k -o /dev/null --silent --write-out '%{http_code}\n' http://hello.as:80) = 200 ]
	then
		echo -e "curl test \e[32mOK.\e[0m"
	else
		echo -e "curl test \e[31mFAIL.\e[0m"
fi

# test server response as hello.as on port 443.
echo -e "Testing hello.as response on port 443..."
if [ $(curl -k -o /dev/null --silent --write-out '%{http_code}\n' https://hello.as:443) = 200 ]
	then
		echo -e "curl test \e[32mOK.\e[0m"
	else
		echo -e "curl test \e[31mFAIL.\e[0m"
fi

# enable SELinux
sudo setenforce 1
