{ 
  config,
  ...
}:

{
  
  virtualisation.oci-containers.containers."dawarich_sidekiq" = {
    image = "freikin/dawarich:latest";
    environment = {
      "APPLICATION_HOSTS" = "localhost";
      "APPLICATION_PROTOCOL" = "http";
      "DATABASE_HOST" = "dawarich_db";
      "DATABASE_NAME" = "dawarich_db";
      "DATABASE_PASSWORD" = "$DAWARICH_PASSWORD"; # secured with agenix
      "DATABASE_USERNAME" = "dawarich_user";
      "PROMETHEUS_EXPORTER_ENABLED" = "false";
      "PROMETHEUS_EXPORTER_HOST" = "dawarich";
      "PROMETHEUS_EXPORTER_PORT" = "9394";
      "RAILS_ENV" = "development";
      "REDIS_URL" = "redis://dawarich_redis:6379";
      "SELF_HOSTED" = "true";
      "STORE_GEODATA" = "true";
    };
    volumes = [
      "/opt/containers/dawarich/dawarich_public:/var/app/public:rw"
      "/opt/containers/dawarich/dawarich_storage:/var/app/storage:rw"
      "/opt/containers/dawarich/dawarich_watched:/var/app/tmp/imports/watched:rw"
    ];
    cmd = [ "sidekiq" ];
    dependsOn = [
      "dawarich"
      "dawarich_db"
      "dawarich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--entrypoint=[\"sidekiq-entrypoint.sh\"]"
      "--health-cmd=pgrep -f sidekiq"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_sidekiq"
      "--network=dawarich_network"
    ];    
    environmentFiles = [
      config.age.secrets.secret_rust.path
    ];
  };
  
}