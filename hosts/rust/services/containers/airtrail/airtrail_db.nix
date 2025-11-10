{ 
  config,
  lib,
  pkgs,
  ...
}:

{
  virtualisation.oci-containers.containers."airtrail_db" = {
    image = "postgres:16-alpine";
    ports = [ "5432:5432" ];
    environment = {
      "POSTGRES_AIRTRAIL_DB" = "airtrail_db";
      "POSTGRES_AIRTRAIL_USER" = "airtrail_user";
      "POSTGRES_AIRTRAIL_PASSWORD" = "$AIRTRAIL_PASSWORD"; # secured with agenix
    };
    volumes = [
      "airtrail_db:/var/lib/postgresql/data"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U airtrail_user -d airtrail_db"
      "--health-interval=5s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=airtrail_db"
      "--network=airtrail_network"
    ];
    environmentFiles = [
      config.age.secrets.secret_rust.path
    ];
  };

  systemd.services."podman-airtrail_db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-airtrail.service"
      "podman-volume-airtrail_db.service"
    ];
    requires = [
      "podman-network-airtrail.service"
      "podman-volume-airtrail_db.service"
    ];
    partOf = [
      "podman-compose-airtrail.target"
    ];
    wantedBy = [
      "podman-compose-airtrail.target"
    ];
  };

}