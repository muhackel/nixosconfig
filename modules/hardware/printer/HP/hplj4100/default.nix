{ config, lib, pkgs, ... }:
let

in
{
  hardware.printers = {
    ensurePrinters = [
      {
        name = "HPLaserJet4100";
        location = "Home";
        deviceUri = "socket://hplj4100.local";
        model = "/HP/hp-laserjet_4100_series-ps.ppd.gz";
        ppdOptions = {
          PageSize = "A4";  
          HPOption_Duplexer = "True"; 
          InstalledMemory = "32MB"; 
        };
      }
    ];
    ensureDefaultPrinter = "HPLaserJet4100";
  };
}