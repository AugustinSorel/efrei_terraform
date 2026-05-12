output "repo_url" {
  description = "URL du dépôt GitHub principal"
  value       = github_repository.app.html_url
}

output "repo2_url" {
  description = "URL du second dépôt GitHub"
  value       = github_repository.app2.html_url
}

output "clone_url" {
  description = "URL de clonage SSH du dépôt principal"
  value       = github_repository.app.ssh_clone_url
}
