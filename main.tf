terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # you can change if you are in a different country/region
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-super-cool-tf-bucket"
  acl    = "private"

  tags = {
    Name        = "machine-learning" # tags are important for cost tracking
    Environment = "prod"
  }
}



# Install the Doppler provider
terraform {
  required_providers {
    doppler = {
      source = "DopplerHQ/doppler"
      version = "1.0.0" # Always specify the latest version
    }
  }
}

# Define a variable so we can pass in our token
variable "doppler_token" {
  type = string
  description = "A token to authenticate with Doppler"
}

# Configure the Doppler provider with the token
provider "doppler" {
  doppler_token = var.doppler_token
}

# Generate a random password
resource "random_password" "db_password" {
  length = 32
  special = true
}

# Save the random password to Doppler
resource "doppler_secret" "db_password" {
  project = "example-project"
  config = "dev"
  name = "DB_PASSWORD"
  value = random_password.db_password.result
}

# Access the secret value
output "resource_value" {
  # nonsensitive used for demo purposes only
  value = nonsensitive(doppler_secret.db_password.value)
}