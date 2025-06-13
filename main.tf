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