{ 
  config,
  lib,
  pkgs,
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
      "APPLICATION_HOSTS" = "localhost https://location.bielaska.cloud";
      "APPLICATION_PROTOCOL" = "http";
      "DATABASE_HOST" = "dawarich_db";
      "DATABASE_NAME" = "dawarich_development";
      "DATABASE_PASSWORD" = "$DAWARICH_PASSWORD"; # secured with agenix
      "DATABASE_USERNAME" = "postgres";
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

  systemd.services."podman-dawarich" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
    };
    after = [
      "podman-network-dawarich.service"
      "podman-volume-dawarich_db.service"
      "podman-volume-dawarich_public.service"
      "podman-volume-dawarich_storage.service"
      "podman-volume-dawarich_watched.service"
    ];
    requires = [
      "podman-network-dawarich.service"
      "podman-volume-dawarich_db_.service"
      "podman-volume-dawarich_public.service"
      "podman-volume-dawarich_storage.service"
      "podman-volume-dawarich_watched.service"
    ];
    partOf = [
      "podman-compose-dawarich.target"
    ];
    wantedBy = [
      "podman-compose-dawarich.target"
    ];
  };

  # Networks
  systemd.services."podman-network-dawarich" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f dawarich"
      ;
    };
    script = ''
      podman network inspect dawarich || podman network create dawarich
    '';
    partOf = [ "podman-compose-dawarich.target" ];
    wantedBy = [ "podman-compose-dawarich.target" ];
  };

  # Volumes
  systemd.services."podman-volume-dawarich_db" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect dawarich_db || podman volume create dawarich_db
    '';
    partOf = [ "podman-compose-dawarich.target" ];
    wantedBy = [ "podman-compose-dawarich.target" ];
  };
  systemd.services."podman-volume-dawarich_public" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect dawarich_public || podman volume create dawarich_public
    '';
    partOf = [ "podman-compose-dawarich.target" ];
    wantedBy = [ "podman-compose-dawarich.target" ];
  };
  systemd.services."podman-volume-dawarich_shared" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect dawarich_shared || podman volume create dawarich_shared
    '';
    partOf = [ "podman-compose-dawarich.target" ];
    wantedBy = [ "podman-compose-dawarich.target" ];
  };
  systemd.services."podman-volume-dawarich_storage" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect dawarich_storage || podman volume create dawarich_storage
    '';
    partOf = [ "podman-compose-dawarich.target" ];
    wantedBy = [ "podman-compose-dawarich.target" ];
  };
  systemd.services."podman-volume-dawarich_watched" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect dawarich_watched || podman volume create dawarich_watched
    '';
    partOf = [ "podman-compose-dawarich.target" ];
    wantedBy = [ "podman-compose-dawarich.target" ];
  };

  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-dawarich" = {
    unitConfig = {
      Description = "Dawarich App Podman Compose Stack";
    };
    wantedBy = [ "multi-user.target" ];
  };

}