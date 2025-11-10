{ 
  config,
  lib,
  pkgs,
  ...
}:

{
  virtualisation.oci-containers.containers."dawarich_db" = {
    image = "postgres:16-alpine";
    ports = [ "5432:5432" ];
    environment = {
      "POSTGRES_DAWARICH_DB" = "dawarich_development";
      "POSTGRES_DAWARICH_USER" = "postgres";
      "POSTGRES_DAWARICH_PASSWORD" = "$DAWARICH_PASSWORD"; # secured with agenix
    };
    volumes = [
      "dawarich_db:/var/lib/postgresql/data"
      "dawarich_shared:/var/shared:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U dawarich_user -d dawarich_db"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_db"
      "--network=dawarich_network"
      "--shm-size=1073741824"
    ];
    environmentFiles = [
      config.age.secrets.secret_rust.path
    ];
  };

  systemd.services."podman-dawarich_db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-dawarich.service"
      "podman-volume-dawarich_db.service"
      "podman-volume-dawarich_shared.service"
    ];
    requires = [
      "podman-network-dawarich.service"
      "podman-volume-dawarich_db.service"
      "podman-volume-dawarich_shared.service"
    ];
    partOf = [
      "podman-compose-dawarich.target"
    ];
    wantedBy = [
      "podman-compose-dawarich.target"
    ];
  };

}