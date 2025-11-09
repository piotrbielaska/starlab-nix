{ 
  lib,
  ...
}:
{
  
  imports = [
    ./airtrail_db.nix # airtrail database container
  ];

  # starting airtrail app container
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
  };
  
  # checking if network exists and if no create it
  system.activationScripts.createPodmanNetworkAirTrail = lib.mkAfter ''
    if ! /run/current-system/sw/bin/podman network exists airtrail_network; then
      /run/current-system/sw/bin/podman network create airtrail_network
    fi 
  '';

}