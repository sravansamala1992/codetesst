# This terraform template deploys a scalable and secure web application in AWS Auto Scaling Group behind Elastic Load Balancer and distributes traffic across the EC2 Instance in ASG. It also creates Route53 Record Set record under primary Hosted Zone with a Alias Target as a ELB DNS Name.
# Service Provider AWS Configuration

provider "aws" {
	region = "us-east-1"
}
# Fetches all availability Zones under Region configured above, i.e. "us-east-1"

data "aws_availability_zones" "all" {}

# Creates aws_autoscaling_group

resource "aws_autoscaling_group" "agterrafrom" {
	launch_configuration = "${aws_launch_configuration.lcterraform.id}"
	availability_zones = ["${data.aws_availability_zones.all.names}"]

	min_size = 2
	max_size = 3

	load_balancers = ["${aws_elb.elbterraform.name}"]
	health_check_type = "ELB"

	tag {
	 key = "Name"
	 value = "terraformautoscaling"
	 propagate_at_launch = true

     }
}

# Creates Launch Configuration for aws_autoscaling_group

resource "aws_launch_configuration" "lcterraform" {
	image_id = "ami-01e3b8c3a51e88954"
        instance_type = "t2.micro"
        security_groups = ["${aws_security_group.sgterraform.id}"]
        key_name = "test"
        user_data = "${file("userdatascript")}"
   	root_block_device {
       # device_name = "/dev/sda1"
        volume_size = 8
        volume_type = "gp2"
        delete_on_termination = true
        }
 
	lifecycle {
		create_before_destroy = true
	}
}

# Create Security Group for EC2 Instances under aws_autoscaling_group


resource "aws_security_group" "sgterraform" {
	name = "tfrm-sg-clstr"

        ingress {
                from_port = "22"
                to_port   = "22"
                protocol  = "tcp"
                cidr_blocks= ["0.0.0.0/0"]
                }
        ingress {
                from_port = "80"
                to_port   = "80"
                protocol  = "tcp"
                cidr_blocks= ["0.0.0.0/0"]
                }
        ingress {
                from_port = "443"
                to_port   = "443"
               protocol  = "tcp"
                cidr_blocks= ["0.0.0.0/0"]
                }
        egress {
                from_port = "0"
                to_port = "1000"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
               }
	lifecycle {
		create_before_destroy = true
	}	
}

# Create Elastic Load Balancer 


resource "aws_elb" "elbterraform" {
	name = "terraform-elb"
	security_groups = ["${aws_security_group.sgelbterraform.id}"]
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	
	health_check {
		healthy_threshold = 2
		unhealthy_threshold = 10
		timeout = 3
		interval = 30
	#	target = "HTTP:80/index.html"
		target = "HTTPS:${var.healthchk_port}/index.html"
	}

	listener {
		lb_port = "80"
		lb_protocol = "http"
		instance_port = "80"
		instance_protocol = "http"
	}

        listener {
                lb_port = 443
                lb_protocol = "https"
                instance_port = "443"
                instance_protocol = "https"
                ssl_certificate_id =   "arn:aws:acm:us-east-1:855795182277:certificate/1fe1ebee-f86d-46a7-af37-b22b2857ddaa"
	
	}

}

# Creates SG for ELB

resource "aws_security_group" "sgelbterraform" {
	name = "terraform-sg-elb"
	egress {
   		 from_port = 0
    		to_port = 0
    		protocol = "-1"
   		 cidr_blocks = ["0.0.0.0/0"]
  	}
	
	ingress {
                from_port = "80"
                to_port   = "80"
                protocol  = "tcp"
                cidr_blocks= ["0.0.0.0/0"]
                }
        ingress {
         from_port = "443"
         to_port   = "443"
         protocol  = "tcp"
         cidr_blocks= ["0.0.0.0/0"]
         }

}

# Creates Route53 Record Set for ELB DNS Name under Primary Hosted Zone


