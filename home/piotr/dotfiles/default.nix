{
  inputs,
  ...
}: 

{
  home.file.".config/nvim" = {
    source = "${inputs.dotfiles}/nvim ";
    recursive = true;
  };
  home.file.".config/MusicBrainz" = {
    source = "${inputs.dotfiles}/MusicBrainz";
    recursive = true;
  };
  home.file.".config/karabiner" = {
    source = "${inputs.dotfiles}/karabiner";
    recursive = true;
  };
}