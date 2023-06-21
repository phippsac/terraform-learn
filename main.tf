provider "aws" {
    region = var.default_region
            
}           
 module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block


  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = { Name = "${var.env_prefix}-subnet-1"}

  tags = {
    Name = "${var.env_prefix}-vpc"  
    Environment = "dev"
  }
}


#variables mentioned here need to be defined in same directory as main.tf, so variables.tf, they in turn
#get their values from terraform.tfvars file

#variables can als0 be referenced from resource i.e aws_vpc.myapp-vpc.id 

module "myapp-server" {
    source = "./modules/webserver" 
#this gives us vpc id of the vpc module created above
    vpc_id = module.vpc.vpc_id 
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.vpc.public_subnets[0]
    avail_zone = var.avail_zone
}


    # connection {
    #     type = "ssh"
    #     host = self.public_ip
    #     user = "ec2-user"
    #     private_key = file(var.private_key_location)

    # }

    # provisioner "file" {
    #     source = "entryscript.sh"
    #     destination = "/home/ec2-user/entry-script.sh"
    # }

    # provisioner "remote-exec" {
    #     script = file("entryscript.sh")
    # }

    # provisioner "local-exec" {
    #     command = "echo ${self.public_ip} > /root/output.txt"
    # }



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