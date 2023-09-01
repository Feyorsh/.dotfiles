{
  description = "holy scripture of the cargo cult";

  outputs = { self }: {
    templates = {
      python = {
        path = ./python;
        description = "Beautiful is better than ugly";
      };
      zig = {
        path = ./zig;
        description = "All Your Codebase Are Belong To Us";
      };
      rust = {
        path = ./rust;
        description = "Rewrite it, but in Rust";
      };
    };
  };
}
