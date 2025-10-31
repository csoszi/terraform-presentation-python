variable "subnet_id" { type = string }
variable "vpc_id" { type = string }
variable "instance_type" { 
    type = string 
    default = "t3.micro" 
    }
variable "key_name" { 
    type = string 
    default = "" 
    }
variable "app_port" { 
    type = number 
    default = 8000 
    }
variable "app_repo_url" { 
    type = string 
    default = "" 
    }

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "presentation-app-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  user_data = <<-EOF
              #!/bin/bash
              set -e
              yum -y update
              yum -y install python3 git gcc openssl-devel bzip2-devel libffi-devel make
              python3 -m pip install --upgrade pip
              pip3 install virtualenv
              mkdir -p /opt/presentation-app
              cd /opt/presentation-app
              if [ -n "${var.app_repo_url}" ]; then
                git clone ${var.app_repo_url} app || (cd app && git pull)
                cd app
              else
                mkdir -p app
                cd app
              fi
              if [ -f requirements.txt ]; then
                python3 -m venv .venv
                source .venv/bin/activate
                pip install -r requirements.txt
              else
                pip3 install django gunicorn whitenoise
              fi
              # Apply migrations and collect static
              export PYTHONUNBUFFERED=1
              if [ -f manage.py ]; then
                python manage.py migrate --noinput || true
                python manage.py collectstatic --noinput || true
              fi
              # Run app with gunicorn
              # Try common WSGI modules:
              if [ -f manage.py ]; then
                # Django: use gettingstarted.wsgi or try to detect WSGI
                gunicorn gettingstarted.wsgi:application --bind 0.0.0.0:${var.app_port} --daemon || true
              else
                # fallback: try wsgi:app
                gunicorn wsgi:app --bind 0.0.0.0:${var.app_port} --daemon || true
              fi
              EOF

  tags = { Name = "presentation-app-instance" }
}

output "instance_public_ip" { value = aws_instance.app.public_ip }
output "instance_id" { value = aws_instance.app.id }