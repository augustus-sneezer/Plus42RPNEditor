unit unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Plus42Comms

  ;

type

  { TForm3 }

  TForm3 = class( TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click( Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3. Button1Click( Sender: TObject);
var
  e: string;
begin
  memo1.text := CopyPlus42Printout(e).Text;
end;

end.

