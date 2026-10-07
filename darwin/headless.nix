{
  networking.wakeOnLan.enable = true;

  power = {
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
    sleep.computer = "never";
  };
}
