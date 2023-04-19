job "automation" {
  datacenters = ["dc1"]

  group "automation" {

    task "automation" {
      driver = "docker"

      config {
        image = "dalfonzotucows/debian-w-nomad-aws:0.1"
        command = "bash"
        args = ["-c", "chmod -R /local/ && ./local/backup.sh" ]
      }
    
      resources {
        cpu    = 100
        memory = 200

      template {
              data = <<EOH       
#!/bin/bash
mkdir -p /var/log/example
now_datetime=$(date +"%Y%m%d%H%M%S")
logfile="/var/log/example/backup-example-${now_datetime}_log"
 
#aws 
mkdir -p ~/.aws
bucket=companyinc-example-dev
s3Key=supersecrets3key
s3Secret=supersecrets3secret
# Extact Database
echo "Connecting to example-db" | tee $logfile
allocation=$(nomad job allocs -verbose example-postgres | grep running | awk '{ print $1 }' | shuf -n 1)
echo "pg_dump --verbose  --port=5432 --username=team-example --format=t --encoding=UTF-8 --file dump-example.tar -n public example" > extract-db.sh
echo 'cat dump-example.tar | base64' >> extract-db.sh
nomad alloc exec -task example-postgres -i $allocation /bin/bash -s <./extract-db.sh > dump-example.tar
echo "Disconnected, file saved." | tee $logfile
 
echo "Connecting to s3 bucket" | tee $logfile
echo -e '[default]\noutput = json\nregion = us-east-1' > ~/.aws/config
echo -e "[default]\naws_access_key_id = ${s3Key}\naws_secret_access_key = ${s3Secret}"  > ~/.aws/credentials
echo "Sending  data to S3 bucket" | tee $logfile
cat dump-example.tar | aws s3 cp - s3://${bucket}/example-db_${now_datetime}_base64.tar
echo "Data sent to S3 bucket" | tee $logfile
EOH
        destination = "local/backup.sh"
        change_mode = "noop"
      }
    }
  }
}