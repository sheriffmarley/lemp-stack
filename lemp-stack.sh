
# Install mandatory files
apt install curl nano


# Install nginx from nginx repo
sudo apt install curl gnupg2 ca-certificates lsb-release


echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    
    echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    
    curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
    
    sudo apt-key fingerprint ABF5BD827BD9BF62
     
    sudo apt update
    
    sudo apt install nginx
