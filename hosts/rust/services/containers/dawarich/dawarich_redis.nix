{
  virtualisation.oci-containers.containers."dawarich_redis" = {
    image = "redis:7.4-alpine";
    volumes = [
      "/opt/containers/dawarich/dawarich_shared:/data:rw"
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
}