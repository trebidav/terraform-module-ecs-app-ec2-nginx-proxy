module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.17.0"

  container_name  = "${var.name}"
  container_image = "${var.image == "" ? aws_ecr_repository.application.repository_url : var.image}"

  container_cpu                = "${var.cpu}"
  container_memory_reservation = "${var.memory}"
  container_memory             = "${var.memory_limit}"

  log_options = [
    {
      "awslogs-region"        = "${data.aws_region.current.name}"
      "awslogs-group"         = "${aws_cloudwatch_log_group.application_logs.name}"
      "awslogs-stream-prefix" = "ecs"
    },
  ]

  mount_points = [
    {
      containerPath = "/etc/nginx/conf.d/"
      sourceVolume  = "nginx_config"
    },
  ]

  environment = ["${var.environment}"]
  secrets     = ["${var.secrets}"]
}

module "container_definition_nginx" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.17.0"

  container_name  = "nginx_proxy"
  container_image = "nginx:latest"

  container_cpu                = "64"
  container_memory_reservation = "64"
  container_memory             = "0"

  port_mappings = [
    {
      containerPort = "${var.port}"
      hostPort      = 0
      protocol      = "tcp"
    },
  ]

  volumes_from = [
    {
      "sourceContainer" = "${var.name}"
      "readOnly"        = "true"
    },
  ]

  links = [
    "${var.name}:django",
  ]

  log_options = [
    {
      "awslogs-region"        = "${data.aws_region.current.name}"
      "awslogs-group"         = "${aws_cloudwatch_log_group.application_logs.name}"
      "awslogs-stream-prefix" = "ecs"
    },
  ]
}
