# ☁️ Cloud Notes App — AWS Cloud Deployment

A cloud-based notes web application built with **Python Flask** and deployed on **Amazon EC2**. The application uses **Amazon RDS PostgreSQL** for database storage and **Amazon S3** for file storage.

The complete AWS infrastructure is provisioned using **Terraform**.

---

## 📌 Project Overview

The **Cloud Notes App** allows users to:

* 📝 Create notes
* 📎 Upload files with notes
* 📚 View stored notes
* 🗑️ Delete notes
* 🗄️ Store application data in PostgreSQL
* 📦 Store uploaded files in Amazon S3
* ☁️ Run the application on an AWS EC2 server

This project demonstrates how a traditional Flask application can be deployed using multiple AWS cloud services.

---

# 🏗️ Architecture

```text
                         INTERNET
                             │
                             │ HTTP :5000
                             ▼
                    ┌──────────────────┐
                    │      AWS EC2     │
                    │   Ubuntu Server  │
                    │                  │
                    │   Flask App      │
                    │    app.py        │
                    └────────┬─────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
          PostgreSQL :5432          AWS IAM Role
                │                         │
                ▼                         ▼
       ┌─────────────────┐       ┌─────────────────┐
       │   Amazon RDS    │       │   Amazon S3     │
       │   PostgreSQL    │       │  File Storage   │
       │                 │       │                 │
       │ Private Subnet  │       │ Private Bucket  │
       └─────────────────┘       └─────────────────┘
```

---

# ☁️ AWS Infrastructure

The infrastructure contains the following AWS resources:

### VPC

A custom VPC is created with:

```text
VPC CIDR: 10.0.0.0/16
```

### Subnets

```text
Public Subnet
10.0.1.0/24
```

Used for:

* EC2
* Internet-facing application

Two private subnets are used for RDS:

```text
Private Subnet A
10.0.2.0/24

Private Subnet B
10.0.3.0/24
```

RDS requires subnets in multiple Availability Zones for its DB subnet group.

---

# 🖥️ EC2

The Flask application runs on an Ubuntu EC2 instance.

EC2 is deployed in the public subnet so that users can access the web application.

The EC2 instance is configured with:

* Ubuntu
* Python 3
* Flask
* Gunicorn
* PostgreSQL client
* AWS CLI
* Python virtual environment

---

# 🗄️ Amazon RDS

The application uses **Amazon RDS for PostgreSQL**.

Configuration:

```text
Engine: PostgreSQL
Database: cloudnotes
Port: 5432
Storage: 20 GB
Storage Type: gp3
Public Access: Disabled
Encryption: Enabled
```

The RDS instance is located inside the private subnets.

The database is not directly exposed to the Internet.

---

# 📦 Amazon S3

Amazon S3 is used to store uploaded files.

Examples:

* Images
* PDFs
* Documents
* Other user-uploaded files

The S3 bucket is configured with:

* Versioning
* Server-side encryption
* Public access blocked

Uploaded files use the following object structure:

```text
uploads/
    filename.pdf
    image.png
    document.docx
```

---

# 🔐 IAM

The EC2 instance uses an IAM role to communicate with Amazon S3.

The application does **not** require AWS access keys inside the application.

The EC2 role provides permissions such as:

```text
s3:PutObject
s3:GetObject
s3:DeleteObject
s3:ListBucket
```

The permissions are restricted to the application's S3 bucket.

---

# 🔒 Security Groups

## EC2 Security Group

The EC2 security group allows web traffic to the application.

Example:

```text
HTTP
Port: 80
Source: Internet
```

During direct Flask testing:

```text
Custom TCP
Port: 5000
Source: Your IP
```

SSH should ideally be restricted to your own public IP:

```text
SSH
Port: 22
Source: YOUR_PUBLIC_IP/32
```

---

## RDS Security Group

RDS PostgreSQL is only accessible from the EC2 security group.

```text
EC2
 │
 │ TCP 5432
 ▼
RDS PostgreSQL
```

The RDS security group does not allow PostgreSQL traffic directly from the public Internet.

---

# 🧰 Technologies Used

| Technology   | Purpose                     |
| ------------ | --------------------------- |
| Python       | Application programming     |
| Flask        | Web framework               |
| PostgreSQL   | Relational database         |
| Amazon RDS   | Managed PostgreSQL database |
| Amazon S3    | File storage                |
| Amazon EC2   | Application server          |
| AWS IAM      | Access control              |
| AWS VPC      | Network isolation           |
| Terraform    | Infrastructure as Code      |
| Gunicorn     | Production WSGI server      |
| Nginx        | Reverse proxy               |
| Linux/Ubuntu | Server operating system     |
| Git/GitHub   | Version control             |

---

# 📁 Project Structure

```text
cloud-services-web-app/
│
├── app/
│   ├── app.py
│   ├── database.py
│   │
│   ├── templates/
│   │   └── index.html
│   │
│   └── static/
│       └── style.css
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── user-data.sh
│   └── .gitignore
│
├── requirements.txt
│
└── README.md
```

---

# 🐍 Flask Application

The Flask application provides the web interface and communicates with the cloud services.

Main routes include:

```text
/
```

Displays the notes.

```text
/add
```

Creates a new note and handles file uploads.

```text
/delete/<note_id>
```

Deletes a note.

```text
/health
```

Checks application health.

Example:

```bash
curl http://localhost:5000/health
```

Expected response:

```json
{
    "status": "healthy",
    "application": "Cloud Notes App"
}
```

---

# 🗄️ Database

The Flask application connects to PostgreSQL using:

```text
psycopg2
```

Database connection information is loaded from environment variables.

Example:

```env
DB_HOST=your-rds-endpoint
DB_PORT=5432
DB_NAME=cloudnotes
DB_USER=postgres
DB_PASSWORD=your-password
```

The application should never hard-code database credentials inside Python source code.

---

# 📦 S3 Configuration

The application uses `boto3` to communicate with S3.

Example environment variables:

```env
S3_BUCKET_NAME=your-bucket-name
AWS_REGION=us-east-1
```

Because the EC2 instance uses an IAM role, AWS credentials do not need to be stored in the `.env` file.

---

# 🔑 Environment Variables

Create a `.env` file inside the application directory:

```env
DB_HOST=your-rds-endpoint
DB_PORT=5432
DB_NAME=cloudnotes
DB_USER=postgres
DB_PASSWORD=your-password

S3_BUCKET_NAME=your-s3-bucket
AWS_REGION=us-east-1
```

### ⚠️ Important

Never commit `.env` to GitHub.

Add it to `.gitignore`:

```gitignore
.env
*.pem
terraform.tfvars
.terraform/
terraform.tfstate
terraform.tfstate.*
```

---

# 🚀 Infrastructure Deployment

## 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/cloud-services-web-app.git
```

Move into the Terraform directory:

```bash
cd cloud-services-web-app/terraform
```

---

# 2. Configure Terraform Variables

Create:

```text
terraform.tfvars
```

Example:

```hcl
aws_region   = "us-east-1"
project_name = "terraform-linux-server"
instance_type = "t3.micro"

db_name     = "cloudnotes"
db_username = "postgres"
db_password = "YOUR_STRONG_PASSWORD"

my_ip = "YOUR_PUBLIC_IP/32"
```

Do not commit this file to GitHub.

---

# 3. Initialize Terraform

```bash
terraform init
```

---

# 4. Validate Configuration

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

# 5. Review Infrastructure

```bash
terraform plan
```

Review the resources Terraform will create.

---

# 6. Deploy

```bash
terraform apply
```

Type:

```text
yes
```

Terraform creates the AWS infrastructure.

---

# 🖥️ Connect to EC2

After deployment, obtain the public IP:

```bash
terraform output public_ip
```

Then connect:

```bash
ssh -i terraform-linux-server-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

---

# 🐍 Configure Python on EC2

Update packages:

```bash
sudo apt update
```

Install Python tools:

```bash
sudo apt install -y python3 python3-venv python3-pip
```

Move to the application:

```bash
cd ~/cloud-notes/app
```

Create the virtual environment:

```bash
python3 -m venv venv
```

Activate it:

```bash
source venv/bin/activate
```

Install dependencies:

```bash
pip install -r ../requirements.txt
```

---

# 📋 Requirements

Example `requirements.txt`:

```text
Flask
psycopg2-binary
boto3
python-dotenv
gunicorn
```

---

# 🔗 Test EC2 → RDS

First, verify DNS:

```bash
nslookup YOUR_RDS_ENDPOINT
```

Then test port 5432:

```bash
nc -zv YOUR_RDS_ENDPOINT 5432
```

Expected:

```text
Connection to YOUR_RDS_ENDPOINT 5432 port [tcp/postgresql] succeeded!
```

This confirms that the EC2 instance can reach PostgreSQL over the private network.

---

# 🗄️ Test PostgreSQL

```bash
psql \
  -h YOUR_RDS_ENDPOINT \
  -p 5432 \
  -U postgres \
  -d cloudnotes
```

Enter the RDS password when prompted.

If successful:

```text
cloudnotes=>
```

Check tables:

```sql
\dt
```

Exit:

```sql
\q
```

---

# 📦 Test EC2 → S3

Because EC2 has an IAM role, test:

```bash
aws sts get-caller-identity
```

Then:

```bash
aws s3 ls
```

You can also test your bucket:

```bash
aws s3 ls s3://YOUR_BUCKET_NAME
```

---

# ▶️ Run Flask

Inside the application directory:

```bash
cd ~/cloud-notes/app
```

Activate the virtual environment:

```bash
source venv/bin/activate
```

Run:

```bash
python3 app.py
```

Flask should listen on:

```text
0.0.0.0:5000
```

---

# 🌐 Access the Website

If port 5000 is temporarily allowed by the EC2 security group, open:

```text
http://YOUR_EC2_PUBLIC_IP:5000
```

The Cloud Notes application should appear.

---

# 🔄 Production Deployment

For a production-style deployment, Flask's development server should not be used.

Instead:

```text
Internet
    │
    │ HTTP :80
    ▼
  Nginx
    │
    │ localhost:5000
    ▼
 Gunicorn
    │
    ▼
 Flask
```

Run Gunicorn:

```bash
gunicorn \
  --bind 127.0.0.1:5000 \
  app:app
```

Nginx can then forward incoming HTTP requests to Gunicorn.

---

# 🧪 Application Testing

## Health Check

```bash
curl http://localhost:5000/health
```

Expected:

```json
{
    "status": "healthy",
    "application": "Cloud Notes App"
}
```

---

## Database Test

Verify:

```text
EC2 → RDS
```

using:

```bash
nc -zv YOUR_RDS_ENDPOINT 5432
```

---

## S3 Test

Verify:

```text
EC2 → IAM Role → S3
```

using:

```bash
aws s3 ls s3://YOUR_BUCKET_NAME
```

---

## File Upload Test

1. Open the Cloud Notes website.
2. Write a note.
3. Select a file.
4. Click **Add Note**.
5. Check the S3 bucket.

The uploaded object should appear under:

```text
uploads/
```

---

# 🔐 Security Practices

This project follows several basic cloud security practices:

### Private Database

RDS is:

```text
publicly_accessible = false
```

Therefore, it is not directly exposed to the Internet.

### Restricted Database Access

PostgreSQL access is restricted to the EC2 security group.

```text
EC2 SG → RDS SG : 5432
```

### S3 Public Access Block

The S3 bucket blocks:

```text
Public ACLs
Public bucket policies
Public access
```

### Encryption

S3 uses server-side encryption.

RDS storage encryption is enabled.

### IAM Role

EC2 accesses S3 using an IAM role instead of storing AWS access keys inside the application.

### SSH

SSH should be restricted to the administrator's public IP instead of:

```text
0.0.0.0/0
```

---

# 🏛️ Network Design

```text
VPC
10.0.0.0/16
│
├── Public Subnet
│   10.0.1.0/24
│   │
│   └── EC2
│
├── Private Subnet A
│   10.0.2.0/24
│   │
│   └── RDS
│
└── Private Subnet B
    10.0.3.0/24
    │
    └── RDS Subnet Group
```

The Internet Gateway provides Internet connectivity for the public subnet.

The RDS subnets remain private.

---

# 🔄 Request Flow

When a user creates a note:

```text
User
 │
 ▼
EC2
 │
 ▼
Flask
 │
 ├──────────────► PostgreSQL RDS
 │                  │
 │                  └── Store note
 │
 └──────────────► Amazon S3
                    │
                    └── Store uploaded file
```

---

# 💰 Cost Considerations

This project uses AWS resources that may incur charges depending on the AWS account and pricing model.

Resources to monitor include:

* EC2
* RDS
* S3
* Data transfer
* Elastic IP, if used
* Other associated AWS resources

For learning environments, resources should be stopped or destroyed when they are no longer needed.

---

# 🧹 Destroy Infrastructure

When the project is finished:

```bash
terraform destroy
```

Review the resources Terraform wants to delete.

Then confirm:

```text
yes
```

### ⚠️ Warning

`terraform destroy` deletes the infrastructure managed by this Terraform configuration.

Make sure you have backed up anything you need before running it.

---

# 📊 Project Learning Outcomes

Through this project, I practiced:

* AWS cloud infrastructure
* Terraform Infrastructure as Code
* Linux server administration
* VPC networking
* Public and private subnets
* Internet Gateway
* Route tables
* Security Groups
* EC2 deployment
* PostgreSQL
* Amazon RDS
* Amazon S3
* IAM roles
* IAM permissions
* Environment variables
* Flask application deployment
* Python virtual environments
* Gunicorn
* Nginx
* Cloud security fundamentals
* Application troubleshooting

---

# 🧠 Key Cloud Concepts Demonstrated

### Compute

Amazon EC2 provides the server that runs the Flask application.

### Database

Amazon RDS provides a managed PostgreSQL database.

### Storage

Amazon S3 provides object storage for uploaded files.

### Networking

Amazon VPC isolates the infrastructure into public and private network segments.

### Security

Security Groups control network traffic between EC2 and RDS.

### Identity

IAM roles allow EC2 to access S3 without storing AWS access keys.

### Infrastructure as Code

Terraform creates and manages the AWS infrastructure using configuration files.

---

# 📸 Project Evidence

Recommended screenshots for the project documentation:

### 1. Terraform

* `terraform plan`
* `terraform apply`
* Terraform resources

### 2. AWS VPC

* VPC
* Public subnet
* Private subnets
* Route tables

### 3. EC2

* Running EC2 instance
* Public IP
* Security Group

### 4. RDS

* PostgreSQL database
* Private connectivity
* RDS endpoint

### 5. S3

* S3 bucket
* Uploaded file
* Versioning/encryption settings

### 6. IAM

* EC2 IAM role
* S3 permissions

### 7. Application

* Cloud Notes homepage
* Creating a note
* File upload
* Notes list

### 8. Connectivity

```bash
nc -zv RDS_ENDPOINT 5432
```

and:

```bash
aws s3 ls s3://YOUR_BUCKET_NAME
```

---

# 🚧 Future Improvements

Possible future improvements include:

* HTTPS using AWS Certificate Manager
* Domain name
* Nginx reverse proxy
* Gunicorn systemd service
* Better authentication and authorization
* Store S3 object keys in the database
* Generate secure S3 pre-signed URLs
* Application logging
* CloudWatch monitoring
* Automated CI/CD with GitHub Actions
* Docker containerization
* Load balancing with an Application Load Balancer
* Auto Scaling
* AWS Secrets Manager
* Database backups and recovery testing

---

# 🎯 Project Goal

The goal of this project is to demonstrate a complete cloud deployment workflow:

```text
Application
     ↓
Terraform
     ↓
AWS Infrastructure
     ↓
EC2 + RDS + S3
     ↓
Secure Networking
     ↓
Running Flask Application
```

This project demonstrates practical experience with **AWS, Terraform, Linux, Python/Flask, PostgreSQL, S3, IAM, networking, and cloud deployment**.

---

# 👨‍💻 Author

**Aleem Ahmad**

BS Mathematics
Namal University

### Areas of Interest

* DevOps
* Cloud Engineering
* AWS
* Kubernetes
* Terraform
* CI/CD
* Infrastructure as Code
* Cloud Security
* AI/DevOps

---

# ⭐ Acknowledgement

This project was developed as part of hands-on learning in:

**Cloud Services & Web Application Deployment**

The project focuses on applying cloud infrastructure, networking, security, database, storage, and application deployment concepts in a practical AWS environment.
