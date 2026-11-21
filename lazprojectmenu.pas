{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazProjectMenu;

{$warn 5023 off : no warning about unused units}
interface

uses
  uDelphiProjectMenu, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uDelphiProjectMenu', @uDelphiProjectMenu.Register);
end;

initialization
  RegisterPackage('LazProjectMenu', @Register);
end.
