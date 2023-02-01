# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "lb_dns_name" {
  value = aws_lb.app.dns_name
}
