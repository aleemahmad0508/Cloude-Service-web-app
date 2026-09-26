
data "aws_caller_identity" "current" {}



# ==========================================
# 3. NETWORK RESOURCES (VPC, Subnet, Routing)
# ==========================================
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a" # Dynamically targets the first AZ of your selected region

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# ==========================================
# PRIVATE SUBNETS FOR RDS
# ==========================================

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}-private-subnet-b"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
# ==========================================
# PRIVATE ROUTE TABLE
# ==========================================

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}
# ==========================================
# PRIVATE ROUTE TABLE ASSOCIATIONS
# ==========================================

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}




# ==========================================
# 5. KEY PAIR GENERATION
# ==========================================
resource "tls_private_key" "generated_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.generated_ssh_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.generated_ssh_key.private_key_pem
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
}



# ==========================================
# 6. COMPUTE RESOURCE (EC2 Instance)
# ==========================================
resource "aws_instance" "linux_server" {
  ami           = "ami-0c7217cdde317cfec" # Ensure this AMI is valid for your selected var.aws_region
  instance_type = var.instance_type
  
  # FIXED: Now uses the key pair generated above instead of an unlinked variable
  key_name      = aws_key_pair.deployer_key.key_name

  subnet_id              = aws_subnet.public_subnet.id 
  vpc_security_group_ids = [aws_security_group.web_sg.id] 
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  
  # Note: Ensure you have a 'user-data.sh' file in the same directory, or comment this line out
  user_data = fileexists("${path.module}/user-data.sh") ? file("${path.module}/user-data.sh") : null

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name    = var.project_name
    Project = var.project_name
  }
}

