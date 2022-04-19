resource "aws_security_group" "efs_mount_sg" {
  # name        = "efs-mount-sg"
  description = "Amazon EFS for EKS, SG for mount target"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Amazon EFS for EKS, SG for mount target"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  # egress {
  #   from_port        = 0
  #   to_port          = 0
  #   protocol         = "-1"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  tags = {
    Name = "efs-mount-sg"
  }
}

resource "aws_efs_file_system" "eks_efs" {
  creation_token = "eks-token"
  encrypted = true

  tags = {
    Name = "efs-for-eks"
  }
}

resource "aws_efs_mount_target" "mount_target" {
  count              = var.subnets_count
  subnet_id      = var.vpc_subnets[count.index]
  file_system_id = aws_efs_file_system.eks_efs.id
  security_groups = [aws_security_group.efs_mount_sg.id]
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.eks_efs.id
  posix_user {
      gid = 1000
      uid = 1000
    }

    root_directory {
      path = "/jenkins"
      creation_info {
        owner_gid   = 1000
        owner_uid   = 1000
        permissions = "0777"
      }
    }
}
