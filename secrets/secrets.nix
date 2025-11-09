let
  rust = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEYt29D2ktU4ub5cGHX1ND1xAIPCK8620T8a85lYuzB9";
in  {
  "secret_rust.age".publicKeys = [rust];
}