provider "aws" {
    region = var.default_region
}           

variable default_region {}

# Create variables for cidr block
variable "cidr_blocks" {
    description = "cidr blocks"
    type = list(object({
        cidr_block = string
        name = string
    }))
}
            


# Create new vpc
resource "aws_vpc" "terraform-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name: var.cidr_blocks[0].name,  
        vpc_env: "dev"
        }
    }

# Create new subnet within that vpc

resource "aws_subnet" "terraform-vpc-subnet1" {
    vpc_id = aws_vpc.terraform-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = "af-south-1a"
    tags = {
        Name: "subnet-1-dev"
        }
}

# data allows you to query Data Sources from AWS 

data "aws_vpc" "existing_vpc" {
    default = "true"
}

resource "aws_subnet" "terraform-vpc-subnet2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = "af-south-1a"
    
}

#resource "aws_subnet" "terraform-vpc-subnet2" {
#    vpc_id = aws_vpc.terraform-vpc.id
#    cidr_block = "10.0.128.0/17"
#    availability_zone = "af-south-1b"
#}
#
#resource "aws_subnet" "terraform-vpc-subnet3" {
#    vpc_id = aws_vpc.terraform-vpc.id
#    cidr_block = "10.128.0.0/17"
#    availability_zone = "af-south-1c"
#}