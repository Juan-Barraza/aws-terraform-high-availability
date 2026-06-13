resource "aws_efs_file_system" "fs" {
  creation_token = "efs_apps${var.tags.env}"

  tags = {
    "Name" = "efs_shared_${var.tags.env}"
  }
}

data "aws_iam_policy_document" "poliy_efs" {
  statement {
    sid    = "AllowTLSOnly"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.fs.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.fs.id
  policy         = data.aws_iam_policy_document.poliy_efs.json
}


resource "aws_security_group" "efs_sg" {
  name        = "Sg_004_efs"
  description = "Allow NFS traffic for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from application instances"
    from_port       = var.ingress_efs.port_from
    to_port         = var.ingress_efs.to_port
    protocol        = "tcp"
    security_groups = [var.segurity_group_persistence_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-mount-target-sg"
  }
}


resource "aws_efs_mount_target" "main" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.fs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}
