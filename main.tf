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
    policy = file("admin_policy.json")
}

resource "aws_iam_policy_attachment" "hari-admin-access" {
    name       = "hari-admin-access"
    users      = aws_iam_user.admin_user.name
    policy_arn = aws_iam_polilcy.admin_policy.arn
}