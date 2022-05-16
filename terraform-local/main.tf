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

# --== Keycloak ==-- #
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

# --== WikiJs ==-- #
resource "docker_image" "wikijs-backup" {
  name = "isaiah-home/wikijs-backup"
  build {
    path = "../wikijs/backup"
  }
}
resource "docker_image" "wikijs-restore" {
  name = "isaiah-home/wikijs-restore"
  build {
    path = "../wikijs/restore"
  }
}
