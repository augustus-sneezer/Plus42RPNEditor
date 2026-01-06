unit Plus42Comms;

interface

uses
  Classes, SysUtils, Windows, Types, Clipbrd, Dialogs, StrUtils, Strings;

function CopyFromPlus42(out ErrorMessage: string): TStrings;
function PasteToPlus42(ATextToPaste: TStrings; out ErrorMessage: string): Boolean;
function ToggleProgrammingMode(out ErrorMessage: string): Boolean;
function CopyFromPlus42Printout(out ErrorMessage: string): TStringList;
function ClearPrintout(out ErrorMessage: string): Boolean;
function CopyPlus42Printout(out ErrorMessage: string): TStrings;

var
  Cycle: integer;

implementation

const
  //KEYEVENTF_KEYUP = $0002;
  //VK_SHIFT_KEY = 16;
  //VK_RS_KEY = 220;
  KEYEVENTF_KEYUP = $0002;
  VK_SHIFT_KEY = 16;     // Standard Virtual Key Code for Shift
  VK_RS_KEY = 220;       // Virtual Key Code for Backslash
  VK_CONTROL = 17;       // Control key
  VK_D_KEY = 68;         // D key
  VK_T_KEY = 84;         // T key
  VK_C_KEY = 67;         // C key
  VK_V_KEY = 86;         // V key
  VK_ESC_KEY= 27;       // ESC key



function FindPlus42WindowHandle: HWND;
var
  Plus42Handle: HWND;
  WindowClassName: string;
  WindowTitle: string;
begin
  Result := 0;
  WindowTitle := 'Plus42 Decimal';

  WindowClassName := 'FREE42';
  Plus42Handle := FindWindow(PChar(WindowClassName), PChar(WindowTitle));
  if Plus42Handle <> 0 then
  begin
    Result := Plus42Handle;
    Exit;
  end;

  WindowClassName := 'FREE';
  Plus42Handle := FindWindow(PChar(WindowClassName), PChar(WindowTitle));
  if Plus42Handle <> 0 then
  begin
    Result := Plus42Handle;
    Exit;
  end;

  Plus42Handle := FindWindow(nil, PChar(WindowTitle));
  if Plus42Handle <> 0 then
    Result := Plus42Handle;
end;


function CopyPlus42Printout(out ErrorMessage: string): TStrings;
var
  Plus42Handle: HWND;
  OldClipboardContents: string;
begin
  Result := nil;
  ErrorMessage := '';

  Plus42Handle := FindPlus42WindowHandle;
  if Plus42Handle = 0 then
  begin
    ErrorMessage := 'Plus42 window not found. Please ensure it is running and visible.';
    Exit;
  end;

  OldClipboardContents := '';
  if Clipboard.HasFormat(CF_TEXT) then
    OldClipboardContents := Clipboard.AsText;

  SetForegroundWindow(Plus42Handle);
  Sleep(100);

  // Simulate Ctrl+T (Copy Printout)
  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(VK_T_KEY, 0, 0, 0);
keybd_event(VK_T_KEY, 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);

  Sleep(200);

  if Clipboard.HasFormat(CF_TEXT) then
  begin
    Result := TStringList.Create;
    try
      Result.Text := Clipboard.AsText;
      //showmessage(Result.Text);
    except
      on E: Exception do
      begin
        ErrorMessage := 'Error processing clipboard data: ' + E.Message;
        FreeAndNil(Result);
      end;
    end;
  end
  else
  begin
    ErrorMessage := 'No text copied from Plus42 to clipboard.';
    if OldClipboardContents <> '' then
      Clipboard.AsText := OldClipboardContents;
  end;
end;





procedure StripLineNumbers(var ListFrom42: TStrings);
var
  i: Integer;
  astring, replacement: String;
  AB: TStringDynArray;
begin
  for i := 0 to ListFrom42.Count - 1 do
  begin
    astring := ListFrom42.Strings[i];
    if Pos('▸', astring) > 0 then
      astring := StringReplace(astring, '▸', ' ', [rfReplaceAll]);
    AB := SplitString(astring, ' ');
    if Length(AB) > 1 then
      replacement := String.Join(' ', Copy(AB, 1, Length(AB) - 1))
    else
      replacement := astring;
    ListFrom42.Strings[i] := replacement;
  end;
end;
//
//function CopyFromPlus42Printout(out ErrorMessage: string): TStrings;
//const
//  MAX_ATTEMPTS = 3;
//  INITIAL_DELAY = 300;
//  RETRY_DELAY = 150;
//  POST_KEY_DELAY = 500;
//var
//  Plus42Handle: HWND;
//  Attempt: Integer;
//  StartTime: Cardinal;
//  CurrentDelay: Integer;
//begin
//  Result := nil;
//  ErrorMessage := '';
//  Plus42Handle := FindPlus42WindowHandle;
//
//  if Plus42Handle = 0 then
//  begin
//    ErrorMessage := 'Plus42 window not found';
//    Exit;
//  end;
//
//  for Attempt := 1 to MAX_ATTEMPTS do
//  begin
//    try
//      if Attempt = 1 then
//        CurrentDelay := INITIAL_DELAY
//      else
//        CurrentDelay := RETRY_DELAY;
//
//      Clipboard.Open;
//      SetForegroundWindow(Plus42Handle);
//      Sleep(CurrentDelay);
//
//      keybd_event(VK_CONTROL, 0, 0, 0);
//      keybd_event(Ord('T'), 0, 0, 0);
//keybd_event(Ord('T'), 0, KEYEVENTF_KEYUP, 0);
//      keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);
//      Sleep(500);
//
//      StartTime := GetTickCount;
//      while (GetTickCount - StartTime) < POST_KEY_DELAY do
//      begin
//        if Clipboard.HasFormat(CF_TEXT) then
//        begin
//          Result := TStringList.Create;
//          Result.Text := Clipboard.AsText;
//          Exit;
//        end;
//        Sleep(50);
//      end;
//    except
//      on E: Exception do
//      begin
//        ErrorMessage := Format('Attempt %d: %s', [Attempt, E.Message]);
//        if Attempt = MAX_ATTEMPTS then Exit;
//      end;
//    end;
//  end;
//  ErrorMessage := 'Failed after ' + IntToStr(MAX_ATTEMPTS) + ' attempts';
//end;
//function CopyFromPlus42Printout(out ErrorMessage: string): TStringList;
//const
//  POST_KEY_DELAY = 1000;  // Increased delay
//  MAX_WAIT = 3000;        // Maximum wait time in ms
//var
//  Plus42Handle: HWND;
//  StartTime: Cardinal;
//begin
//  Result := nil;
//  ErrorMessage := '';
//  Plus42Handle := FindPlus42WindowHandle;
//
//  if Plus42Handle = 0 then
//  begin
//    ErrorMessage := 'Plus42 window not found';
//    Exit;
//  end;
//
//  try
//    // Ensure we have clipboard access
//    Clipboard.Open;
//    try
//      // Clear clipboard first to detect new content
//      Clipboard.Clear;
//
//      // Activate window and send keys
//      SetForegroundWindow(Plus42Handle);
//      Sleep(300); // Initial delay
//
//      // More reliable key sending
//      keybd_event(VK_CONTROL, 0, 0, 0);
//      Sleep(50);
//      keybd_event(Ord('T'), 0, 0, 0);
//      Sleep(50);
//      keybd_event(Ord('T'), 0, KEYEVENTF_KEYUP, 0);
//      Sleep(50);
//      keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);
//
//      // Wait for clipboard content with timeout
//      StartTime := GetTickCount;
//      while (GetTickCount - StartTime) < MAX_WAIT do
//      begin
//        Sleep(100);
//        if Clipboard.HasFormat(CF_TEXT) then
//        begin
//          Result := TStringList.Create;
//          try
//            Result.Text := Clipboard.AsText;
//            Exit;  // Success
//          except
//            FreeAndNil(Result);
//            raise;
//          end;
//        end;
//      end;
//
//      ErrorMessage := 'Timeout waiting for clipboard data';
//    finally
//      Clipboard.Close;
//    end;
//  except
//    on E: Exception do
//    begin
//      ErrorMessage := 'Error: ' + E.Message;
//    end;
//  end;
//end;

function CopyFromPlus42Printout(out ErrorMessage: string): TStringList;
const
  POST_KEY_DELAY = 200;  // Wait 1 second after keypress
  MAX_WAIT = 500;        // Increased to 5 seconds total wait
var
  Plus42Handle: HWND;
  StartTime: Cardinal;
  Attempts: Integer;
begin
  Result := nil;
  ErrorMessage := '';
  Plus42Handle := FindPlus42WindowHandle;

  if Plus42Handle = 0 then
  begin
    ErrorMessage := 'Plus42 window not found';
    Exit;
  end;

  for Attempts := 1 to 3 do  // Try up to 3 times
  begin
    try
      Clipboard.Open;
      try
        Clipboard.Clear;  // Start with empty clipboard

        // Ensure window is focused
        SetForegroundWindow(Plus42Handle);
        BringWindowToTop(Plus42Handle);
        Sleep(500);  // Increased initial delay

        // Send Ctrl+T more deliberately
        keybd_event(VK_CONTROL, 0, 0, 0);
        Sleep(100);
        keybd_event(Ord('T'), 0, 0, 0);
        Sleep(100);
        keybd_event(Ord('T'), 0, KEYEVENTF_KEYUP, 0);
        Sleep(100);
        keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);

        // Wait for data with progressive checking
        StartTime := GetTickCount;
        while (GetTickCount - StartTime) < MAX_WAIT do
        begin
          if Clipboard.HasFormat(CF_TEXT) then
          begin
            Result := TStringList.Create;
            Result.Text := Clipboard.AsText;
            Exit;  // Success!
          end;
          Sleep(200);  // Check every 200ms
        end;
      finally
        Clipboard.Close;
      end;
    except
      on E: Exception do
        ErrorMessage := 'Attempt ' + IntToStr(Attempts) + ': ' + E.Message;
    end;

    if Attempts < 3 then
      Sleep(1000);  // Wait before retry
  end;

  ErrorMessage := 'Failed after 3 attempts: ' + ErrorMessage;
end;



function CopyFromPlus42(out ErrorMessage: string): TStrings;
var
  Plus42Handle: HWND;
  RetryCount: Integer;
  LastError: string;
begin
  Result := nil;
  ErrorMessage := '';
  Plus42Handle := FindPlus42WindowHandle;

  if Plus42Handle = 0 then
  begin
    ErrorMessage := 'Plus42 window not found';
    Exit;
  end;

  for RetryCount := 1 to 2 do
  begin
    try
      SetForegroundWindow(Plus42Handle);
      Sleep(100);

      keybd_event(VK_CONTROL, 0, 0, 0);
      keybd_event(Ord('C'), 0, 0, 0);
      keybd_event(Ord('C'), 0, KEYEVENTF_KEYUP, 0);
      keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);

      Sleep(300);

      if Clipboard.HasFormat(CF_TEXT) then
      begin
        Result := TStringList.Create;
        try
          Result.Text := Clipboard.AsText;
          StripLineNumbers(Result);
          ErrorMessage := '';
          Exit;
        except
          FreeAndNil(Result);
          raise;
        end;
      end
      else if RetryCount = 1 then
      begin
        LastError := 'No text copied (attempt ' + IntToStr(RetryCount) + ')';
        Continue;
      end;
    except
      on E: Exception do
      begin
        if RetryCount = 1 then
        begin
          LastError := 'Error: ' + E.Message + ' (attempt ' + IntToStr(RetryCount) + ')';
          Sleep(200);
          Continue;
        end;
        LastError := 'Failed after retry: ' + E.Message;
      end;
    end;
  end;
  ErrorMessage := LastError;
end;

function PasteToPlus42(ATextToPaste: TStrings; out ErrorMessage: string): Boolean;
var
  Plus42Handle: HWND;
  RetryCount: Integer;
  Success: Boolean;
begin
  Result := False;
  ErrorMessage := '';
  Plus42Handle := FindPlus42WindowHandle;

  if Plus42Handle = 0 then
  begin
    ErrorMessage := 'Plus42 window not found';
    Exit;
  end;

  if (ATextToPaste = nil) or (ATextToPaste.Count = 0) then
  begin
    ErrorMessage := 'No text to paste';
    Exit;
  end;

  Success := False;
  for RetryCount := 1 to 3 do
  begin
    try
      Clipboard.Open;
      Clipboard.Clear;
      Clipboard.AsText := ATextToPaste.Text;
      Clipboard.Close;
      Success := True;
      Break;
    except
      Sleep(200);
    end;
  end;

  if not Success then
  begin
    ErrorMessage := 'Failed to prepare clipboard';
    Exit;
  end;

  SetForegroundWindow(Plus42Handle);
  Sleep(100);

  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(Ord('V'), 0, 0, 0);
  keybd_event(Ord('V'), 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);

  Result := True;
  Sleep(100);
end;

function ClearPrintout(out ErrorMessage: string): Boolean;
var
  hPlus42: HWND;
begin
  Result := False;
  ErrorMessage := '';
  hPlus42 := FindPlus42WindowHandle;

  if hPlus42 = 0 then
  begin
    ErrorMessage := 'Plus42 window not found!';
    Exit;
  end;

  SetForegroundWindow(hPlus42);
  Sleep(100);

  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(Ord('D'), 0, 0, 0);
  keybd_event(Ord('D'), 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);
  Clipboard.AsText := '';

  Result := True;
end;

function ToggleProgrammingMode(out ErrorMessage: string): Boolean;
var
  hPlus42: HWND;
begin
  Result := False;
  ErrorMessage := '';
  hPlus42 := FindPlus42WindowHandle;

  if hPlus42 = 0 then
  begin
    ErrorMessage := 'Plus42 window not found!';
    Exit;
  end;

  SetForegroundWindow(hPlus42);
  Sleep(100);
  // taking a wild guess here

  //keybd_event(VK_ESC_KEY, 0, 0, 0);
  //keybd_event(VK_ESC_KEY, 0, KEYEVENTF_KEYUP, 0);
  //

  keybd_event(VK_SHIFT_KEY, 0, 0, 0);
  Sleep(50);
  keybd_event(VK_RS_KEY, 0, 0, 0);
  keybd_event(VK_RS_KEY, 0, KEYEVENTF_KEYUP, 0);
  Sleep(50);
  keybd_event(VK_SHIFT_KEY, 0, KEYEVENTF_KEYUP, 0);

  Result := True;
end;

end.
