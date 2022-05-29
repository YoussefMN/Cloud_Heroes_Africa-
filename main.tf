# provider
provider "aws" {
  region = "eu-west-1"
}

# Create the VPC 
resource "aws_vpc" "Main" {
  cidr_block       = "10.0.0.0/24" #var.main_vpc_cidr
  instance_tenancy = "default"
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

#Route table for private subnets
resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    Name = "Private-route"
  }
}

#Route table association with public subnet
resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id      = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.PublicRT.id

}

#Route table association with private subnet
resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id      = aws_subnet.privatesubnets.id
  route_table_id = aws_route_table.PrivateRT.id

}

resource "aws_eip" "nateIP" {
  vpc = true
}

# Creating the NAT Gateway using subnet_id and allocation_id
resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.publicsubnets.id
  tags = {
    Name = "Nat-demo"
  }
}

# launch ec2 instance in public subnet
resource "aws_key_pair" "demokey" {
  key_name   = "demokey"
  public_key = "********" #the path to the file or the value of public key
}

resource "aws_security_group" "web_sg" {
  name   = "demo-sg"
  vpc_id = aws_vpc.Main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "website" {
  ami                         = "ami-0c1bc246476a5572b"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.demokey.id
  subnet_id                   = aws_subnet.publicsubnets.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data                   = file("web.sh")
  tags = {
    Name = "website-instance"
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.demokey.id
  subnet_id              = aws_subnet.privatesubnets.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "demo-instance"
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
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  identifier             = "mydb"
  name                   = "mydb"
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
