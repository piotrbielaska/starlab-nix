{ 
  config,
  ...
}:

{
  virtualisation.oci-containers.containers."dawarich_db" = {
    image = "postgres:16-alpine";
    ports = [ "5432:5432" ];
    environment = {
      "POSTGRES_DAWARICH_DB" = "dawarich_db";
      "POSTGRES_DAWARICH_USER" = "dawarich_user";
      "POSTGRES_DAWARICH_PASSWORD" = "$DAWARICH_PASSWORD"; # secured with agenix
    };
    volumes = [
      "/opt/containers/dawarich/dawarich_db:/var/lib/postgresql/data"
      "/opt/containers/dawarich/dawarich_shared:/var/shared:rw"
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
}