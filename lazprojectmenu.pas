unit LazProjectMenu;

{$warn 5023 off : no warning about unused units}
interface

uses
  uProjectMenu, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uProjectMenu', @uProjectMenu.Register);
end;

initialization
  RegisterPackage('LazProjectMenu', @Register);
end.
