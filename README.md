AWS Infrastructure with Terraform

GitHub hosts the Node.js application's code.
Terraform provisions the AWS infrastructure, including:
EC2 instance to run the Node.js application.
RDS MySQL database for data storage.
S3 bucket for file storage.
The Node.js application connects to the RDS database over port 3306, restricted by security groups for secure communication.
The application interacts with Amazon S3 for uploading or retrieving files.
The whole setup runs within the default VPC, ensuring isolation and secure access to resources.
