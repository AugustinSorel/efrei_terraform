output "container_name" {
 value = docker_container.web.name
}
output "url" {
 value = "http://localhost:${docker_container.web.ports[0].external}"
}