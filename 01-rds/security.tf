# ===============================================================================
# SECURITY GROUP FOR POSTGRESQL (PORT 5432)
# ===============================================================================
# Defines network access rules for PostgreSQL traffic and unrestricted
# outbound connectivity within the RDS VPC.
# ===============================================================================

resource "aws_security_group" "rds_sg" {

  # Name of the security group
  name = "rds-sg"

  # Description of allowed traffic
  description = "Allow PostgreSQL inbound access and all outbound traffic"

  # Associate the security group with the RDS VPC
  vpc_id = aws_vpc.rds-vpc.id

  # -----------------------------------------------------------------------------
  # INBOUND RULES
  # -----------------------------------------------------------------------------

  # Allow PostgreSQL traffic from any IPv4 address
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------------------------------------------------------
  # OUTBOUND RULES
  # -----------------------------------------------------------------------------

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}
