unit CustomHighlighter;    //unit SynEditHighlighter;

interface

uses
  Classes, SysUtils, SynEdit, SynEditMarkup, SynEditMarkupHighAll, Graphics;

type
  TSynEditHighlighter = class
  private
    FSynEdit: TSynEdit;
    FRTNMarkup: TSynEditMarkupHighlightAll;
    FLBLMarkup: TSynEditMarkupHighlightAll;
    FNumberMarkups: array[0..9] of TSynEditMarkupHighlightAll;
    FCommandMarkups: array of TSynEditMarkupHighlightAll;
    FCommandWords: TStringList   ;
     procedure AddCommandMarkups;

    procedure HandleSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure AddDefaultContent;
  public
    constructor Create(aSynEdit: TSynEdit);
    destructor Destroy; override;
    procedure AddLineWithFocus(const LineText: string); // Add this line
  end;

implementation

procedure TSynEditHighlighter.AddCommandMarkups;
const
  CommandWords = 'CLV CLP XEQ GTO AVIEW VIEW STO STO+ STO- STO* ' +
                 'STO/ RCL RCL+ RCL- RCL* MVAR RCL/ STO INPUT';
var
  Words: TStringArray;
  i: Integer;
begin
  Words := CommandWords.Split([' '], TStringSplitOptions.ExcludeEmpty);
  SetLength(FCommandMarkups, Length(Words));

  for i := 0 to High(Words) do
  begin
    FCommandMarkups[i] := TSynEditMarkupHighlightAll.Create(FSynEdit);
    FCommandMarkups[i].MarkupInfo.Foreground := clGreen;
    FCommandMarkups[i].MarkupInfo.Background := clNone; // Transparent background
    FCommandMarkups[i].SearchString := Words[i];
    //FCommandMarkups[i].CaseSensitive := False; // Case insensitive matching
    //FCommandMarkups[i].WholeWord := True; // Match whole words only
    FCommandMarkups[i].Enabled := True;
    FSynEdit.MarkupManager.AddMarkUp(FCommandMarkups[i]);
  end;
end;


{ TSynEditHighlighter }
constructor TSynEditHighlighter.Create(aSynEdit: TSynEdit);
var
  i: Integer;
begin
  inherited Create;
  FSynEdit := aSynEdit;

  // Set up special line colors
  FSynEdit.OnSpecialLineColors := @HandleSpecialLineColors;

  // Highlight 'RTN' in green (keep existing)
  FRTNMarkup := TSynEditMarkupHighlightAll.Create(FSynEdit);
  FRTNMarkup.MarkupInfo.Foreground := clGreen;
  FRTNMarkup.MarkupInfo.Background := clWhite;
  FRTNMarkup.SearchString := 'RTN';
  FRTNMarkup.Enabled := True;
  FSynEdit.MarkupManager.AddMarkUp(FRTNMarkup);

  // Highlight 'LBL' in blue (keep existing)
  FLBLMarkup := TSynEditMarkupHighlightAll.Create(FSynEdit);
  FLBLMarkup.MarkupInfo.Foreground := clBlue;
  FLBLMarkup.MarkupInfo.Background := clYellow;
  FLBLMarkup.SearchString := 'LBL';
  FLBLMarkup.Enabled := True;
  FSynEdit.MarkupManager.AddMarkUp(FLBLMarkup);

  // Highlight each digit (0-9) in red (keep existing)
  for i := 0 to 9 do
  begin
    FNumberMarkups[i] := TSynEditMarkupHighlightAll.Create(FSynEdit);
    FNumberMarkups[i].MarkupInfo.Foreground := clRed;
    FNumberMarkups[i].MarkupInfo.Background := clWhite;
    FNumberMarkups[i].SearchString := IntToStr(i);
    FNumberMarkups[i].Enabled := True;
    FSynEdit.MarkupManager.AddMarkUp(FNumberMarkups[i]);
  end;

  // Add command word highlighting
  AddCommandMarkups;

  // Add the default content
  AddDefaultContent;
end;


//constructor TSynEditHighlighter.Create(aSynEdit: TSynEdit);
//var
//  i: Integer;
//  Commands: TStringArray;
//begin
//  inherited Create;
//  FSynEdit := aSynEdit;
//
//  // Initialize command words list
//  FCommandWords := TStringList.Create;
//  FCommandWords.Delimiter := ' ';
//  FCommandWords.StrictDelimiter := True;
//  FCommandWords.DelimitedText := 'CLV CLP XEQ GTO AVIEW VIEW STO STO+ STO- STO* ' +
//                                'STO/ RCL RCL+ RCL- RCL* MVAR RCL/  STO INPUT';
//
//  // Set up special line colors
//  FSynEdit.OnSpecialLineColors := @HandleSpecialLineColors;
//
//  // Create markup for each command word
//  SetLength(FCommandMarkups, FCommandWords.Count);
//  for i := 0 to FCommandWords.Count - 1 do
//  begin
//    FCommandMarkups[i] := TSynEditMarkupHighlightAll.Create(FSynEdit);
//    FCommandMarkups[i].MarkupInfo.Foreground := clGreen;
//    FCommandMarkups[i].MarkupInfo.Background := clNone; // Transparent background
//    FCommandMarkups[i].SearchString := FCommandWords[i];
//    FCommandMarkups[i].Enabled := True;
//    FSynEdit.MarkupManager.AddMarkUp(FCommandMarkups[i]);
//  end;
  // //Highlight 'LBL' in blue
  //FLBLMarkup := TSynEditMarkupHighlightAll.Create(FSynEdit);
  //FLBLMarkup.MarkupInfo.Foreground := clBlue;
  //FLBLMarkup.MarkupInfo.Background := clYellow;
  //FLBLMarkup.SearchString := 'LBL';
  //FLBLMarkup.Enabled := True;
//  FSynEdit.MarkupManager.AddMarkUp(FLBLMarkup);

  // Add the default content
  //AddDefaultContent;
//end;
//
//constructor TSynEditHighlighter.Create(aSynEdit: TSynEdit);
//var
//  i: Integer;
//begin
//  inherited Create;
//  FSynEdit := aSynEdit;
//
//  // Set up special line colors
//  FSynEdit.OnSpecialLineColors := @HandleSpecialLineColors;
//
//  // Highlight 'RTN' in green
//  FRTNMarkup := TSynEditMarkupHighlightAll.Create(FSynEdit);
//  FRTNMarkup.MarkupInfo.Foreground := clGreen;
//  FRTNMarkup.MarkupInfo.Background := clWhite;
//  FRTNMarkup.SearchString := 'RTN';
//  FRTNMarkup.Enabled := True;
//  FSynEdit.MarkupManager.AddMarkUp(FRTNMarkup);
//
//
//
//  // Highlight each digit (0-9) in red
//  for i := 0 to 9 do
//  begin
//    FNumberMarkups[i] := TSynEditMarkupHighlightAll.Create(FSynEdit);
//    FNumberMarkups[i].MarkupInfo.Foreground := clRed;
//    FNumberMarkups[i].MarkupInfo.Background := clWhite;
//    FNumberMarkups[i].SearchString := IntToStr(i);
//    FNumberMarkups[i].Enabled := True;
//    FSynEdit.MarkupManager.AddMarkUp(FNumberMarkups[i]);
//  end;
//
//  // Add the default content
//  AddDefaultContent;
//end;


destructor TSynEditHighlighter.Destroy;
var
  i: Integer;
begin
  if Assigned(FSynEdit) then
  begin
    FSynEdit.OnSpecialLineColors := nil;

    // Remove all markups
    if Assigned(FRTNMarkup) then
      FSynEdit.MarkupManager.RemoveMarkUp(FRTNMarkup);
    if Assigned(FLBLMarkup) then
      FSynEdit.MarkupManager.RemoveMarkUp(FLBLMarkup);

    for i := 0 to 9 do
      if Assigned(FNumberMarkups[i]) then
        FSynEdit.MarkupManager.RemoveMarkUp(FNumberMarkups[i]);

    for i := 0 to High(FCommandMarkups) do
      if Assigned(FCommandMarkups[i]) then
        FSynEdit.MarkupManager.RemoveMarkUp(FCommandMarkups[i]);
  end;

end;







//
//destructor TSynEditHighlighter.Destroy;
//var
//  i: Integer;
//begin
//  if Assigned(FSynEdit) then
//  begin
//    FSynEdit.OnSpecialLineColors := nil;
//
//    // Remove all command markups
//    for i := 0 to High(FCommandMarkups) do
//      if Assigned(FCommandMarkups[i]) then
//        FSynEdit.MarkupManager.RemoveMarkUp(FCommandMarkups[i]);
//  end;
//
//  // Free all command markups
//  for i := 0 to High(FCommandMarkups) do
//    FreeAndNil(FCommandMarkups[i]);
//
//  FreeAndNil(FCommandWords);
//  inherited;
//end;


//destructor TSynEditHighlighter.Destroy;
//var
//  i: Integer;
//begin
//  if Assigned(FSynEdit) then
//  begin
//    FSynEdit.OnSpecialLineColors := nil;
//
//    //if Assigned(FRTNMarkup) then
//    //  FSynEdit.MarkupManager.RemoveMarkUp(FRTNMarkup);
//    if Assigned(FLBLMarkup) then
//      FSynEdit.MarkupManager.RemoveMarkUp(FLBLMarkup);
//
//    for i := 0 to 9 do
//      if Assigned(FNumberMarkups[i]) then
//        FSynEdit.MarkupManager.RemoveMarkUp(FNumberMarkups[i]);
//  end;
//
//  FreeAndNil(FRTNMarkup);
//  FreeAndNil(FLBLMarkup);
//
//  for i := 0 to 9 do
//    FreeAndNil(FNumberMarkups[i]);
//
//  inherited;
//end;

procedure TSynEditHighlighter.HandleSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
begin
  if (Line >= 1) and (Line <= FSynEdit.Lines.Count) then
  begin
    if FSynEdit.Lines[Line - 1].Trim.StartsWith('"') then
    begin
      Special := True;
      BG := clWhite;
      FG := clBlue;
    end;
  end;
end;

procedure TSynEditHighlighter.AddDefaultContent;
begin
  //FSynEdit.Lines.Clear;
  //FSynEdit.Lines.Add('"This line will be blue on white');
  //FSynEdit.Lines.Add('LBL 123 RTN 456');
  //FSynEdit.CaretX := 1;
  //FSynEdit.CaretY := FSynEdit.Lines.Count;
end;

// Add this method
procedure TSynEditHighlighter.AddLineWithFocus(const LineText: string);
begin
  FSynEdit.Lines.Add(LineText);
  FSynEdit.CaretX := 1;
  FSynEdit.CaretY := FSynEdit.Lines.Count;
end;

end.
