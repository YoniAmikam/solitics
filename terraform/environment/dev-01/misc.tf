resource "null_resource" "alb_1_ready" {
  provisioner "local-exec" {
    command = <<EOT
      while ! aws elbv2 describe-load-balancers --names "${var.alb_1_name}" --query 'LoadBalancers[0].State.Code' --output text | grep -q 'active'; do
        echo "Waiting for ${var.alb_1_name} to become active..."
        sleep 10
      done
      echo "${var.alb_1_name} is active"
    EOT
  }
}
