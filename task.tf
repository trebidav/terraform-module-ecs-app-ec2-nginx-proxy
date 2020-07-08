resource "aws_ecs_task_definition" "application" {
  family = "${local.name}"

  execution_role_arn = "${aws_iam_role.ecs_task_execution.arn}"
  task_role_arn      = "${aws_iam_role.ecs_task_execution.arn}"

  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  container_definitions = "[${module.container_definition.json_map},${module.container_definition_nginx.json_map}]"

  volume {
    name = "nginx_config"

    docker_volume_configuration {
      scope         = "task"
      autoprovision = true
      driver        = "local"
    }
  }

  tags = "${local.tags}"
}
