resource "aws_security_group" "myapp-sg" {
    vpc_id = var.vpc_id
    name = "myapp-sg"

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
        values = [var.image_name]
    }

    filter {  
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh-key"{

    key_name = "terra-server-key"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

   user_data = file("entryscript.sh")

       tags = {
        Name = "${var.env_prefix}-server"
    }

}
