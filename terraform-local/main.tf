terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.16.0"
    }
  }
}

provider "docker" {
}

resource "docker_image" "keycloak-backup" {
  name = "isaiah-home/keycloak-backup"
  build {
    path = "../keycloak/backup"
  }
}

resource "docker_image" "keycloak-restore" {
  name = "isaiah-home/keycloak-restore"
  build {
    path = "../keycloak/restore"
  }
}
