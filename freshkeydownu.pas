unit freshkeydownu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  SynEdit, SynEditHighlighter, SynEditMarkupHighAll, SynGutterBase,
  SynGutterLineNumber, SynHighlighterAny, SynEditMiscClasses,
  SynEditMarkupSpecialLine, customHighlighter, SetupSynedit, LCLType, StdCtrls,
  Menus, LazUTF8, StrUtils, Plus42Comms, FileUtil, unit3, unit1, SynEditSearch ,
  SynEditTypes
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnProgrammingMode: TButton;
    btnImportFromPlus42: TButton;
    btnExportToPlus42: TButton;
    Button1: TButton;
    Button2: TButton;
    FindDialog1: TFindDialog;
    FontDialog1: TFontDialog;
    ListBox1: TListBox;
    MainMenu1: TMainMenu;
    FileStuff: TMenuItem;
    Load: TMenuItem;
    Find: TMenuItem;
    FindText: TMenuItem;
    Replace: TMenuItem;
    Printout: TMenuItem;
    clearprintout: TMenuItem;
    copyprintout: TMenuItem;
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
    procedure btnExportToPlus42Click( Sender: TObject);
    procedure btnImportFromPlus42Click( Sender: TObject);
    procedure Button1Click( Sender: TObject);
    procedure btnProgrammingModeClick( Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure copyprintoutClick( Sender: TObject);
    procedure DefaultDirClick( Sender: TObject);
    procedure FindTextClick(Sender: TObject);
    procedure FormClose( Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click( Sender: TObject);
    procedure LoadClick( Sender: TObject);
    procedure PrintoutClick( Sender: TObject);
    procedure SaveClick( Sender: TObject);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure Timer1Timer(Sender: TObject);
    procedure SplitaLine(ALine: string);
    procedure splitaline2( APos: TPoint);
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
                                                             // Menu item click - just shows the dialog


// AUTOMATICALLY called when user clicks "Find Next" in Replace dialog
procedure TForm1.ReplaceDialog1Find(Sender: TObject);
var
  Options: TSynSearchOptions;
begin
  Options := [ssoFindContinue];

  if frMatchCase in ReplaceDialog1.Options then
    Include(Options, ssoMatchCase);

  if frWholeWord in ReplaceDialog1.Options then
    Include(Options, ssoWholeWord);

  if not (frDown in ReplaceDialog1.Options) then
    Include(Options, ssoBackwards);

  SynEdit1.SelText := '';  // Clear any selection

  if SynEdit1.SearchReplace(ReplaceDialog1.FindText, '', Options) = 0 then
  begin
    ShowMessage('Text "' + ReplaceDialog1.FindText + '" not found.');
  end
  else
  begin
    SynEdit1.SelectWord;  // Highlight found text
  end;
end;

// AUTOMATICALLY called when user clicks "Replace" or "Replace All"
procedure TForm1.ReplaceDialog1Replace(Sender: TObject);
var
  Options: TSynSearchOptions;
  ReplaceCount: Integer;
begin
  // frReplaceAll is ONLY true if user clicked "Replace All" button
  if frReplaceAll in ReplaceDialog1.Options then
  begin
    // User explicitly clicked "Replace All"
    Options := [ssoReplace, ssoReplaceAll];
    if frMatchCase in ReplaceDialog1.Options then
      Include(Options, ssoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(Options, ssoWholeWord);

    ReplaceCount := SynEdit1.SearchReplace(
      ReplaceDialog1.FindText,
      ReplaceDialog1.ReplaceText,
      Options
    );

    ShowMessage(IntToStr(ReplaceCount) + ' replacements made.');
    // Dialog closes after Replace All
  end
  else
  begin
    // User explicitly clicked "Replace" (single replace)
    // Replace whatever is currently selected
    SynEdit1.SelText := ReplaceDialog1.ReplaceText;
    // Dialog stays open for next user action
  end;
end;
procedure TForm1.FindDialog1Find(Sender: TObject);
var
  Options: TSynSearchOptions;
  FoundPos: Integer;
begin
  // Clear ONLY the current selection (if any), not all text
  SynEdit1.SelText := '';

  // Set search options
  Options := [ssoFindContinue];

  if frMatchCase in FindDialog1.Options then
    Include(Options, ssoMatchCase);

  if frWholeWord in FindDialog1.Options then
    Include(Options, ssoWholeWord);

  if not (frDown in FindDialog1.Options) then
    Include(Options, ssoBackwards);

  // Perform the search
  FoundPos := SynEdit1.SearchReplace(FindDialog1.FindText, '', Options);

  if FoundPos = 0 then
  begin
    // Text not found - wrap to beginning
    //ShowMessage('Text "' + FindDialog1.FindText + '" not found.');
    SynEdit1.CaretXY := Point(1, 1);
  end;
end;

procedure TForm1.FindNextOccurrence;
var
  Options: TSynSearchOptions;
  FoundCount: Integer;
begin
  Options := [];
  if frMatchCase in ReplaceDialog1.Options then
    Include(Options, ssoMatchCase);
  if frWholeWord in ReplaceDialog1.Options then
    Include(Options, ssoWholeWord);

  FoundCount := SynEdit1.SearchReplace(ReplaceDialog1.FindText, '',
      Options + [ssoFindContinue]);

  if FoundCount = 0 then
  begin
    //ShowMessage('Text not found');
     //Reset to start position for next search
    SynEdit1.CaretXY := Point(1, 1);
  end;
end;


procedure TForm1. replaceline( aline: String; startPoint, EndPoint: TPoint);
begin
  synedit1.TextBetweenPoints[startPoint, EndPoint] := aline;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FSelectedDirectory := GetCurrentDir;
  SetupSyn(SynEdit1);
  FHighlighter := TSynEditHighlighter.Create(SynEdit1);
  //FHighlighter.AddLineWithFocus('LBL "');
  FLineIndex := 0;
  Alphacommands:= SplitString('CLV CLP XEQ GTO AVIEW VIEW STO STO+ STO- STO* ' +
                  'STO/ RCL RCL+ RCL- RCL* MVAR RCL/ LBL STO INPUT', ' ');

  LocalLabels := splitstring('A B C D E F G H I J a b c d e', ' ');
  Arithmeticals := SplitString('+ - / *', ' ');
  //showmessage(GetCurrentDir);
  if FileExists(FSelectedDirectory + '\Plus42.txt') then begin
     Synedit1.Lines.LoadFromFile(FSelectedDirectory + '\Plus42.txt');
  end;
end;


procedure TForm1.ListBox1Click(Sender : TObject);
var
  item : String;
  StartPoint, EndPoint: TPoint;
begin
   if ListBox1.ItemIndex <> -1 then
   begin
     item :=   ListBox1.Items[ListBox1.ItemIndex];
     case item of
         'Y=0?': item := '0=? ST Y';
         'Y≠0?': item := '0≠? ST Y';
         'Y<0?': item := '0>? ST Y';
         'Y>0?': item := '0<? ST Y';
         'Y≤0?': item := '0≥? ST Y';
         'Y≥0?': item := '0≤? ST Y' ;
     end;
     //synedit1.lines.Insert(SynEdit1.carety -1, item + sLineBreak);
     ////:= synedit1.text + item + sLineBreak;
     //
     ////SynEdit1.SelStart := Length(SynEdit1.Text) - 1;
     //SynEdit1.SetFocus;
     //end;
     StartPoint := Point(1, FCarY);
     EndPoint := Point(length(FCurrentLine) + 1, FCarY);
     SynEdit1.TextBetweenPoints[StartPoint, EndPoint] := item
                                                        + LineEnding + FCurrentLine;
     synedit1.CaretXY := Point( 1, FCarY + 1);
     SynEdit1.SetFocus;
   end;
end;

procedure TForm1. LoadClick( Sender: TObject);
begin
  with OpenDialog1 do begin
    InitialDir := FSelectedDirectory;
    if Execute then begin
      SynEdit1.Lines.LoadFromFile(FileName);
    end;
  end;
end;

procedure TForm1. PrintoutClick( Sender: TObject);
begin
  form4.show;
end;

procedure TForm1. SaveClick( Sender: TObject);
begin
  with SaveDialog1 do begin
    InitialDir := FSelectedDirectory;
    if Execute then begin
      SynEdit1.Lines.SaveToFile(FileName);
    end;
  end;

end;

procedure TForm1. Button1Click( Sender: TObject);
begin
  FontDialog1.Font := SynEdit1.Font;
  if FontDialog1.Execute then
    SynEdit1.Font.Assign(FontDialog1.Font);
end;

procedure TForm1. btnImportFromPlus42Click( Sender: TObject);
var
  e: string;
begin
  Synedit1.text := CopyFromPlus42(e).Text;
end;

procedure TForm1. btnExportToPlus42Click( Sender: TObject);
var
  e: string;
begin
  PasteToPlus42(SynEdit1.Lines, e);
end;

procedure TForm1. btnProgrammingModeClick( Sender: TObject);
var
  e: string;
begin
  ToggleProgrammingMode(e);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    if ReplaceDialog1.execute then
        ReplaceDialog1Replace(Sender);
end;

procedure TForm1. copyprintoutClick( Sender: TObject);
begin
  //Form2.Show;
end;

procedure TForm1. DefaultDirClick( Sender: TObject);
 var
   SelectedPath: string;

   DialogTitle: string;
begin
  with SelectDirectoryDialog1 do begin
    if Execute then  begin
       InitialDir := FSelectedDirectory;
    DialogTitle := 'Choose default directory';
      FSelectedDirectory := SelectDirectoryDialog1.FileName ;
    end;

  end;

end;

procedure TForm1.FindTextClick(Sender: TObject);
begin
      FindDialog1.Execute;  // Show the dialog

end;

procedure TForm1. FormClose( Sender: TObject; var CloseAction: TCloseAction);
begin
  //SynEdit1.Lines.SaveToFile()
  //ShowMessage(FSelectedDirectory + '\Saved.txt'  + myTimestamp);
  SynEdit1.Lines.SaveToFile(FSelectedDirectory + '\Plus42.txt');

end;

procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  aline, A, B, C, D, ThisString: String;
  LA, difference, Laline, LB: PtrInt;
  i, x, CurrentLine: Integer;
  StartOfLine, Midline, EndOfLine: Boolean;
  AB, ABCD: TStringDynArray;
  StartPoint, EndPoint: TPoint;
  endchar: Char;
  dummy: Double;
  Dummy2: Longint;
begin
  if Key = 13 then begin
    Key := 0;
    // CATER FOR EMPTY STRING

    aline := Synedit1.Lines[FLineIndex];
    if IsEmptyStr(aline, [' ']) then
        exit;
    Laline := UTF8Length(aline);
    difference:=  FCarX - Laline - 2;
    if difference > 0 then begin
      // PAD FROM EOL TO CURSOR POSITION
      // SO RETURN WORKS AS EXPECTED.
      for i := 0 to difference do begin
        aline := aline + char(160);
      end;

    end;
    //Synedit1.Lines.Add(aline);
    StartOfLine := FCarX = 1;
    Midline := (FCarX > 1) and (FCarX < Laline + 1);
    EndOfLine := FCarX > Laline;
    aline := StringReplace(aline, Char(160), '', [rfReplaceAll]);
    if StartOfLine then begin
      SynEdit1.TextBetweenPoints[Point(1, FCarY), Point(Length(aline) + 1, FCarY)] := lineending + aline;
    end
    else if Midline then begin
      SplitaLine2(Point(FCarX, FCarY) );
    end
    else if EndOfLine then begin
      // single character?
      // single instruction?
      // multipart line?
      ABCD := SplitString(aline, ' ');
      A := ABCD[0];
      B := ABCD[1];
      C := ABCD[2];
      D := ABCD[3];
      case Length(ABCD) of
        1:  begin
              if Length(A) = 1 then begin                   // single char
                StartPoint := Point(1,FCarY);               // or single number
                EndPoint := Point(Laline + 1, FCarY );
                replaceline(aline + lineending, StartPoint, EndPoint);
                SynEdit1.CaretXY := Point(1, FCarY + 1);
              end

              else  begin
                endchar := aline[Length(aline)];           // number followed by
                if endchar in Arithmeticals then begin     // operator ?
                  AB := splitstring(aline, endchar);
                  if TryStrToFloat(ab[0], dummy)  then     //
                    splitaline2(Point(FCarX - 1, FCarY))
                  else begin
                    StartPoint := Point(1,FCarY);                //not a number
                    EndPoint := Point(Length(aline) + 1, FCarY); // followed by an operator
                    replaceline(Aline + LineEnding , StartPoint, endPoint);
                    SynEdit1.CaretXY := point(1, FcarY + 1);
                  end;
                end
                else begin
                  StartPoint := Point(1,FCarY);               // anything else;
                  EndPoint := Point(1, FCarY + 1);
                  replaceline(Aline + LineEnding + lineending, StartPoint, endPoint);
                  SynEdit1.CaretXY := point(1, FcarY + 1);
                end;
              end
            end;

        2:  begin
              { #todo : NUMERIC LBLS DON'T HAVE "" }
              if A in Alphacommands then begin

                if(B in LocalLabels) or (TryStrToInt(B, Dummy2)) = True  then
                  ThisString := A + ' ' + B
                else begin
                  B := StringReplace(B, '"', '', [rfReplaceAll]);
                  ThisString := A + ' ' + '"' + B + '"';
                end
              End;
              StartPoint := Point(1, FCarY);
              EndPoint := Point(Length(aline) + 1, FCarY);
              replaceline(ThisString + LineEnding, StartPoint, EndPoint);
              SynEdit1.CaretXY := point(1, FcarY + 1);




            end;
         3,4,5: begin
               StartPoint := Point(1, FCarY);                // anything else
              EndPoint := Point(Length(aline) + 1, FCarY);   //  need to include
              replaceline(Aline + LineEnding, StartPoint, EndPoint); // KEY 1 XEQ etc
              SynEdit1.CaretXY := point(1, FcarY + 1);
              end;
  end;

  end;


end;
    end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  FLineIndex := Synedit1.CaretY -1;
  FCurrentLine := Synedit1.Lines[FLineIndex];
  FCarX := SynEdit1.CaretX;
  FCarY := SynEdit1.CaretY;
end;

procedure TForm1. SplitaLine( ALine: string);
var
  LineText, PartBefore, PartAfter: string;
  CaretPos: TPoint;
  InsertPos: TPoint;
begin
  CaretPos := SynEdit1.CaretXY;
  //LineText := SynEdit1.Lines[FCurrentLine];

  PartBefore := UTF8Copy(aline, 1, FCarX - 1);
  PartAfter := UTF8Copy(aline, FCarX, MaxInt);
  SynEdit1.BeginUndoBlock;
  try
    SynEdit1.TextBetweenPoints[Point(1, FCarY), Point(Length(aline) + 1, FCarY)] := PartBefore + lineending;
    InsertPos := Point(1, FCarY + 1);
    SynEdit1.TextBetweenPoints[InsertPos, InsertPos] :=  PartAfter;
  finally
    SynEdit1.EndUndoBlock;
  end;
  SynEdit1.CaretXY := Point(1, FLineIndex + 2);

end;

procedure TForm1. splitaline2(APos: TPoint);

 var
  PartBefore, PartAfter, s, A, B: string;
  startPoint, EndPoint: TPoint;
  x: Integer;
begin

  A := UTF8Copy(FCurrentLine, 1, APos.X - 1 );
  B := UTF8Copy(FCurrentLine, APos.X, MaxInt);

  StartPoint := Point(1, FCarY);
  EndPoint := Point(length(FCurrentLine) + 1, FCarY);
  synedit1.TextBetweenPoints[StartPoint, EndPoint] := A + LineEnding + B + lineending;
  synedit1.CaretXY := Point(1,  SynEdit1.CaretY + 2);

  end;

procedure TForm1.splitaline3(aline: string; APos: TPoint);

 var
  PartBefore, PartAfter, s, A, B: string;
  startPoint, EndPoint: TPoint;
  x: Integer;
begin

  A := UTF8Copy(aline, 1, APos.X - 1 );
  B := UTF8Copy(aline, APos.X, MaxInt);

  StartPoint := Point(1, FCarY);
  EndPoint := Point(length(aline) + 1, FCarY);
  synedit1.TextBetweenPoints[StartPoint, EndPoint] := A + LineEnding + B ;
  synedit1.CaretXY := Point(1,  SynEdit1.CaretY + 1);

  end;



end.

