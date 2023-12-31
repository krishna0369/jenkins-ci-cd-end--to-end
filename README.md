# Project Setup using below tools
1) Maven
2) Git Hub
3) Jenkins
4) sonarqube
5) nexus
6) Docker
7) Kubernetes

# Step-1 : Jenkins Server Setup in Linux VM #

1) Create Ubuntu VM using AWS EC2 (t2.medium) <br/>
2) Enable 8080 Port Number in Security Group Inbound Rules
3) Connect to VM using MobaXterm
4) Instal Java

```
sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
```

3) Install Jenkins
```
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```
4) Start Jenkins

```
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

5) Verify Jenkins

```
sudo systemctl status jenkins
```
	
6) Open jenkins server in browser using VM public ip

```
http://public-ip:8080/
```

7) Copy jenkins admin pwd
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
	   
8) Create Admin Account & Install Required Plugins in Jenkins


## Step-2 : Configure Maven as Global Tool in Jenkins ##
1) Manage Jenkins -> Tools -> Maven Installation -> Add maven <br/>

## Step-3 : Setup Docker in Jenkins ##
```
curl -fsSL get.docker.com | /bin/bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
sudo docker version
```

# Step - 4 : Create EKS Management Host in AWS #

1) Launch new Ubuntu VM using AWS Ec2 ( t2.micro )	  
2) Connect to machine and install kubectl using below commands  
```
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl <br/>
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client
```
3) Install AWS CLI latest version using below commands 
```
sudo apt install unzip 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

4) Install eksctl using below commands
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version <br/>
```

# Step - 5 : Create IAM role & attach to EKS Management Host & Jenkins Server #

1) Create New Role using IAM service ( Select Usecase - ec2 ) 	
2) Add below permissions for the role <br/>
	- IAM - fullaccess <br/>
	- VPC - fullaccess <br/>
	- EC2 - fullaccess  <br/>
	- CloudFomration - fullaccess  <br/>
	- Administrator - acces <br/>
		
3) Enter Role Name (eksroleec2) 
4) Attach created role to EKS Management Host (Select EC2 => Click on Security => Modify IAM Role => attach IAM role we have created) 
5) Attach created role to Jenkins Machine (Select EC2 => Click on Security => Modify IAM Role => attach IAM role we have created) 
  
# Step - 6 : Create EKS Cluster using eksctl # 
**Syntax:** 

eksctl create cluster --name cluster-name  \
--region region-name \
--node-type instance-type \
--nodes-min 2 \
--nodes-max 2 \ 
--zones <AZ-1>,<AZ-2>

```
eksctl create cluster --name ashokit-cluster --region ap-south-1 --node-type t2.medium  --zones ap-south-1a,ap-south-1b**
```

Note: Cluster creation will take 5 to 10 mins of time (we have to wait). After cluster created we can check nodes using below command.	
```
kubectl get nodes  
```
# Step - 7 : Install AWS CLI in JENKINS Server #

URL : https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  

**Execute below commands to install AWS CLI**
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```
 
# Step - 8 : Install Kubectl in JENKINS Server #
**Execute below commands in Jenkins server to install kubectl**

```
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
udo mv ./kubectl /usr/local/bin
kubectl version --short --client
```

# Step - 9 : Update EKS Cluster Config File in Jenkins Server #
	
1) Execute below command in Eks Management host & copy kube config file data <br/>
	$ cat .kube/config 

2) Execute below commands in Jenkins Server and paste kube config file  <br/>
	$ cd /var/lib/jenkins <br/>
	$ sudo mkdir .kube  <br/>
	$ sudo vi .kube/config  <br/>

3) Execute below commands in Jenkins Server and paste kube config file for ubuntu user to check EKS Cluster info<br/>
	$ cd ~ <br/>
	$ ls -la  <br/>
	$ sudo vi .kube/config  <br/>

4) check eks nodes <br/>
	$ kubectl get nodes 

**Note: We should be able to see EKS cluster nodes here.**
## Step-10 : Setup sonarqube using docker

1) Login into AWS Cloud account
2) Launch Linux VM using EC2 service   
     - AMI : Amazon Linux
     - Instance Type : t2.medium       
4) Connect to VM using MobaXterm

## Step-11 : Install Docker In Linux VM

```
sudo yum update -y 
sudo yum install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
exit
```
## Step-12 : Rress 'R' to restart the session (This is in MobaXterm)

## Step-13 :  Verify docker installation
```
docker -v
```
## Step-14 : Run SonarQube using docker image
```
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 sonarqube:lts-community
```

## Step-15 : Enable 9000 port number in Security Group Inbound Rules & Access Sonar Server
```
 - URL : http://public-ip:9000/
```
## Step-16 : Add SonarQube stage

1) Start Sonar Server <br/>
2) Login into Sonar Server & Generate Sonar Token  <br/>
	Ex: cedbc0b89e45c58f4a86e4687f2df2a2241e3369 <br/>
3) Add Sonar Token in 'Jenkins Credentials' as Secret Text <br/>
			-> Manager Jenkins  <br/>
			-> Credentials  <br/>
			-> Add Credentials <br/>
			-> Select Secret text <br/>
			-> Enter Sonar Token as secret text  <br/>

4) Install SonarQube Scanner Plugin <br/>
-> Manage Jenkins -> Plugins -> Available -> Sonar Qube Scanner Plugin -> Install it

5) Configure SonarQube Server <br/>
-> Manage Jenkins -> Configure System -> Sonar Qube Servers -> Add Sonar Qube Server 
		- Name : Sonar-Server-7.8
		- Server URL : http://52.66.247.11:9000/   (Give your sonar server url here)
		- Add Sonar Server Token
   
## Step-17 : Setup nexus using docker

1) Login into AWS Cloud account
2) Launch Linux VM using EC2 service   
     - AMI : Amazon Linux
     - Instance Type : t2.medium       
4) Connect to VM using MobaXterm

## Step-17 : Install Docker In Linux VM

```
sudo yum update -y 
sudo yum install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
exit
```
## Step-18 : Rress 'R' to restart the session (This is in MobaXterm)

## Step-19 :  Verify docker installation
```
docker -v
```
## Step-20 : Run Nexus using docker image
```
docker run -d -p 8081:8081 --name nexus sonatype/nexus3
```

## Step-21: Enable 8001 port number in Security Group Inbound Rules & Access Sonar Server
```
 http://public-ip:8081/
```

1) Run nexus VM and create nexus repository
2) Create Nexus Repository 
3) Install Nexus Repository Plugin using Manage Plugins   ( Plugin Name : Nexus Artifact Uploader)
4) Generate Nexus Pipeline Syntax


