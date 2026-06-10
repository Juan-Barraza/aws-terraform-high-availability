
# Just dev/sandbox
resource "aws_ses_email_identity" "sender_email" {
  count = var.enable_ses ? 1 : 0
  email = var.notification_email
}

# to use in prodcution
resource "aws_ses_domain_identity" "main" {
  count  = var.enable_ses && var.use_domain_identity ? 1 : 0
  domain = var.ses_domain
}

resource "aws_ses_domain_dkim" "main" {
  count  = var.enable_ses && var.use_domain_identity ? 1 : 0
  domain = aws_ses_domain_identity.main[0].domain
}

resource "aws_ses_identity_notification_topic" "bounce_report" {
  count                    = var.enable_ses && var.enable_ses_monitoring ? 1 : 0
  notification_type        = "Bounce"
  identity                 = var.use_domain_identity ? aws_ses_domain_identity.main[0].domain : aws_ses_email_identity.sender_email[0].email
  include_original_headers = true
}