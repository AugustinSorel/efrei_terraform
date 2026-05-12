resource "docker_image" "nginx" {
 name = "${var.nginx_name}"
}
resource "docker_network" "app" {
 name = "app-network"
}
resource "docker_container" "web" {
 name = "${var.project_name}-web"
 image = docker_image.nginx.image_id
 ports {
 internal = 80
 external = var.host_port
 }
 networks_advanced {
 name = docker_network.app.name
 }
 log_opts = {
   "max-file" = "5"
   "max-size"  = "20m"
 }
 }

 resource "docker_image" "redis" {
 name = "${var.redis_name}"
}
resource "docker_container" "redis" {
 name = "${var.project_name}-redis"
 image = docker_image.redis.image_id
 networks_advanced {
 name = docker_network.app.name
 }
 log_opts = {
   "max-file" = "5"
   "max-size"  = "20m"
 }
 }