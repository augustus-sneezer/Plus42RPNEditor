unit rpneditoru;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  SynEdit, SynEditHighlighter, SynEditMarkupHighAll, SynGutterBase,
  SynGutterLineNumber, SynHighlighterAny, SynEditMiscClasses,
  SynEditMarkupSpecialLine, customHighlighter, SetupSynedit, LCLType, StdCtrls,
  Menus, LazUTF8, StrUtils, Plus42Comms, FileUtil, SynEditSearch,
  SynEditTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnProgrammingMode: TButton;
    btnImportFromPlus42: TButton;
    btnExportToPlus42: TButton;
    FindDialog1: TFindDialog;
    FontDialog1: TFontDialog;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    FileStuff: TMenuItem;
    Load: TMenuItem;
    Find: TMenuItem;
    FindText: TMenuItem;
    Replace: TMenuItem;
    ReplaceDialog1: TReplaceDialog;
    Save: TMenuItem;
    DefaultDir: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SynAnySyn1: TSynAnySyn;
    SynEdit1: TSynEdit;
    Timer1: TTimer;
    procedure btnExportToPlus42Click(Sender: TObject);
    procedure btnImportFromPlus42Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnProgrammingModeClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DefaultDirClick(Sender: TObject);
    procedure FindTextClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure LoadClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure SplitaLine(ALine: string);
    procedure splitaline2(APos: TPoint);
    procedure splitaline3(aline: string; APos: TPoint);
    procedure replaceline(aline: String; startPoint, EndPoint: TPoint);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);

  private
    FSelectedDirectory: String;
    FHighlighter: TSynEditHighlighter;
    FLineIndex,
    FCarX,
    FCarY: integer;
    FCurrentLine: string;
    Alphacommands,
    LocalLabels,
    Arithmeticals : TStringDynArray;

    procedure FindNextOccurrence;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function myTimestamp: String;
begin
  Result := FormatDateTime('__yyyy-mm-dd_hh-nn-ss', Now);
end;

procedure TForm1.ReplaceDialog1Find(Sender: TObject);
var
  Options: TSynSearchOptions;
begin
  Options := [ssoFindContinue];
  if frMatchCase in ReplaceDialog1.Options then Include(Options, ssoMatchCase);
  if frWholeWord in ReplaceDialog1.Options then Include(Options, ssoWholeWord);
  if not (frDown in ReplaceDialog1.Options) then Include(Options, ssoBackwards);

  if SynEdit1.SearchReplace(ReplaceDialog1.FindText, ReplaceDialog1.FindText, Options) = 0 then
    ShowMessage('Text not found.');
end;

procedure TForm1.ReplaceDialog1Replace(Sender: TObject);
var
  Options: TSynSearchOptions;
begin
  Options := [ssoFindContinue];
  if frMatchCase in ReplaceDialog1.Options then Include(Options, ssoMatchCase);
  if frWholeWord in ReplaceDialog1.Options then Include(Options, ssoWholeWord);

  if frReplaceAll in ReplaceDialog1.Options then
  begin
    Include(Options, ssoReplaceAll);
    SynEdit1.SearchReplace(ReplaceDialog1.FindText, ReplaceDialog1.ReplaceText, Options);
  end
  else
  begin
    Include(Options, ssoReplace);
    if SynEdit1.SearchReplace(ReplaceDialog1.FindText, ReplaceDialog1.ReplaceText, Options) = 0 then
      ShowMessage('No match found to replace.');
  end;
end;

procedure TForm1.FindDialog1Find(Sender: TObject);
var
  Options: TSynSearchOptions;
begin
  Options := [ssoFindContinue];
  if frMatchCase in FindDialog1.Options then Include(Options, ssoMatchCase);
  if frWholeWord in FindDialog1.Options then Include(Options, ssoWholeWord);
  if not (frDown in FindDialog1.Options) then Include(Options, ssoBackwards);

  if SynEdit1.SearchReplace(FindDialog1.FindText, FindDialog1.FindText, Options) = 0 then
    ShowMessage('Text "' + FindDialog1.FindText + '" not found.')
  else
    SynEdit1.SetFocus;
end;

procedure TForm1.FindNextOccurrence;
var
  Options: TSynSearchOptions;
begin
  Options := [ssoFindContinue];
  if frMatchCase in ReplaceDialog1.Options then Include(Options, ssoMatchCase);
  if frWholeWord in ReplaceDialog1.Options then Include(Options, ssoWholeWord);

  if SynEdit1.SearchReplace(ReplaceDialog1.FindText, ReplaceDialog1.FindText, Options) = 0 then
    SynEdit1.CaretXY := Point(1, 1);
end;

procedure TForm1.replaceline(aline: String; startPoint, EndPoint: TPoint);
begin
  SynEdit1.BeginUndoBlock;
  try
    SynEdit1.TextBetweenPoints[startPoint, EndPoint] := aline;
  finally
    SynEdit1.EndUndoBlock;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FSelectedDirectory := GetCurrentDir;
  SetupSyn(SynEdit1);
  FHighlighter := TSynEditHighlighter.Create(SynEdit1);
  FLineIndex := 0;
  Alphacommands:= SplitString('CLV CLP XEQ GTO AVIEW VIEW STO STO+ STO- STO* ' +
                  'STO/ RCL RCL+ RCL- RCL* MVAR RCL/ LBL STO INPUT', ' ');

  LocalLabels := splitstring('A B C D E F G H I J a b c d e', ' ');
  Arithmeticals := SplitString('+ - / *', ' ');

  if FileExists(FSelectedDirectory + '\Plus42.txt') then
     SynEdit1.Lines.LoadFromFile(FSelectedDirectory + '\Plus42.txt');
end;

procedure TForm1.ListBox1Click(Sender : TObject);
var
  item : String;
  StartPoint, EndPoint: TPoint;
begin
   if ListBox1.ItemIndex <> -1 then
   begin
     item := ListBox1.Items[ListBox1.ItemIndex];
     case item of
         'Y=0?': item := '0=? ST Y';
         'Y≠0?': item := '0≠? ST Y';
         'Y<0?': item := '0>? ST Y';
         'Y>0?': item := '0<? ST Y';
         'Y≤0?': item := '0≥? ST Y';
         'Y≥0?': item := '0≤? ST Y';
     end;

     StartPoint := Point(1, FCarY);
     EndPoint := Point(UTF8Length(FCurrentLine) + 1, FCarY);

     SynEdit1.BeginUndoBlock;
     try
       SynEdit1.TextBetweenPoints[StartPoint, EndPoint] := item + LineEnding + FCurrentLine;
       SynEdit1.CaretXY := Point(1, FCarY + 1);
     finally
       SynEdit1.EndUndoBlock;
     end;
     SynEdit1.SetFocus;
   end;
end;

procedure TForm1.LoadClick(Sender: TObject);
begin
  with OpenDialog1 do begin
    InitialDir := FSelectedDirectory;
    if Execute then SynEdit1.Lines.LoadFromFile(FileName);
  end;
end;

procedure TForm1.SaveClick(Sender: TObject);
begin
  with SaveDialog1 do begin
    InitialDir := FSelectedDirectory;
    if Execute then SynEdit1.Lines.SaveToFile(FileName);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  FontDialog1.Font := SynEdit1.Font;
  if FontDialog1.Execute then SynEdit1.Font.Assign(FontDialog1.Font);
end;

procedure TForm1.btnImportFromPlus42Click(Sender: TObject);
var e: string;
begin
  SynEdit1.Text := CopyFromPlus42(e).Text;
end;

procedure TForm1.btnExportToPlus42Click(Sender: TObject);
var e: string;
begin
  PasteToPlus42(SynEdit1.Lines, e);
end;

procedure TForm1.btnProgrammingModeClick(Sender: TObject);
var e: string;
begin
  ToggleProgrammingMode(e);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if ReplaceDialog1.Execute then ReplaceDialog1Replace(Sender);
end;

procedure TForm1.DefaultDirClick(Sender: TObject);
begin
  with SelectDirectoryDialog1 do begin
    if Execute then FSelectedDirectory := FileName;
  end;
end;

procedure TForm1.FindTextClick(Sender: TObject);
begin
  FindDialog1.Execute;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SynEdit1.Lines.SaveToFile(FSelectedDirectory + '\Plus42.txt');
end;

procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  aline, A, B, C, D, ThisString: String;
  difference, Laline: PtrInt;
  i: Integer;
  StartOfLine, Midline, EndOfLine: Boolean;
  AB, ABCD: TStringDynArray;
  StartPoint, EndPoint: TPoint;
  endchar: String;
  dummy: Double;
  Dummy2: Longint;
begin
  if Key = 13 then begin
    Key := 0;
    aline := Synedit1.Lines[FLineIndex];
    if IsEmptyStr(aline, [' ']) then exit;

    Laline := UTF8Length(aline);
    difference := FCarX - Laline - 2;
    if difference > 0 then begin
      for i := 0 to difference do aline := aline + ' ';
    end;

    StartOfLine := FCarX = 1;
    Midline := (FCarX > 1) and (FCarX < Laline + 1);
    EndOfLine := FCarX > Laline;

    if StartOfLine then begin
      SynEdit1.BeginUndoBlock;
      try
        SynEdit1.TextBetweenPoints[Point(1, FCarY), Point(UTF8Length(aline) + 1, FCarY)] := LineEnding + aline;
        SynEdit1.CaretXY := Point(1, FCarY + 1);
      finally
        SynEdit1.EndUndoBlock;
      end;
    end
    else if Midline then begin
      SplitaLine2(Point(FCarX, FCarY));
    end
    else if EndOfLine then begin
      ABCD := SplitString(aline, ' ');
      A := ''; B := ''; C := ''; D := '';
      if Length(ABCD) > 0 then A := ABCD[0];
      if Length(ABCD) > 1 then B := ABCD[1];
      if Length(ABCD) > 2 then C := ABCD[2];
      if Length(ABCD) > 3 then D := ABCD[3];

      case Length(ABCD) of
        1: begin
             if UTF8Length(A) = 1 then begin
               StartPoint := Point(1, FCarY);
               EndPoint := Point(Laline + 1, FCarY);
               replaceline(aline + LineEnding, StartPoint, EndPoint);
               SynEdit1.CaretXY := Point(1, FCarY + 1);
             end
             else begin
               endchar := UTF8Copy(aline, UTF8Length(aline), 1);
               if IndexStr(endchar, Arithmeticals) >= 0 then begin
                 AB := SplitString(aline, endchar);
                 if TryStrToFloat(AB[0], dummy) then
                   splitaline2(Point(FCarX - 1, FCarY))
                 else begin
                   StartPoint := Point(1, FCarY);
                   EndPoint := Point(UTF8Length(aline) + 1, FCarY);
                   replaceline(aline + LineEnding, StartPoint, EndPoint);
                   SynEdit1.CaretXY := Point(1, FCarY + 1);
                 end;
               end
               else begin
                 StartPoint := Point(1, FCarY);
                 EndPoint := Point(1, FCarY + 1);
                 replaceline(aline + LineEnding + LineEnding, StartPoint, endPoint);
                 SynEdit1.CaretXY := Point(1, FCarY + 1);
               end;
             end;
           end;
        2: begin
             ThisString := aline;
             if IndexStr(A, Alphacommands) >= 0 then begin
                if (IndexStr(B, LocalLabels) >= 0) or TryStrToInt(B, Dummy2) then
                   ThisString := A + ' ' + B
                else
                   ThisString := A + ' ' + '"' + StringReplace(B, '"', '', [rfReplaceAll]) + '"';
             end;
             StartPoint := Point(1, FCarY);
             EndPoint := Point(UTF8Length(aline) + 1, FCarY);
             replaceline(ThisString + LineEnding, StartPoint, EndPoint);
             SynEdit1.CaretXY := Point(1, FCarY + 1);
           end;
        3,4,5: begin
             StartPoint := Point(1, FCarY);
             EndPoint := Point(UTF8Length(aline) + 1, FCarY);
             replaceline(aline + LineEnding, StartPoint, EndPoint);
             SynEdit1.CaretXY := Point(1, FCarY + 1);
           end;
      end;
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  FLineIndex := SynEdit1.CaretY - 1;
  FCurrentLine := SynEdit1.Lines[FLineIndex];
  FCarX := SynEdit1.CaretX;
  FCarY := SynEdit1.CaretY;
end;

procedure TForm1.SplitaLine(ALine: string);
var
  PartBefore, PartAfter: string;
  InsertPos: TPoint;
begin
  PartBefore := UTF8Copy(ALine, 1, FCarX - 1);
  PartAfter := UTF8Copy(ALine, FCarX, MaxInt);
  SynEdit1.BeginUndoBlock;
  try
    SynEdit1.TextBetweenPoints[Point(1, FCarY), Point(UTF8Length(ALine) + 1, FCarY)] := PartBefore + LineEnding;
    InsertPos := Point(1, FCarY + 1);
    SynEdit1.TextBetweenPoints[InsertPos, InsertPos] := PartAfter;
    SynEdit1.CaretXY := Point(1, FCarY + 1);
  finally
    SynEdit1.EndUndoBlock;
  end;
end;

procedure TForm1.splitaline2(APos: TPoint);
var
  A, B: string;
  StartPoint, EndPoint: TPoint;
begin
  A := UTF8Copy(FCurrentLine, 1, APos.X - 1);
  B := UTF8Copy(FCurrentLine, APos.X, MaxInt);
  StartPoint := Point(1, FCarY);
  EndPoint := Point(UTF8Length(FCurrentLine) + 1, FCarY);
  SynEdit1.BeginUndoBlock;
  try
    SynEdit1.TextBetweenPoints[StartPoint, EndPoint] := A + LineEnding + B + LineEnding;
    SynEdit1.CaretXY := Point(1, FCarY + 2);
  finally
    SynEdit1.EndUndoBlock;
  end;
end;

procedure TForm1.splitaline3(aline: string; APos: TPoint);
var
  A, B: string;
  StartPoint, EndPoint: TPoint;
begin
  A := UTF8Copy(aline, 1, APos.X - 1);
  B := UTF8Copy(aline, APos.X, MaxInt);
  StartPoint := Point(1, FCarY);
  EndPoint := Point(UTF8Length(aline) + 1, FCarY);
  SynEdit1.BeginUndoBlock;
  try
    SynEdit1.TextBetweenPoints[StartPoint, EndPoint] := A + LineEnding + B;
    SynEdit1.CaretXY := Point(1, FCarY + 1);
  finally
    SynEdit1.EndUndoBlock;
  end;
end;

end.
