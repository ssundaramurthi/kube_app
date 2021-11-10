resource "aws_ecr_repository" "codebuild_ecr" {
  name                 = "codebuild-alpine"
  image_tag_mutability = "MUTABLE"

  encryption_configuration{
    encryption_type      = "AES256"
  }


  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "eks_api" {
  name                 = "eks-api"
  image_tag_mutability = "MUTABLE"

  encryption_configuration{
    encryption_type      = "AES256"
  }


  image_scanning_configuration {
    scan_on_push = true
  }
}