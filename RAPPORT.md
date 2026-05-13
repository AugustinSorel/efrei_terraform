# TP DevOps — Terraform & Providers locaux

---

## Partie 1 — Provider Docker

**Objectif :** déployer un serveur nginx et un cache Redis en local via le provider `kreuzwerker/docker`, sans passer par un cloud.

### Fichiers

```
tp-docker/
├── versions.tf   # Provider et version Terraform
├── main.tf       # Ressources Docker
├── variables.tf  # Variables
└── outputs.tf    # Sorties
```

### Provider

```hcl
provider "docker" {}
```

Pas de configuration nécessaire — le provider se connecte automatiquement au daemon Docker local.

### Variables

| Variable | Défaut | Description |
|---|---|---|
| `project_name` | `"tp-terraform"` | Préfixe des noms de conteneurs |
| `host_port` | `8080` | Port exposé sur l'hôte pour nginx |
| `nginx_name` | `"nginx:alpine"` | Image nginx |
| `redis_name` | `"redis:alpine"` | Image Redis |

### Ressources

```hcl
resource "docker_network" "app" {
  name = "app-network"
}

resource "docker_image" "nginx" { name = var.nginx_name }
resource "docker_container" "web" {
  name  = "${var.project_name}-web"
  image = docker_image.nginx.image_id
  ports { internal = 80; external = var.host_port }
  networks_advanced { name = docker_network.app.name }
  log_opts = { "max-file" = "5"; "max-size" = "20m" }
}

resource "docker_image" "redis" { name = var.redis_name }
resource "docker_container" "redis" {
  name  = "${var.project_name}-redis"
  image = docker_image.redis.image_id
  networks_advanced { name = docker_network.app.name }
  log_opts = { "max-file" = "5"; "max-size" = "20m" }
}
```

Les deux conteneurs communiquent via le réseau `app-network`. Redis n'expose aucun port vers l'hôte — seul nginx est accessible depuis l'extérieur.

### Outputs

| Output | Valeur |
|---|---|
| `container_name` | `"tp-terraform-web"` |
| `url` | `"http://localhost:8080"` |

### Commandes

```bash
cd tp-docker
terraform init    # télécharge le provider
terraform plan    # prévisualise
terraform apply   # déploie
docker ps         # vérifie les conteneurs
terraform destroy # supprime tout
```

---

## Partie 2 — Provider GitHub

**Objectif :** gérer des ressources GitHub as code — dépôts, protection de branche et secrets Actions — via le provider `integrations/github`.

### Fichiers

```
tp-github/
├── versions.tf       # Provider et version Terraform
├── main.tf           # Ressources GitHub
├── variables.tf      # Variables
├── outputs.tf        # Sorties
└── terraform.tfvars  # Valeurs non sensibles
```

### Provider

```hcl
provider "github" {
  token = var.github_token  # sensitive = true
}
```

L'authentification se fait par **Personal Access Token (PAT)**. Le token est marqué `sensitive` : Terraform ne l'affiche jamais dans les logs. Il doit être passé via une variable d'environnement ou un fichier `.tfvars` non commité.

### Variables

| Variable | Sensible | Description |
|---|---|---|
| `github_token` | Oui | PAT GitHub |
| `project_name` | Non | Préfixe des noms de dépôts (`"tp-terraform-demo"`) |
| `db_url` | Oui | URL de base de données injectée comme secret Actions |

### Ressources

**2 dépôts publics**

```hcl
resource "github_repository" "app" {
  name       = "${var.project_name}-demo"
  visibility = "public"
  has_issues = true
  has_wiki   = true
  auto_init  = true
  topics     = ["terraform", "devops"]
}

resource "github_repository" "app2" {
  name       = "${var.project_name}-demo2"
  visibility = "public"
  has_issues = true
  has_wiki   = false  # différence avec app
  auto_init  = true
  topics     = ["terraform", "devops"]
}
```

**Protection de la branche `main`**

```hcl
resource "github_branch_protection" "main" {
  repository_id = github_repository.app.node_id
  pattern       = "main"
  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
  }
}
```

Règles actives : merge uniquement via PR, 1 approbation requise, reviews invalidées si de nouveaux commits sont poussés.

**Secret GitHub Actions**

```hcl
resource "github_actions_secret" "db_url" {
  repository      = github_repository.app.name
  secret_name     = "DATABASE_URL"
  plaintext_value = var.db_url
}
```

### Outputs

| Output | Valeur |
|---|---|
| `repo_url` | https://github.com/AugustinSorel/tp-terraform-demo-demo |
| `repo2_url` | https://github.com/AugustinSorel/tp-terraform-demo-demo2 |
| `clone_url` | `git@github.com:AugustinSorel/tp-terraform-demo-demo.git` |

### Commandes

```bash
cd tp-github
export TF_VAR_github_token="ghp_xxxxxxxxxxxxxxxxxxxx"
terraform init    # télécharge le provider
terraform plan    # prévisualise
terraform apply   # crée les dépôts, la protection et le secret
terraform output  # affiche les URLs
terraform destroy # supprime tout
```

### Résultats

Les deux dépôts ont été créés avec succès le 12 mai 2026 :

| Dépôt | Wiki | État |
|---|---|---|
| `tp-terraform-demo-demo` | Oui | Actif |
| `tp-terraform-demo-demo2` | Non | Actif |

Protection de branche et secret `DATABASE_URL` confirmés dans le `tfstate`.

---

*Rapport généré le 13 mai 2026*
