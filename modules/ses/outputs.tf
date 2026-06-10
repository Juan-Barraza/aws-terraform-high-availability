output "dkim_tokens" {
  value = var.enable_ses && var.use_domain_identity ? aws_ses_domain_dkim.main[0].dkim_tokens : []
}

output "domain_identity_arn" {
  value = var.enable_ses && var.use_domain_identity ? aws_ses_domain_identity.main[0].arn : null
}