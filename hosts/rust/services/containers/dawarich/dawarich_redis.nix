{
  virtualisation.oci-containers.containers."dawarich_redis" = {
    image = "redis:7.4-alpine";
    volumes = [
      "dawarich_shared:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"redis-cli\", \"--raw\", \"incr\", \"ping\"]"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_redis"
      "--network=dawarich_network"
      "--user=0:0"  # Add this line to run as root
    ];
  };

  systemd.services."podman-dawarich_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-dawarich.service"
      "podman-volume-dawarich_shared.service"
    ];
    requires = [
      "podman-network-dawarich_dawarich.service"
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