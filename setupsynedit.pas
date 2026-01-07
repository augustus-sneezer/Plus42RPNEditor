unit SetupSynedit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SynEdit, SynGutterBase, SynGutterLineNumber, Graphics;

procedure   SetupSyn(var SynEdit: TSynedit);

implementation

procedure SetupSyn(var SynEdit: TSynEdit);
var
  i, CalculatedGutterwidth: Integer;
  LineNumberPart: TSynGutterLineNumber;
  Found: Boolean;
  NewFont: TFont;
begin
  NewFont := TFont.Create;
  with SynEdit do
  begin
    NewFont.Name := 'DejaVu Sans Mono';
    NewFont.Size := 10;
    SynEdit.Font.Assign(NewFont);
    newFont.Free;

    // Basic gutter setup
    Gutter.Visible := True;
    Gutter.AutoSize := True;
    //CalculatedGutterwidth := SynEdit.Canvas.TextWidth('888888');
    //Gutter.Width := CalculatedGutterwidth ;



    // First remove any existing line number parts
    Found := False;
    for i := Gutter.Parts.Count - 1 downto 0 do
    begin
      if Gutter.Parts[i] is TSynGutterLineNumber then
      begin
        if Found then
          Gutter.Parts.Delete(i)  // Remove duplicate line number parts
        else
          Found := True;         // Keep the first one found
      end;
    end;

    // If no line number part exists, create one
    if not Found then
    begin
      LineNumberPart := TSynGutterLineNumber.Create(Gutter.Parts);
      Gutter.Parts.Add(LineNumberPart);
    end
    else
    begin
      // Find the remaining line number part
      for i := 0 to Gutter.Parts.Count - 1 do
      begin
        if Gutter.Parts[i] is TSynGutterLineNumber then
        begin
          LineNumberPart := TSynGutterLineNumber(Gutter.Parts[i]);
          Break;
        end;
      end;
    end;

    // Configure line numbers
    with LineNumberPart do
    begin
    RightOffset := 1;
      DigitCount := 3;                   // Show 3 digits (001, 010, 100)
      LeadingZeros := True;              // Show leading zeros
      ShowOnlyLineNumbersMultiplesOf := 1; // Show all line numbers
      MarkupInfo.Background := clNone;   // Transparent background
      MarkupInfo.Foreground := clBlack;  // Black text for line numbers
    end;
  end;
end;
end.
