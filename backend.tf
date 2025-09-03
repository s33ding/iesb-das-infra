terraform {
  backend "s3" {
    bucket         = "iesb-das-terraform"   # Your S3 bucket name
    key            = "state/terraform.tfstate"  # Path to store the state file
    region         = "us-east-1"  # Change to your AWS region
    encrypt        = true  # Enable encryption for security
  }
}

