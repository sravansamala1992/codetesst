# codetesst
This terraform template deploys a scalable and secure web application in AWS Auto Scaling Group behind Elastic Load Balancer and distributes traffic across the EC2 Instance in ASG. It also creates Route53 Record Set record under primary Hosted Zone with a Alias Target as a ELB DNS Name.
# Service Provider AWS Configuration
Creates aws_autoscaling_group
Creates Launch Configuration for aws_autoscaling_group
Create Security Group for EC2 Instances under aws_autoscaling_group
Create Elastic Load Balancer 
Creates SG for ELB
validation of credit card numbers
