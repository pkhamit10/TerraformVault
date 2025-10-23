provider "aws" {
    region = "us-east-1"
}
variable login_approle_role_id {
    default = "fb0d2515-48e3-b470-d8e6-2a19afe1b3fc"
}
variable login_approle_secret_id {
    default = "a1989553-05f1-da44-6cfe-f6049cd29fa8"
}

provider "vault" {
    address = "http://54.224.26.64:8200"
    skip_child_token = true
    
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.login_approle_role_id
      secret_id = var.login_approle_secret_id
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "pksecret"
  name  = "test-secret"
}

resource "aws_instance" "example" {
    ami           = "ami-0341d95f75f311023"
    instance_type = "t3.micro"

    tags = {
        secret = data.vault_kv_secret_v2.example.data["username"]
    }
}