default_region = "af-south-1"
env_prefix = "dev"  
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
avail_zone = "af-south-1c"
my_ip ="197.94.66.59/32"
instance_type = "t3.micro"
image_name = "al2023-ami-2023*-x86_64"
public_key_location = "/terraform_aws/.ssh/id_rsa.pub"
private_key_location = "/terraform_aws/.ssh/id_rsa"
#
#cidr_blocks = [
#    { cidr_block = "10.0.0.0/16", name = "dev-vpc"},
#    { cidr_block = "10.0.10.0/24", name = "dev-subnet"}
#]
#vpc_cidr_block = "10.0.0.0/16"
