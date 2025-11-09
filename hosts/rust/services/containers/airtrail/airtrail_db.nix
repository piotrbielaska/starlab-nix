{
  virtualisation.oci-containers.containers."airtrail_db" = {
    image = "postgres:16-alpine";
    ports = [ "5432:5432" ];
    environment = {
      "POSTGRES_AIRTRAIL_DB" = "airtrail_db";
      "POSTGRES_AIRTRAIL_USER" = "airtrail_user";
      "POSTGRES_AIRTRAIL_PASSWORD" = "airtrail_password"; # secure with age-nix!
    };
    volumes = [
      "/opt/containers/airtrail/airtrail_db:/var/lib/postgresql/data"
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
  };
}