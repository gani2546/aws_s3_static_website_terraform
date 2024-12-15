#create s3 bucket
resource "aws_s3_bucket" "my_s3" {
    bucket = var.bucket_name
  
}

# bucket versioning
resource "aws_s3_bucket_versioning" "s3_version" {
    bucket = aws_s3_bucket.my_s3.id
    versioning_configuration {
      status = "Enabled"
    }
  
}

#aws_s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.my_s3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#public access
resource "aws_s3_bucket_public_access_block" "pub_access" {
  bucket = aws_s3_bucket.my_s3.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

#bucket acl
resource "aws_s3_bucket_acl" "bucket_acl" {
    depends_on = [ aws_s3_bucket_ownership_controls.s3_ownership, 
                   aws_s3_bucket_public_access_block.pub_access,
                ]
    bucket = aws_s3_bucket.my_s3.id
    acl = "public-read"
}

#upload objects into s3 bucket
resource "aws_s3_object" "index" {
    bucket = aws_s3_bucket.my_s3.id
    key = "index.html"
    source = "index.html"
    content_type = "text/html"
    acl = "public-read"
}

resource "aws_s3_object" "error" {
    bucket = aws_s3_bucket.my_s3.id
    key = "error.html"
    source = "error.html"
    content_type = "text/html"
    acl = "public-read"
}

#website configuration
resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.my_s3.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }

    depends_on = [ aws_s3_bucket_acl.bucket_acl ]
}
