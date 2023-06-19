provider "aws" {
    region = var.default_region
            
}           
        
variable default_region {}
variable env_prefix {}       
variable vpc_cidr_block {}  
variable subnet_cidr_block {}
variable avail_zone {}
variable my_ip {}
variable instance_type {}
#variable my_public_key {}
variable public_key_location {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
# variable inside a string
        Name: "${var.env_prefix}-vpc"
    }
}

resource  "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id 
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table"  "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

#incoming fireall rule, from and to is a range of ports

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]

# just allow one ip
#cidr_block = ["102.165.226.130/32"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        
    }

    egress {
        from_port = 0
        to_port = 0
# allow all protocols using -1 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
        }

    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["amazon"]
    
    filter {
        name = "name"
        values = ["al2023-ami-*-x86_64"]
    }

    filter {  
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami_id" {
  value       = data.aws_ami.latest-amazon-linux-image.id

}

output "ec2_public_id" {
  value = aws_instance.myapp-server.public_ip
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("entryscript.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }

}

resource "aws_key_pair" "ssh-key"{

    key_name = "terra-server-key"
    public_key = file(var.public_key_location)
}

# resource "aws_route_table" "myapp-route-table" {
#     vpc_id = aws_vpc.myapp-vpc.id
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp-igw.id
#     }
#     tags = {
#         Name: "${var.env_prefix}-igw"
#     }
# }


#  resource "aws_route_table_association" "a-rtb-subnet" {
#             subnet_id = aws_subnet.myapp-subnet-1.id 
#             route_table = aws_route_table.myapp-route-table.id        
# }