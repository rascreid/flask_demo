#cloud-config
package_update: true
package_upgrade: all

packages:
 - aws-cli

users:
 - name: ${username}
   gecos: ${username}
   primary_group: users
   no_user_group: true
   lock_password: false
   sudo: ALL=(ALL) NOPASSWD:ALL

runcmd:
 - amazon-linux-extras enable nginx1
 - yum install -y nginx
 - mkdir -p /etc/ecs
 - echo ECS_CLUSTER=${resource_prefix}-cluster >> /etc/ecs/ecs.config
