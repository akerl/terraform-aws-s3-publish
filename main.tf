data "aws_iam_policy_document" "publish" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.publish-bucket}/*",
      "arn:aws:s3:::${var.publish-bucket}",
    ]
  }
}

resource "aws_iam_user_policy" "s3_publish" {
  name   = "s3_publish"
  user   = "${aws_iam_user.build.name}"
  policy = "${data.aws_iam_policy_document.publish.json}"
}

resource "awscreds_iam_access_key" "build-key" {
  user = "${aws_iam_user.build.name}"
  file = "creds/${aws_iam_user.build.name}"
}

resource "aws_s3_bucket" "publish-bucket" {
  bucket = "${var.publish-bucket}"

  versioning {
    enabled = "true"
  }

  logging {
    target_bucket = "${var.logging-bucket}"
    target_prefix = "${var.publish-bucket}/"
  }

  count = "${var.make-bucket}"
}

resource "aws_iam_user" "build" {
  name = "build-${var.publish-bucket}"
}
