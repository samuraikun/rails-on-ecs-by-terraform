data "aws_caller_identity" "self" { }

resource "aws_s3_bucket" "alb_log" {
  bucket        = "rails-on-ecs-by-terraform-alb-log"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id = "expire-alb-log"
    status = "Enabled"

    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = [ "s3:PutObject" ]
    resources = [ "arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*" ]

    principals {
      type = "AWS"
      identifiers = [ 582318560864 ]
    }
  }
}
