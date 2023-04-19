job "example-postgres" {
  datacenters = ["dc1"]

  group "example-postgres" {

    network {
      
      port "db" {
        static = 5432
      }
    }

    task "example-postgres" {
      driver = "docker"

      config {
        image = "postgres:12.10"
        ports = ["db"]
      }

# Secure your passwords, this is not best practice but good for testing
    env {
        POSTGRES_USER="CHANGEME-USER"
        POSTGRES_PASSWORD="PROTECTME-PASSWORD"
    }
    
      resources {
        cpu    = 100
        memory = 200
      }

    }
  }
}