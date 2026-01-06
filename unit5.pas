unit unit5;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Plus42Comms;

type

  { TForm2 }

  TForm2 = class( TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click( Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2. Button1Click( Sender: TObject);
var
  e: string;
begin
  Memo1.text := CopyFromPlus42Printout(e).Text;
end;

end.

