
# ==========================================
# IAM ROLE FOR EC2
# ==========================================

resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ec2-s3-role"
    Project = var.project_name
  }
}


# ==========================================
# S3 POLICY FOR EC2
# ==========================================

resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "${var.project_name}-s3-policy"
  description = "Allow EC2 to access Cloud Notes S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.cloud_notes.arn}/*"
      },

      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.cloud_notes.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}
# ==========================================
# EC2 INSTANCE PROFILE
# ==========================================

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"

  role = aws_iam_role.ec2_s3_role.name
}
