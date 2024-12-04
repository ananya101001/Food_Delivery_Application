terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ${path.module}/key.pem && chmod 0700 ${path.module}/key.pem"
  }
}

resource "aws_instance" "backend_instance" {
  ami           = "ami-0d53d72369335a9d6"  # Ubuntu 22.04 free tier ami in us-west-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh_http_1.id, aws_security_group.lambda_sg.id]
  subnet_id = aws_subnet.public_subnet_1.id  # Use a public subnet
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "FoodDeliveryBackend"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main"
  }
}

resource "aws_lambda_function" "get_restaurants" {
  filename      = "/Users/akshashe/Documents/Cloud Technologies/food_delivery_project/lambda_functions/get_restaurants.zip"
  function_name = "get_restaurants"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DB_HOST = aws_db_instance.food_delivery_db.address
      DB_NAME = aws_db_instance.food_delivery_db.name
      DB_USER = aws_db_instance.food_delivery_db.username
    }
  }
}

resource "aws_lambda_function" "post_restaurant" {
  filename      = "/Users/akshashe/Documents/Cloud Technologies/food_delivery_project/lambda_functions/post_restaurants.zip"
  function_name = "post_restaurant"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DB_HOST = aws_db_instance.food_delivery_db.address
      DB_NAME = aws_db_instance.food_delivery_db.name
      DB_USER = aws_db_instance.food_delivery_db.username
    }
  }
}

resource "aws_lambda_function" "get_menu" {
  filename      = "/Users/akshashe/Documents/Cloud Technologies/food_delivery_project/lambda_functions/get_menu.zip"
  function_name = "get_menu"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DB_HOST = aws_db_instance.food_delivery_db.address
      DB_NAME = aws_db_instance.food_delivery_db.name
      DB_USER = aws_db_instance.food_delivery_db.username
    }
  }
}

resource "aws_lambda_function" "post_menu" {
  filename      = "/Users/akshashe/Documents/Cloud Technologies/food_delivery_project/lambda_functions/post_menu.zip"
  function_name = "post_menu"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DB_HOST = aws_db_instance.food_delivery_db.address
      DB_NAME = aws_db_instance.food_delivery_db.name
      DB_USER = aws_db_instance.food_delivery_db.username
    }
  }
}

resource "aws_lambda_function" "post_order" {
  filename      = "/Users/akshashe/Documents/Cloud Technologies/food_delivery_project/lambda_functions/post_orders.zip"
  function_name = "post_order"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DB_HOST = aws_db_instance.food_delivery_db.address
      DB_NAME = aws_db_instance.food_delivery_db.name
      DB_USER = aws_db_instance.food_delivery_db.username
    }
  }
}

resource "aws_lambda_function" "get_order" {
  filename      = "/Users/akshashe/Documents/Cloud Technologies/food_delivery_project/lambda_functions/get_orders.zip"
  function_name = "get_order"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      DB_HOST = aws_db_instance.food_delivery_db.address
      DB_NAME = aws_db_instance.food_delivery_db.name
      DB_USER = aws_db_instance.food_delivery_db.username
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-security-group"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id  # Assuming you have a VPC resource defined

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_public_ip" {
  value = aws_instance.backend_instance.public_ip
}

output "lambda_function_name" {
  value = aws_lambda_function.get_restaurants.function_name
}