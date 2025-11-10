{ 
  pkgs,
  ...
}:

{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_16;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
      host all all 10.9.100.0/24 trust
      host all all 10.89.3.0/24 trust
    '';
    initialScript = pkgs.writeText "backend-initscript" ''
      CREATE USER dawarich WITH ENCRYPTED PASSWORD '$DAWARICH_PASSWORD';
      CREATE DATABASE dawarich_db;
      GRANT ALL PRIVILEGES ON DATABASE dawarich_db TO dawarich;
      ALTER DATABASE dawarich_db OWNER to dawarich;
    '';
  };

  services.postgresqlBackup = {
    enable = true;
    startAt = "03:10:00";
    databases = ["dawarich_db"];
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];

}