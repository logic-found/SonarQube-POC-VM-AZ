# This script is used for setting up Docker, SonarQube on VM

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo systemctl start docker
sudo systemctl enable docker
sudo docker pull sonarqube:lts
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts