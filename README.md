# rails-on-ecs-by-terraform

## Docker

```sh
$ docker-compose up --no-start
```

## Dockerにログオン

```
$ docker-compose run terraform sh

$ cd /usr/src/terraform/envs/development/ # productionの場合は cd /usr/src/terraform/envs/production
# ワークスペースの初期化
$ terraform init
# 設定確認
$ terraform plan
# 設定内容反映
$ terraform apply
```

## Features

- [x] Network
- [x] ECS/Fargate
- [x] ECS Auto Scaling
- [x] ALB
- [x] Database
- [ ] Deployment
- [ ] Batch
