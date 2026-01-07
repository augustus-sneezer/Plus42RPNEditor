[README.md](https://github.com/user-attachments/files/24468215/README.md)
# Plus42 RPN Editor
A Lazarus/Free Pascal editor for HP calculator programs.

## Features

- **Auto quotes:** Automatically formats labels to save keystrokes.
  - `LBL CATS` + `<ENTER>` → `LBL "CATS"`
  - `RCL+ DOGS` + `<ENTER>` → `RCL+ "DOGS"`
  - `LBL j` + `<ENTER>` → `LBL j` (Handles local labels correctly)
- **Arithmetic Splitting:**
  - `2368*` + `<ENTER>` automatically becomes:
    ```text
    2368
    *
    ```
- **Plus42 Integration:**
  - Toggle programming mode of Plus42 from the editor.
  - Import from and Export to Plus42 directly.
- **RPN Pick-list:** Includes a sidebar/list of common RPN functions.
- **Search Tools:** Full Find and Replace functionality.

## Building

1. Open `RPNEditor.lpi` in Lazarus.
2. Build project (**Ctrl+F9**).
