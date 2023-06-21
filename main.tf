provider "aws" {
    region = var.default_region
            
}           
        

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
# variable inside a string
        Name: "${var.env_prefix}-vpc"
    }
}

#variables mentioned here need to be defined in same directory as main.tf, so variables.tf, they in turn
#get their values from terraform.tfvars file

#variables can als0 be referenced from resource i.e aws_vpc.myapp-vpc.id 

module "myapp-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id 
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}



module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
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