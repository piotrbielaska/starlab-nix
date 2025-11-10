{ 
  config,
  ...
}:

{

  imports = [
    ./dawarich_db.nix
    ./dawarich_redis.nix
    ./dawarich_sidekiq.nix
  ];

  virtualisation.oci-containers.containers."dawarich" = {
    image = "freikin/dawarich:latest";
    environment = {
      "APPLICATION_HOSTS" = "localhost";
      "APPLICATION_PROTOCOL" = "http";
      "DATABASE_HOST" = "dawarich_db";
      "DATABASE_NAME" = "dawarich_db";
      "DATABASE_PASSWORD" = "$DAWARICH_PASSWORD"; # secured with agenix
      "DATABASE_USERNAME" = "dawarich_user";
      "MIN_MINUTES_SPENT_IN_CITY" = "60";
      "PROMETHEUS_EXPORTER_ENABLED" = "false";
      "PROMETHEUS_EXPORTER_HOST" = "0.0.0.0";
      "PROMETHEUS_EXPORTER_PORT" = "9394";
      "RAILS_ENV" = "development";
      "REDIS_URL" = "redis://dawarich_redis:6379";
      "SELF_HOSTED" = "true";
      "STORE_GEODATA" = "true";
      "TIME_ZONE" = "Europe/Warsaw";
    };
    volumes = [
      "dawarich_db:/dawarich_db_data:rw"
      "dawarich_public:/var/app/public:rw"
      "dawarich_storage:/var/app/storage:rw"
      "dawarich_watched:/var/app/tmp/imports/watched:rw"
    ];
    ports = [ "3000:3000/tcp"];
    cmd = [ "bin/rails" "server" "-p" "3000" "-b" "::" ];
    dependsOn = [
      "dawarich_db"
      "dawarich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cpus=0.5"
      "--entrypoint=[\"web-entrypoint.sh\"]"
      "--health-cmd=wget -qO - http://127.0.0.1:3000/api/v1/health | grep -q '\"status\"\\s*:\\s*\"ok\"'"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--memory=4294967296b"
      "--network-alias=dawarich"
      "--network=dawarich_network"
    ];
    environmentFiles = [
      config.age.secrets.secret_rust.path
    ];
  };

  system.activationScripts.createPodmanNetworkDawarich = lib.mkAfter ''
    if ! /run/current-system/sw/bin/podman network exists dawarich_network; then
      /run/current-system/sw/bin/podman network create dawarich_network
    fi 
  '';

}