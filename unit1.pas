unit Unit1;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, CheckLst,
  StdCtrls, Menus, Plus42Comms, StrUtils
  ;

type

  { TForm4 }

  TForm4 = class( TForm)
    btnCopyPrintout: TButton;
    btnClearPrintout: TButton;
    Button1: TButton;
    btnToggleProgrammingMode2: TButton;
    Button2: TButton;
    cbCheckAll: TCheckBox;
    CheckListBox1: TCheckListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btnClearPrintoutClick( Sender: TObject);
    procedure btnCopyPrintoutClick( Sender: TObject);
    procedure btnToggleProgrammingMode2Click( Sender: TObject);
    procedure Button1Click( Sender: TObject);
    procedure Button2Click( Sender: TObject);
    procedure cbCheckAllChange( Sender: TObject);
  private

  public

  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }
function AllChecked(var aCheckListBox: TChecklistbox): Boolean;
var
  i: Integer;
begin
  for i := 0 to aCheckListBox.count - 1 do begin
    if not aCheckListBox.Checked[i] then
      Result := False
    else
      Result := True;

  end;
end ;


procedure TForm4. btnClearPrintoutClick( Sender: TObject);
var
  e: string;
begin
  ClearPrintout(e);
end;

procedure TForm4. btnCopyPrintoutClick( Sender: TObject);
var
  e, Aline, clrString, CLV, CLP: string;
  i: Integer;
  P: SizeInt;
begin
  CopyPlus42Printout(e);
  Memo1.Text := CopyPlus42Printout(e).Text;
  For i := 0 to Memo1.Lines.Count - 1 do begin
    Aline := Memo1.Lines[i];
    if aline.contains('LBL') then begin
      CLP := 'CLP ' + Copy(ALine,5, Maxint);
      CheckListBox1.Items.Add(CLP);
    end;
    if aline.Contains('=') then begin
      P := Pos('=', Aline) ;
      CLV := 'CLV "' + Copy(Aline, 1, P - 1 ) + '"';;
      CheckListBox1.Items.Add(CLV) ;

    end;

  end;
  cbCheckAll.enabled := true;
end;

procedure TForm4. btnToggleProgrammingMode2Click( Sender: TObject);
var
  e: string;
begin
  ToggleProgrammingMode(e);
end;

procedure TForm4. Button1Click( Sender: TObject);
var
  s: String;
  i: Integer;
begin
  memo1.Clear;
  memo1.Lines.Add('LBL "CLVP"');
  for i := 0 to CheckListBox1.Count - 1 do begin
    if CheckListBox1.Checked[i] then begin
      Memo1.Lines.Add(checkListBox1.Items[i]);
    end;


  end;
  memo1.Lines.Add('END' );

end;

procedure TForm4. Button2Click( Sender: TObject);
var
  e: string;
begin
  PasteToPlus42(Memo1.Lines, e)  ;
end;

procedure TForm4. cbCheckAllChange( Sender: TObject);
begin
  if AllChecked(CheckListBox1) then
   CheckListBox1.CheckAll(cbunchecked)
  else
    CheckListBox1.CheckAll(cbchecked);



end;

end.

