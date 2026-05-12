resource "docker_image" "nginx" {
 name = "nginx:alpine"
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
 }