variable "project_name" {
 description = "Nom du projet"
 type = string
 default = "tp-terraform"
}
variable "host_port" {
 description = "Port sur la machine hôte"
 type = number
 default = 8080
}
variable "redis_name" {
    description = "Nom du projet"
    type = string
    default = "redis:alpine"
}
variable "nginx_name" {
 description = "Nom du projet"
 type = string
 default = "nginx:alpine"
}