resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.acme_email
}

resource "acme_certificate" "ghost" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.acme_cn

  dns_challenge {
    provider = "cloudflare"
  }
}