# provider
provider "aws" {
  region = "eu-west-1"
}

# Create the VPC 
resource "aws_vpc" "Main" {
  cidr_block           = "10.0.0.0/24" #var.main_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "vpc-demo"
  }
}

# Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Main.id
  tags = {
    Name = "igw-demo"
  }
}

# Create a public subnets
resource "aws_subnet" "publicsubnets" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = "10.0.0.128/26" #var.publicsubnets
  tags = {
    Name = "pub-demo"
  }
}
resource "aws_subnet" "privatesubnets" {
  vpc_id            = aws_vpc.Main.id
  cidr_block        = "10.0.0.192/26" #var.privatesubnets
  availability_zone = "eu-west-1a"
  tags = {
    Name = "priv-demo"
  }
}

resource "aws_subnet" "privatesubnet2" {
  vpc_id            = aws_vpc.Main.id
  cidr_block        = "10.0.0.64/26"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "priv-sub2"
  }
}
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnetgroup"
  subnet_ids = [aws_subnet.privatesubnets.id, aws_subnet.privatesubnet2.id]
}
#Route table for public subnets
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "Public-route"
  }
}

#Route table association with public subnet
resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id      = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.PublicRT.id

}

# launch ec2 instance in public subnet

resource "aws_security_group" "web_sg" {
  name   = "demo-sg"
  vpc_id = aws_vpc.Main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "website" {
  ami                         = "ami-0c1bc246476a5572b"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.publicsubnets.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data                   = file("web.sh")
  tags = {
    Name = "website-instance"
  }
}

# launch RDS in private subnet
resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
  vpc_id      = aws_vpc.Main.id
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-example-rds-security-group"
  }
}

resource "aws_db_instance" "mydb" {
  allocated_storage      = 100
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  identifier             = "mydb"
  db_name                = "mydb"
  username               = "root"
  password               = "foobarbaz"
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}

# What we need to improve in our terraform script ?

# Use of modules,vars,outputs ....
## Make it HA,more secure ...
### Monitoring,Backup of the resources...
#### Any others suggestions 
