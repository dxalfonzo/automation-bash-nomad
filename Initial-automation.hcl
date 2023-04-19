job "automation" {
  datacenters = ["dc1"]

  group "automation" {

    task "automation" {
      driver = "docker"

      config {
        image = "dalfonzotucows/debian-w-nomad-aws:0.1"
        command = "bash"
        args = ["-c", "tail -f /dev/null" ]
      }
    
      resources {
        cpu    = 100
        memory = 200
      }

    }
  }
}