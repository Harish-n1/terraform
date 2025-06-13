provider "aws" {
    region = ""
    access_key = ""
    secret_key = ""
}

resource "aws_iam_user" "admin_user" {
    name = "hari"
    tags = {
        Description = "Admin"
    }
}

resource "aws_iam_polilcy" "admin_policy" {
    name = "AdminPolicy"
    description = "Admin policy for full access"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "*"
                Resource = "*"
            }
        ]
    })
}