############################
# ECS Cluster + Task Definition + Service (Fargate)
############################
resource "aws_ecs_cluster" "app" {
  name = "${local.name_prefix}-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name_prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "erp-academico-backend"
      image     = var.ecr_image
      essential = true

      secrets = [
        {
          name      = "SPRING_DATASOURCE_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"
        },
        {
          name      = "APP_SYSTEM_BASE_URL"
          valueFrom = "${aws_secretsmanager_secret.system_config.arn}:system_base_url::"
        }
      ]

      portMappings = [{
        containerPort = var.container_port
        protocol      = "tcp"
      }]

      environment = concat(
        [
          {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://${aws_db_instance.mysql.address}:3306/${aws_db_instance.mysql.db_name}?zeroDateTimeBehavior=CONVERT_TO_NULL"
          }
        ],
        [for k, v in var.spring_env : { name = k, value = v }]
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "erp-academico-backend"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "erp-academico-backend"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
}

