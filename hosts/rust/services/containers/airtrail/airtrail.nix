{


  imports = [
    ./airtrail_db.nix
  ];

  virtualisation.oci-containers.containers."airtrail" = {
    image = "johly/airtrail:latest";
    ports = [ "3001:3000/tcp"];
    dependsOn = [
      "airtrail_db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=airtrail"
      "--network=airtrail_network"
    ];
  };
  
}