{ 
  lib,
  config,
  pkgs,
  ...
}:
{

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces = let
    matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
  in {
    "${matchAll}".allowedUDPPorts = [ 53 ];
  };

  imports = [
    ./airtrail_db.nix # airtrail database container 
  ];

  # starting airtrail app container as a service
  virtualisation.oci-containers.containers."airtrail" = {
    image = "johly/airtrail:latest";
    ports = [ 
      "3001:3000/tcp"
    ];
    dependsOn = [
      "airtrail_db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=airtrail"
      "--network=airtrail_network"
    ];
    environment = {
      "ORIGINS" = "http://10.9.100.94:3001 http://rust:3001 https://flights.bielaska.cloud";
      "DB_URL" = "postgres://atuser:atpassword@airtrail_db:5432/airtrail_user";
    };
  };

  # ensuring that dependencies are meet
  systemd.services."podman-airtrail" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-airtrail.service"
    ];
    requires = [
      "podman-network-airtrail.service"
    ];
    partOf = [
      "podman-compose-airtrail.target"
    ];
    wantedBy = [
      "podman-compose-airtrail.target"
    ];
  };
  
# Networks
  systemd.services."podman-network-airtrail" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f airtrail";
    };
    script = ''
      podman network inspect airtrail || podman network create airtrail
    '';
    partOf = [ "podman-compose-airtrail.target" ];
    wantedBy = [ "podman-compose-airtrail.target" ];
  };

  # Volumes created in /var/lib/containers/storage/volumes/
  systemd.services."podman-volume-airtrail_db" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect airtrail_db || podman volume create airtrail_db
    '';
    partOf = [ "podman-compose-airtrail.target" ];
    wantedBy = [ "podman-compose-airtrail.target" ];
  };

  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-airtrail" = {
    unitConfig = {
      Description = "AirTrail App Compose Container Stack";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # checking if network exists and if no create it
  # system.activationScripts.createPodmanNetworkAirTrail = lib.mkAfter ''
  #   if ! /run/current-system/sw/bin/podman network exists airtrail_network; then
  #     /run/current-system/sw/bin/podman network create airtrail_network
  #   fi 
  # '';

}