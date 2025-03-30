unit Unit1;

{HANDMODIFIED COMMENT ADDED
  March 30 2025

  Entry for Minesweeper contest.
  Code produced by Google Gemini 2.5 Pro by successively giving it these prompts:

  "Make a complete minesweeper game in Delphi.
   It must contain animated graphics and keep track of score,
   contain a nice intro and a nice failure and success end
   animation/screen."

  Providing additional hint by followup prompt:

  "Produce the dfm file too"

  Providing additional hint by followup prompt:

  "Change the code to not use predefined images,
   but instead draw them using drawing primitives.
   That includes all graphics and animations."

  Providing additional hint by followup prompt:

  "DFM files can't contain comments.
   And TMainMenu does not have a height since it does not count as part
   of the client area."

  Which produced the current code, including DFM file.
  The code could not compile without simple changes, which
  I could have told it to make Im sure, but I instead decided to
  mark the changes with {HANDMODIFIED....

  Two types of mistakes was made:
    1) thinking that InflateRect is a function. It is a procedure.
       so requires to be on a separate line. Eg.

        DrawFlag(ACanvas, InflateRect(DestRect, -BEVEL_WIDTH-1, -BEVEL_WIDTH-1));

    2) not specifying correct paranthesis for a statement:

          else if FGameState in [gsWon, gsLost] and (FEndTime > FStartTime) then

       Which fails because of missing paranthesis around the FGameState in [...] part.

  In addition it forgot to link the imgBoardMouseDown event handler, that it did produce
  to the actual eventhandler OnMouseDown of the imgBoard control.

  With those fixes, the code runs and works pretty well.
  It seems to me that, with an aggregated prompt, and a little fine tuning,
  it might very well have produced a fully functioning Delphi Minesweeper game
  without further human interaction needed, except for copy/paste/compile/run.

  Kim Bo Madsen
  Components4Developers
  www.components4developers.com
  House of components for serious applications
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Menus, System.Math, Vcl.ComCtrls, System.Types, // Added System.Types for TPoint
  System.UIConsts; // Added for standard colors like clBtnFace etc.

type
  TGameState = (gsIntro, gsReady, gsPlaying, gsWon, gsLost, gsAnimating);

  // NEW: State for the smiley face
  TSmileyState = (ssNormal, ssOoh, ssWin, ssLost);

  TCell = record
    IsMine: Boolean;
    IsRevealed: Boolean;
    IsFlagged: Boolean;
    AdjacentMines: Integer;
  end;

  TDifficulty = (dEasy, dMedium, dHard);

  TMainForm = class(TForm)
    imgBoard: TImage;
    StatusBar1: TStatusBar;
    GameTimer: TTimer;
    AnimationTimer: TTimer;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    NGame: TMenuItem;
    DifficultyMenu: TMenuItem;
    EasyItem: TMenuItem;
    MediumItem: TMenuItem;
    HardItem: TMenuItem;
    ExitItem: TMenuItem;
    imgSmiley: TImage; // Will draw directly onto this
    imgOverlay: TImage; // For intro/outro screens - drawn directly
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject); // Keep for freeing lists etc.
    procedure imgBoardMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GameTimerTimer(Sender: TObject);
    procedure AnimationTimerTimer(Sender: TObject);
    procedure NGameClick(Sender: TObject);
    procedure EasyItemClick(Sender: TObject);
    procedure MediumItemClick(Sender: TObject);
    procedure HardItemClick(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure imgSmileyClick(Sender: TObject);
    procedure imgOverlayClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure imgBoardPaint(Sender: TObject); // Use OnPaint for direct drawing if preferred
    procedure imgSmileyPaint(Sender: TObject); // Use OnPaint for smiley
  private
    { Private declarations }
    FGrid: array of array of TCell;
    FGridWidth, FGridHeight: Integer;
    FMineCount: Integer;
    FCellSize: Integer;
    FGameState: TGameState;
    FFirstClick: Boolean;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
    FRevealedCount: Integer;
    FFlagsPlaced: Integer;
    FGameLostMineX, FGameLostMineY: Integer;
    FCurrentDifficulty: TDifficulty;
    FCurrentSmileyState: TSmileyState; // Track current smiley state

    // Graphics Resources REMOVED - No longer needed
    // FTiles: TBitmap;
    // FSmileyNormal, FSmileyOoh, FSmileyWin, FSmileyLost: TBitmap;
    // FIntroBitmap, FWinBitmap, FLostBitmap: TBitmap;

    // For animation:
    FAnimationStep: Integer;
    FCellsToReveal: TList; // Still used for loss animation logic

    // Graphics drawing procedures
    procedure DrawBevel(ACanvas: TCanvas; R: TRect; Width: Integer; Up: Boolean);
    procedure DrawTilePrimitive(ACanvas: TCanvas; DestRect: TRect; TileIndex: Integer);
    procedure DrawSmileyFace(ACanvas: TCanvas; DestRect: TRect; State: TSmileyState);
    procedure DrawIntroScreen(ACanvas: TCanvas; Width, Height: Integer; Step: Integer);
    procedure DrawWinScreen(ACanvas: TCanvas; Width, Height: Integer; Step: Integer);
    procedure DrawLossScreen(ACanvas: TCanvas; Width, Height: Integer; Step: Integer);
    procedure DrawFlag(ACanvas: TCanvas; R: TRect);
    procedure DrawMine(ACanvas: TCanvas; R: TRect; IsHit: Boolean = False);
    procedure DrawWrongMine(ACanvas: TCanvas; R: TRect);

    // Game Logic procedures (mostly unchanged internally, but drawing calls modified)
    procedure SetupGame(ADifficulty: TDifficulty);
    procedure InitializeGrid;
    procedure PlaceMines(ExcludeX, ExcludeY: Integer);
    procedure CalculateAdjacentMines;
    procedure DrawBoard; // Will now call DrawTilePrimitive
    procedure DrawCell(ACanvas: TCanvas; GridX, GridY: Integer); // Calls DrawTilePrimitive
    // procedure DrawTile(...) REMOVED - Replaced by DrawTilePrimitive
    procedure RevealCell(GridX, GridY: Integer);
    procedure FloodFill(GridX, GridY: Integer);
    procedure CheckWinCondition;
    procedure GameOver(Win: Boolean);
    procedure UpdateStatusBar;
    procedure UpdateSmiley(Scared: Boolean = False); // Will call DrawSmileyFace
    procedure SetDifficultyCheckmark(ADifficulty: TDifficulty);
    procedure StartIntro;
    procedure StartWinAnimation;
    procedure StartLossAnimation;
    function GetTileIndex(GridX, GridY: Integer): Integer;
    function IsValidCoord(GridX, GridY: Integer): Boolean;
    procedure CenterBoard;
    procedure EnsureImageBitmaps; // Helper to make sure TImage bitmaps exist

  public
    { Public declarations }
  end;

const
  // Tile indices remain the same conceptually
  TILE_COVERED = 0;
  TILE_FLAG = 1;
  TILE_QUESTION = 2; // Keep index, but maybe don't implement drawing
  TILE_0 = 3;
  TILE_1 = 4;
  TILE_2 = 5;
  TILE_3 = 6;
  TILE_4 = 7;
  TILE_5 = 8;
  TILE_6 = 9;
  TILE_7 = 10;
  TILE_8 = 11;
  TILE_MINE = 12;
  TILE_MINE_HIT = 13;
  TILE_MINE_WRONG = 14;

  DEFAULT_CELL_SIZE = 24; // Adjusted default size for primitive drawing
  BEVEL_WIDTH = 2;        // How many pixels for the 3D bevel effect

var
  MainForm: TMainForm;

implementation

{$R *.dfm} // Make sure the DFM matches the structure

uses System.DateUtils; // For SecondsBetween

// --- Initialization and Cleanup ---

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Double Buffering still useful to avoid flicker when drawing primitives
  imgBoard.ControlStyle := imgBoard.ControlStyle + [csOpaque];
  imgSmiley.ControlStyle := imgSmiley.ControlStyle + [csOpaque];
  imgOverlay.ControlStyle := imgOverlay.ControlStyle + [csOpaque];

  FCellSize := DEFAULT_CELL_SIZE;
  FCellsToReveal := TList.Create;
  Randomize;
  // LoadGraphics REMOVED
  FCurrentDifficulty := dEasy;
  SetDifficultyCheckmark(FCurrentDifficulty);

  // Adjust Smiley Size based on constants (doesn't rely on loaded bitmap anymore)
  imgSmiley.Width := FCellSize * 2; // Example size
  imgSmiley.Height := FCellSize * 2;
  imgSmiley.AutoSize := False; // Important: We control the size now

  StartIntro;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: Integer;
  ptr: Pointer;
begin
  // Free any remaining pointers in the list if animation was interrupted
  for i := FCellsToReveal.Count - 1 downto 0 do
  begin
     ptr := FCellsToReveal[i];
     FreeMem(ptr);
  end;
  FCellsToReveal.Free;
  // FreeGraphics REMOVED
end;

// --- NEW: Graphics Primitive Drawing Functions ---

// Helper to draw simple 3D bevels
procedure TMainForm.DrawBevel(ACanvas: TCanvas; R: TRect; Width: Integer; Up: Boolean);
var
  i: Integer;
  TopLeftColor, BottomRightColor: TColor;
begin
  if Up then // Raised bevel
  begin
    TopLeftColor := clBtnHighlight;
    BottomRightColor := clBtnShadow;
  end else // Lowered bevel
  begin
    TopLeftColor := clBtnShadow;
    BottomRightColor := clBtnHighlight;
  end;

  ACanvas.Pen.Width := 1;
  for i := 0 to Width - 1 do
  begin
    // Top and Left lines
    ACanvas.Pen.Color := TopLeftColor;
    ACanvas.MoveTo(R.Left + i, R.Bottom - 1 - i);
    ACanvas.LineTo(R.Left + i, R.Top + i);
    ACanvas.LineTo(R.Right - 1 - i, R.Top + i);

    // Bottom and Right lines
    ACanvas.Pen.Color := BottomRightColor;
    ACanvas.MoveTo(R.Right - 1 - i, R.Top + i);
    ACanvas.LineTo(R.Right - 1 - i, R.Bottom - 1 - i);
    ACanvas.LineTo(R.Left + i, R.Bottom - 1 - i);
  end;
end;

// Draws a Flag primitive
procedure TMainForm.DrawFlag(ACanvas: TCanvas; R: TRect);
var
  PoleX, MidY: Integer;
  FlagPoints: array[0..2] of TPoint;
begin
  PoleX := R.Left + R.Width div 2;
  MidY := R.Top + R.Height div 2;

  // Pole
  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Width := Max(1, R.Width div 10); // Scale pole width
  ACanvas.MoveTo(PoleX, R.Top + 2);
  ACanvas.LineTo(PoleX, R.Bottom - 2);
  // Base
  ACanvas.MoveTo(R.Left + 2, R.Bottom - 3);
  ACanvas.LineTo(R.Right - 2, R.Bottom - 3);

  // Flag (Triangle)
  FlagPoints[0] := Point(PoleX, R.Top + 3);
  FlagPoints[1] := Point(R.Left + 3, MidY - 2);
  FlagPoints[2] := Point(PoleX, MidY + 1);

  ACanvas.Brush.Color := clRed;
  ACanvas.Pen.Color := clBlack; // Outline flag
  ACanvas.Pen.Width := 1;
  ACanvas.Polygon(FlagPoints);
end;

// Draws a Mine primitive
procedure TMainForm.DrawMine(ACanvas: TCanvas; R: TRect; IsHit: Boolean = False);
var
  CenterX, CenterY, Radius, SmallRadius: Integer;
begin
  CenterX := R.Left + R.Width div 2;
  CenterY := R.Top + R.Height div 2;
  Radius := Min(R.Width, R.Height) * 2 div 5; // 40% radius
  SmallRadius := Radius div 4;

  // Background if hit
  if IsHit then
  begin
    ACanvas.Brush.Color := clRed;
    ACanvas.FillRect(R);
  end;

  // Main body
  ACanvas.Brush.Color := clBlack;
  ACanvas.Pen.Color := clBlack;
  ACanvas.Ellipse(CenterX - Radius, CenterY - Radius, CenterX + Radius, CenterY + Radius);

  // Simple "spikes"
  ACanvas.Pen.Width := Max(1, R.Width div 12);
  ACanvas.MoveTo(CenterX, R.Top + 2); ACanvas.LineTo(CenterX, R.Bottom - 2); // Vertical
  ACanvas.MoveTo(R.Left + 2, CenterY); ACanvas.LineTo(R.Right - 2, CenterY); // Horizontal
  ACanvas.MoveTo(R.Left + 3, R.Top + 3); ACanvas.LineTo(R.Right - 3, R.Bottom - 3); // Diagonal
  ACanvas.MoveTo(R.Left + 3, R.Bottom - 3); ACanvas.LineTo(R.Right - 3, R.Top + 3); // Diagonal
  ACanvas.Pen.Width := 1; // Reset pen width

  // Optional center highlight
  ACanvas.Brush.Color := clWhite;
  ACanvas.Pen.Color := clWhite;
  ACanvas.Ellipse(CenterX - SmallRadius, CenterY - SmallRadius, CenterX + SmallRadius, CenterY + SmallRadius);

end;

// Draws a Mine with a Red X over it
procedure TMainForm.DrawWrongMine(ACanvas: TCanvas; R: TRect);
begin
  // Draw the regular mine first
  DrawMine(ACanvas, R, False);

  // Draw Red X
  ACanvas.Pen.Color := clRed;
  ACanvas.Pen.Width := Max(2, R.Width div 8); // Thicker X
  ACanvas.MoveTo(R.Left + 2, R.Top + 2);
  ACanvas.LineTo(R.Right - 2, R.Bottom - 2);
  ACanvas.MoveTo(R.Left + 2, R.Bottom - 2);
  ACanvas.LineTo(R.Right - 2, R.Top + 2);
  ACanvas.Pen.Width := 1; // Reset
end;

// The main replacement for DrawTile using a bitmap strip
procedure TMainForm.DrawTilePrimitive(ACanvas: TCanvas; DestRect: TRect; TileIndex: Integer);
var
  NumStr: string;
  NumColor: TColor;
  TextRect: TRect;
  TextWidth, TextHeight: Integer;
  OldBkMode: Integer;
begin
  // Common setup
  ACanvas.Font.Name := 'Arial'; // Or Tahoma
  ACanvas.Font.Size := Max(8, DestRect.Height * 2 div 4); // Scale font size
  ACanvas.Font.Style := [fsBold];
  TextRect := DestRect; // Copy rect for text centering

  case TileIndex of
    TILE_COVERED:
      begin
        ACanvas.Brush.Color := clBtnFace;
        ACanvas.FillRect(DestRect);
        DrawBevel(ACanvas, DestRect, BEVEL_WIDTH, True); // Raised
      end;
    TILE_FLAG:
      begin
        // Draw covered base first
        ACanvas.Brush.Color := clBtnFace;
        ACanvas.FillRect(DestRect);
        DrawBevel(ACanvas, DestRect, BEVEL_WIDTH, True);
        // Draw flag on top
{HANDMODIFIED WAS
        DrawFlag(ACanvas, InflateRect(DestRect, -BEVEL_WIDTH-1, -BEVEL_WIDTH-1));
}
        InflateRect(DestRect, -BEVEL_WIDTH-1, -BEVEL_WIDTH-1);
        DrawFlag(ACanvas, DestRect);
      end;
    TILE_0: // Revealed empty cell
      begin
        ACanvas.Brush.Color := clSilver; // Or a slightly darker gray
        ACanvas.FillRect(DestRect);
        DrawBevel(ACanvas, DestRect, 1, False); // Sunken slightly
      end;
    TILE_1..TILE_8:
      begin
        // Draw sunken base
        ACanvas.Brush.Color := clSilver;
        ACanvas.FillRect(DestRect);
        DrawBevel(ACanvas, DestRect, 1, False); // Sunken slightly

        // Determine Number Color
        case TileIndex of
          TILE_1: NumColor := clBlue;
          TILE_2: NumColor := TColor($008000); // Dark Green
          TILE_3: NumColor := clRed;
          TILE_4: NumColor := TColor($800000); // Dark Blue (Navy)
          TILE_5: NumColor := TColor($000080); // Maroon
          TILE_6: NumColor := TColor($808000); // Teal
          TILE_7: NumColor := clBlack;
          TILE_8: NumColor := clGray;
        else
          NumColor := clBlack;
        end;

        NumStr := IntToStr(TileIndex - TILE_0);
        ACanvas.Font.Color := NumColor;

        // Center Text
        TextWidth := ACanvas.TextWidth(NumStr);
        TextHeight := ACanvas.TextHeight(NumStr);
        TextRect.Left := DestRect.Left + (DestRect.Width - TextWidth) div 2;
        TextRect.Top := DestRect.Top + (DestRect.Height - TextHeight) div 2;

        OldBkMode := SetBkMode(ACanvas.Handle, TRANSPARENT); // Draw text transparently
        ACanvas.TextRect(TextRect, TextRect.Left, TextRect.Top, NumStr);
        SetBkMode(ACanvas.Handle, OldBkMode); // Restore background mode
      end;
    TILE_MINE:
      begin
        ACanvas.Brush.Color := clSilver; // Background for non-hit mine shown at end
        ACanvas.FillRect(DestRect);
        DrawBevel(ACanvas, DestRect, 1, False);
{HANDMODIFIED WAS
        DrawMine(ACanvas, InflateRect(DestRect, -2, -2));
}
        InflateRect(DestRect, -2, -2);
        DrawMine(ACanvas, DestRect);
      end;
    TILE_MINE_HIT:
      begin
        // Base is already drawn by DrawMine with IsHit=True
        DrawMine(ACanvas, DestRect, True);
      end;
    TILE_MINE_WRONG:
       begin
        ACanvas.Brush.Color := clSilver;
        ACanvas.FillRect(DestRect);
        DrawBevel(ACanvas, DestRect, 1, False);
{HANDMODIFIED WAS
        DrawWrongMine(ACanvas, InflateRect(DestRect, -2, -2));
}
        InflateRect(DestRect, -2, -2);
        DrawWrongMine(ACanvas, DestRect);
       end;
    // TILE_QUESTION: // Optional implementation
    //   begin
    //     // Draw covered tile base
    //     ACanvas.Brush.Color := clBtnFace;
    //     ACanvas.FillRect(DestRect);
    //     DrawBevel(ACanvas, DestRect, BEVEL_WIDTH, True);
    //     // Draw '?'
    //     ACanvas.Font.Color := clBlack;
    //     NumStr := '?';
    //     TextWidth := ACanvas.TextWidth(NumStr);
    //     TextHeight := ACanvas.TextHeight(NumStr);
    //     TextRect.Left := DestRect.Left + (DestRect.Width - TextWidth) div 2;
    //     TextRect.Top := DestRect.Top + (DestRect.Height - TextHeight) div 2;
    //     OldBkMode := SetBkMode(ACanvas.Handle, TRANSPARENT);
    //     ACanvas.TextRect(TextRect, TextRect.Left, TextRect.Top, NumStr);
    //     SetBkMode(ACanvas.Handle, OldBkMode);
    //   end;

  else // Should not happen, draw as covered
      begin
        ACanvas.Brush.Color := clBtnFace;
        ACanvas.FillRect(DestRect);
        DrawBevel(ACanvas, DestRect, BEVEL_WIDTH, True); // Raised
      end;
  end; // case
end;


procedure TMainForm.DrawSmileyFace(ACanvas: TCanvas; DestRect: TRect; State: TSmileyState);
var
  CenterX, CenterY, Radius, EyeRadius, EyeOffsetX, EyeY: Integer;
  MouthRect: TRect;
  Angle1, Angle2: Integer; // For Arc
begin
  CenterX := DestRect.Left + DestRect.Width div 2;
  CenterY := DestRect.Top + DestRect.Height div 2;
  Radius := Min(DestRect.Width, DestRect.Height) * 9 div 20; // 90% of half size
  EyeRadius := Max(1, Radius div 5);
  EyeOffsetX := Radius * 2 div 5;
  EyeY := CenterY - Radius * 1 div 5;

  // Background / Bevel
  ACanvas.Brush.Color := clBtnFace;
  ACanvas.FillRect(DestRect);
  DrawBevel(ACanvas, DestRect, BEVEL_WIDTH, True); // Raised button look

  // Head
  ACanvas.Brush.Color := clYellow;
  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Width := 1;
  ACanvas.Ellipse(CenterX - Radius, CenterY - Radius, CenterX + Radius, CenterY + Radius);

  // Eyes
  ACanvas.Brush.Color := clBlack;
  if State = ssLost then // X Eyes
  begin
    ACanvas.Pen.Width := Max(1, EyeRadius);
    // Left X
    ACanvas.MoveTo(CenterX - EyeOffsetX - EyeRadius, EyeY - EyeRadius);
    ACanvas.LineTo(CenterX - EyeOffsetX + EyeRadius, EyeY + EyeRadius);
    ACanvas.MoveTo(CenterX - EyeOffsetX + EyeRadius, EyeY - EyeRadius);
    ACanvas.LineTo(CenterX - EyeOffsetX - EyeRadius, EyeY + EyeRadius);
    // Right X
    ACanvas.MoveTo(CenterX + EyeOffsetX - EyeRadius, EyeY - EyeRadius);
    ACanvas.LineTo(CenterX + EyeOffsetX + EyeRadius, EyeY + EyeRadius);
    ACanvas.MoveTo(CenterX + EyeOffsetX + EyeRadius, EyeY - EyeRadius);
    ACanvas.LineTo(CenterX + EyeOffsetX - EyeRadius, EyeY + EyeRadius);
    ACanvas.Pen.Width := 1;
  end
  else // Normal round eyes (or sunglasses for Win)
  begin
     if State = ssWin then // Sunglasses
     begin
        ACanvas.Brush.Color := clBlack;
        ACanvas.Pen.Color := clBlack;
        ACanvas.Rectangle(CenterX - EyeOffsetX - EyeRadius*2, EyeY - EyeRadius,
                         CenterX - EyeOffsetX + EyeRadius*2, EyeY + EyeRadius);
        ACanvas.Rectangle(CenterX + EyeOffsetX - EyeRadius*2, EyeY - EyeRadius,
                         CenterX + EyeOffsetX + EyeRadius*2, EyeY + EyeRadius);
        // Bridge
        ACanvas.MoveTo(CenterX - EyeOffsetX + EyeRadius*2, EyeY);
        ACanvas.LineTo(CenterX + EyeOffsetX - EyeRadius*2, EyeY);
     end
     else // Round eyes
     begin
       ACanvas.Ellipse(CenterX - EyeOffsetX - EyeRadius, EyeY - EyeRadius, CenterX - EyeOffsetX + EyeRadius, EyeY + EyeRadius); // Left Eye
       ACanvas.Ellipse(CenterX + EyeOffsetX - EyeRadius, EyeY - EyeRadius, CenterX + EyeOffsetX + EyeRadius, EyeY + EyeRadius); // Right Eye
     end;
  end;

  // Mouth
  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Width := Max(1, EyeRadius);
  MouthRect := Rect(CenterX - Radius * 3 div 5, CenterY + Radius * 1 div 5,
                   CenterX + Radius * 3 div 5, CenterY + Radius * 4 div 5);

  case State of
    ssNormal, ssWin: // Smile
      begin
        Angle1 := 0; Angle2 := 180; // Bottom half of ellipse for smile
        ACanvas.Arc(MouthRect.Left, MouthRect.Top, MouthRect.Right, MouthRect.Bottom,
                   MouthRect.Right, MouthRect.Top + MouthRect.Height div 2, // Start point on right
                   MouthRect.Left, MouthRect.Top + MouthRect.Height div 2); // End point on left
      end;
    ssOoh: // O shape
      begin
         ACanvas.Brush.Style := bsClear; // Hollow mouth
         ACanvas.Ellipse(MouthRect.Left + EyeRadius, MouthRect.Top, MouthRect.Right - EyeRadius, MouthRect.Bottom);
         ACanvas.Brush.Style := bsSolid;
      end;
    ssLost: // Frown
      begin
        Angle1 := 180; Angle2 := 360; // Top half of ellipse for frown
        ACanvas.Arc(MouthRect.Left, MouthRect.Top - Radius div 3, MouthRect.Right, MouthRect.Bottom - Radius div 3, // Shift up a bit
                   MouthRect.Left, MouthRect.Top + MouthRect.Height div 2 - Radius div 3, // Start point on left
                   MouthRect.Right, MouthRect.Top + MouthRect.Height div 2 - Radius div 3); // End point on right
      end;
  end;
  ACanvas.Pen.Width := 1; // Reset pen
end;

// --- Intro/Win/Loss Screen Drawing ---

procedure TMainForm.DrawIntroScreen(ACanvas: TCanvas; Width, Height: Integer; Step: Integer);
var
  R: TRect;
  MidX, MidY: Integer;
  Title: string;
  SubText: string;
  Alpha: Byte; // For fading effect
begin
  MidX := Width div 2;
  MidY := Height div 2;
  Title := 'MINESWEEPER DELPHI';
  SubText := 'Click to Start';

  // Background (Could animate color change based on Step)
  ACanvas.Brush.Color := TColor($00A06000); // Darkish Blue/Green
  ACanvas.FillRect(Rect(0, 0, Width, Height));

  // Simple Animation: Text Fade In (Example)
  Alpha := Min(255, Step * 10); // Fade over ~25 steps

  // Title Text
  ACanvas.Font.Name := 'Impact'; // Or another bold font
  ACanvas.Font.Size := Max(18, Height div 10);
  ACanvas.Font.Color := TColor( $FFFFFF or (Alpha shl 24) ); // White with alpha
  ACanvas.Font.Style := [fsBold];
  R := Rect(0, 0, Width, MidY);
  ACanvas.Brush.Style := bsClear; // Transparent background for text
  DrawText(ACanvas.Handle, Title, Length(Title), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

  // Sub Text
  ACanvas.Font.Name := 'Arial';
  ACanvas.Font.Size := Max(10, Height div 25);
  ACanvas.Font.Color := TColor( $D0D0D0 or (Alpha shl 24) ); // Light Gray with alpha
  ACanvas.Font.Style := [];
  R := Rect(0, MidY, Width, Height - 20);
  DrawText(ACanvas.Handle, SubText, Length(SubText), R, DT_CENTER or DT_TOP or DT_SINGLELINE);

  ACanvas.Brush.Style := bsSolid; // Reset brush
end;

procedure TMainForm.DrawWinScreen(ACanvas: TCanvas; Width, Height: Integer; Step: Integer);
var
  R: TRect;
  MidX, MidY: Integer;
  Msg: string;
  PulseColor: TColor;
  ScoreText: string;
  ElapsedTime: Int64;
begin
  MidX := Width div 2;
  MidY := Height div 2;
  Msg := 'YOU WIN!';

  // Pulsating Background (Example Animation)
  // Simple sine wave for color pulse (adjust frequency/amplitude)
  PulseColor := TColor( Round(100 + 80 * Sin(Step * 0.2)) shl 8 ); // Pulsing Green
  ACanvas.Brush.Color := PulseColor;
  ACanvas.FillRect(Rect(0, 0, Width, Height));

  // Win Text
  ACanvas.Font.Name := 'Impact';
  ACanvas.Font.Size := Max(24, Height div 8);
  ACanvas.Font.Color := clWhite;
  ACanvas.Font.Style := [fsBold];
  R := Rect(0, 0, Width, MidY + 20);
  ACanvas.Brush.Style := bsClear;
  DrawText(ACanvas.Handle, Msg, Length(Msg), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

  // Show Score
  if FEndTime > FStartTime then // Ensure times are valid
     ElapsedTime := SecondsBetween(FEndTime, FStartTime)
  else
     ElapsedTime := 0;
  ScoreText := Format('Time: %d seconds', [ElapsedTime]);
  ACanvas.Font.Name := 'Arial';
  ACanvas.Font.Size := Max(12, Height div 20);
  ACanvas.Font.Color := clYellow;
  ACanvas.Font.Style := [];
  R := Rect(0, MidY + 20, Width, Height - 20);
  DrawText(ACanvas.Handle, ScoreText, Length(ScoreText), R, DT_CENTER or DT_TOP or DT_SINGLELINE);

  ACanvas.Brush.Style := bsSolid;
end;

procedure TMainForm.DrawLossScreen(ACanvas: TCanvas; Width, Height: Integer; Step: Integer);
var
  R: TRect;
  MidX, MidY: Integer;
  Msg: string;
  FlashColor: TColor;
begin
  MidX := Width div 2;
  MidY := Height div 2;
  Msg := 'GAME OVER!';

  // Flashing Background (Example Animation)
  if Odd(Step div 5) then // Flash every 5 steps
     FlashColor := clRed
  else
     FlashColor := TColor($0000A0); // Dark Red

  ACanvas.Brush.Color := FlashColor;
  ACanvas.FillRect(Rect(0, 0, Width, Height));

  // Text
  ACanvas.Font.Name := 'Impact';
  ACanvas.Font.Size := Max(24, Height div 8);
  ACanvas.Font.Color := clWhite;
  ACanvas.Font.Style := [fsBold];
  R := Rect(0, 0, Width, Height);
  ACanvas.Brush.Style := bsClear;
  DrawText(ACanvas.Handle, Msg, Length(Msg), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

  ACanvas.Brush.Style := bsSolid;
end;


// --- Helper to Ensure TImage Bitmaps Exist ---
procedure TMainForm.EnsureImageBitmaps;
begin
  // Ensure imgBoard bitmap exists and has correct size
  if not Assigned(imgBoard.Picture.Bitmap) then
    imgBoard.Picture.Bitmap := TBitmap.Create;
  if (imgBoard.Picture.Bitmap.Width <> imgBoard.Width) or (imgBoard.Picture.Bitmap.Height <> imgBoard.Height) then
    imgBoard.Picture.Bitmap.SetSize(imgBoard.Width, imgBoard.Height);

  // Ensure imgSmiley bitmap exists and has correct size
  if not Assigned(imgSmiley.Picture.Bitmap) then
    imgSmiley.Picture.Bitmap := TBitmap.Create;
   if (imgSmiley.Picture.Bitmap.Width <> imgSmiley.Width) or (imgSmiley.Picture.Bitmap.Height <> imgSmiley.Height) then
     imgSmiley.Picture.Bitmap.SetSize(imgSmiley.Width, imgSmiley.Height);

  // Ensure imgOverlay bitmap exists and has correct size
  if not Assigned(imgOverlay.Picture.Bitmap) then
     imgOverlay.Picture.Bitmap := TBitmap.Create;
  if (imgOverlay.Picture.Bitmap.Width <> imgOverlay.Width) or (imgOverlay.Picture.Bitmap.Height <> imgOverlay.Height) then
     imgOverlay.Picture.Bitmap.SetSize(imgOverlay.Width, imgOverlay.Height);
end;

// --- Game Setup ---

procedure TMainForm.SetupGame(ADifficulty: TDifficulty);
const
  TOP_MARGIN = 5; // Space above smiley
  SMILEY_BOARD_GAP = 10; // Space between smiley and board
  BOTTOM_MARGIN = 10; // Space below board
begin
  GameTimer.Enabled := False;
  AnimationTimer.Enabled := False;

  FCurrentDifficulty := ADifficulty;
  SetDifficultyCheckmark(ADifficulty);

  case ADifficulty of
    dEasy:   begin FGridWidth := 9;  FGridHeight := 9;  FMineCount := 10; end;
    dMedium: begin FGridWidth := 16; FGridHeight := 16; FMineCount := 40; end;
    dHard:   begin FGridWidth := 30; FGridHeight := 16; FMineCount := 99; end;
  else
    begin FGridWidth := 9;  FGridHeight := 9;  FMineCount := 10; end;
  end;

  // Adjust image sizes based on CELL SIZE
  imgBoard.Width := FGridWidth * FCellSize;
  imgBoard.Height := FGridHeight * FCellSize;
  // Use fixed smiley size set in DFM or FormCreate
  // imgSmiley.Width := FCellSize * 2; // Or keep fixed DFM size
  // imgSmiley.Height := FCellSize * 2;

  // Position smiley near top of client area
  imgSmiley.Top := TOP_MARGIN;
  // Position board below smiley
  imgBoard.Top := imgSmiley.Top + imgSmiley.Height + SMILEY_BOARD_GAP;

  // Calculate required client dimensions
  Self.ClientWidth := Max(imgBoard.Width + 40, imgSmiley.Left + imgSmiley.Width + 20); // Ensure wide enough for board+padding or smiley
  Self.ClientHeight := imgBoard.Top + imgBoard.Height + StatusBar1.Height + BOTTOM_MARGIN; // Height based on elements + status bar + margins

  EnsureImageBitmaps; // Create/resize backing bitmaps
  CenterBoard;        // Center controls horizontally and verify vertical positions

  InitializeGrid;
  FGameState := gsReady;
  FFirstClick := True;
  FRevealedCount := 0;
  FFlagsPlaced := 0;
  FGameLostMineX := -1;
  FGameLostMineY := -1;
  FCurrentSmileyState := ssNormal; // Reset smiley state

  imgOverlay.Visible := False;

  UpdateSmiley;
  UpdateStatusBar;
  DrawBoard; // Initial draw
end;

procedure TMainForm.CenterBoard;
const
  TOP_MARGIN = 5; // Consistent margin (must match SetupGame or be passed)
  SMILEY_BOARD_GAP = 10; // Consistent gap
begin
  // Center Smiley horizontally, position near top
  imgSmiley.Left := Max(5, (Self.ClientWidth - imgSmiley.Width) div 2);
  imgSmiley.Top := TOP_MARGIN; // Use constant margin from top

  // Center imgBoard horizontally, position below smiley
  imgBoard.Left := Max(5, (Self.ClientWidth - imgBoard.Width) div 2);
  imgBoard.Top := imgSmiley.Top + imgSmiley.Height + SMILEY_BOARD_GAP; // Position below updated smiley position

  // Make overlay cover the client area
  imgOverlay.BoundsRect := Self.ClientRect;
end;
// InitializeGrid, PlaceMines, CalculateAdjacentMines remain the same internally

procedure TMainForm.InitializeGrid;
var x,y: Integer;
begin
  SetLength(FGrid, FGridWidth, FGridHeight);
  for x := 0 to FGridWidth - 1 do
  begin
    for y := 0 to FGridHeight - 1 do
    begin
      FGrid[x, y].IsMine := False;
      FGrid[x, y].IsRevealed := False;
      FGrid[x, y].IsFlagged := False;
      FGrid[x, y].AdjacentMines := 0;
    end;
  end;
end;

procedure TMainForm.PlaceMines(ExcludeX, ExcludeY: Integer);
var MinesToPlace, x,y : Integer;
begin
  MinesToPlace := FMineCount;
  while MinesToPlace > 0 do
  begin
    x := Random(FGridWidth);
    y := Random(FGridHeight);

    if not FGrid[x, y].IsMine and not ((x = ExcludeX) and (y = ExcludeY)) then
    begin
      FGrid[x, y].IsMine := True;
      Dec(MinesToPlace);
    end;
  end;
end;

procedure TMainForm.CalculateAdjacentMines;
var x,y,i,j,nx,ny, count: Integer;
begin
  for x := 0 to FGridWidth - 1 do
  begin
    for y := 0 to FGridHeight - 1 do
    begin
      if not FGrid[x, y].IsMine then
      begin
        count := 0;
        for i := -1 to 1 do
        begin
          for j := -1 to 1 do
          begin
            if (i = 0) and (j = 0) then continue;
            nx := x + i;
            ny := y + j;
            if IsValidCoord(nx, ny) and FGrid[nx, ny].IsMine then
            begin
              Inc(count);
            end;
          end;
        end;
        FGrid[x, y].AdjacentMines := count;
      end;
    end;
  end;
end;

// --- Drawing ---

procedure TMainForm.DrawBoard;
var
  x, y: Integer;
begin
  EnsureImageBitmaps; // Make sure bitmap exists and is sized correctly
  if imgBoard.Picture.Bitmap.Empty then Exit;

  // Clear background (optional, primitives usually cover)
  // imgBoard.Picture.Bitmap.Canvas.Brush.Color := clWhite;
  // imgBoard.Picture.Bitmap.Canvas.FillRect(Rect(0, 0, imgBoard.Width, imgBoard.Height));

  for x := 0 to FGridWidth - 1 do
  begin
    for y := 0 to FGridHeight - 1 do
    begin
      DrawCell(imgBoard.Picture.Bitmap.Canvas, x, y);
    end;
  end;

  imgBoard.Invalidate; // Refresh the image control
end;

procedure TMainForm.DrawCell(ACanvas: TCanvas; GridX, GridY: Integer);
var
  DestRect: TRect;
  TileIndex: Integer;
begin
  DestRect := Rect(GridX * FCellSize, GridY * FCellSize,
                   (GridX + 1) * FCellSize, (GridY + 1) * FCellSize);
  TileIndex := GetTileIndex(GridX, GridY);
  DrawTilePrimitive(ACanvas, DestRect, TileIndex);
end;

// GetTileIndex logic remains the same

function TMainForm.GetTileIndex(GridX, GridY: Integer): Integer;
begin
  Result := TILE_COVERED; // Default

  if (FGameState = gsLost) or (FGameState = gsWon) then
  begin // Game Over states - reveal everything
    if FGrid[GridX, GridY].IsMine then
    begin
      if FGrid[GridX, GridY].IsFlagged then
        Result := TILE_FLAG // Show flag even if mine (consistent view)
      else if (GridX = FGameLostMineX) and (GridY = FGameLostMineY) then
        Result := TILE_MINE_HIT // The one that exploded
      else
        Result := TILE_MINE; // Unflagged mine
    end
    else // Not a mine
    begin
      if FGrid[GridX, GridY].IsFlagged then
        Result := TILE_MINE_WRONG // Incorrectly flagged
      else if FGrid[GridX, GridY].IsRevealed then // Check if it was revealed during play
         Result := TILE_0 + FGrid[GridX, GridY].AdjacentMines
      else // If not revealed (only possible in win scenario?), show base
         Result := TILE_0;
    end;
  end
  else // Game is playing or ready
  begin
    if FGrid[GridX, GridY].IsFlagged then
      Result := TILE_FLAG
    else if FGrid[GridX, GridY].IsRevealed then
    begin
      if FGrid[GridX, GridY].IsMine then // Should not happen
         Result := TILE_MINE_HIT
      else
         Result := TILE_0 + FGrid[GridX, GridY].AdjacentMines;
    end
    else // Still covered
      Result := TILE_COVERED;
     // Optional: Add Question Mark state TILE_QUESTION
  end;
end;


// --- Game Logic (Input, Reveal, Win/Loss Check) ---
// imgBoardMouseDown, RevealCell, FloodFill, CheckWinCondition, GameOver logic largely unchanged,
// but drawing calls inside them might update differently.

procedure TMainForm.imgBoardMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var GridX, GridY: Integer;
begin
  if not (FGameState in [gsReady, gsPlaying]) then Exit;

  GridX := X div FCellSize;
  GridY := Y div FCellSize;

  if not IsValidCoord(GridX, GridY) then Exit;

  if Button = mbLeft then
  begin
    UpdateSmiley(True); // Show Ooh face

    // Need to PumpMessages to allow smiley redraw before potential long operation (like flood fill)
    Application.ProcessMessages; // Use with caution, can cause re-entrancy issues if not careful

    if FGrid[GridX, GridY].IsRevealed or FGrid[GridX, GridY].IsFlagged then
    begin
      UpdateSmiley(False); // Back to normal/win/lost state
      Exit;
    end;

    if FFirstClick then
    begin
      FFirstClick := False;
      PlaceMines(GridX, GridY);
      CalculateAdjacentMines;
      FStartTime := Now;
      GameTimer.Enabled := True;
      FGameState := gsPlaying;
    end;

    if FGrid[GridX, GridY].IsMine then
    begin
      FGameLostMineX := GridX;
      FGameLostMineY := GridY;
      GameOver(False);
    end
    else
    begin
      RevealCell(GridX, GridY); // This will call DrawBoard indirectly
      // DrawBoard; // Redraw AFTER revealing
      if FGameState = gsPlaying then
         CheckWinCondition;
    end;
     // Update smiley based on game state *after* action potentially changes it
     UpdateSmiley(False);
  end
  else if Button = mbRight then // Right Click for Flag
  begin
    if not FGrid[GridX, GridY].IsRevealed then
    begin
      FGrid[GridX, GridY].IsFlagged := not FGrid[GridX, GridY].IsFlagged;
      if FGrid[GridX, GridY].IsFlagged then
        Inc(FFlagsPlaced)
      else
        Dec(FFlagsPlaced);

      // Redraw only the affected cell directly onto the bitmap buffer
      DrawCell(imgBoard.Picture.Bitmap.Canvas, GridX, GridY);
      imgBoard.Invalidate; // Make the change visible

      UpdateStatusBar;
    end;
  end;
  // No need for final UpdateSmiley here as left click handles it, right click doesn't change smiley state.
end;

procedure TMainForm.RevealCell(GridX, GridY: Integer);
var NeedsRedraw: Boolean;
begin
  if not IsValidCoord(GridX, GridY) then Exit;
  if FGrid[GridX, GridY].IsRevealed then Exit;
  if FGrid[GridX, GridY].IsFlagged then Exit;

  FGrid[GridX, GridY].IsRevealed := True;
  Inc(FRevealedCount);
  NeedsRedraw := True;

  // If it was an empty cell (0 adjacent mines), reveal neighbors
  if FGrid[GridX, GridY].AdjacentMines = 0 then
  begin
    FloodFill(GridX, GridY); // FloodFill might call RevealCell recursively
    NeedsRedraw := False; // FloodFill likely caused redraws, avoid redundant full DrawBoard
  end;

  // If FloodFill didn't happen, or for the initial non-zero cell reveal
  if NeedsRedraw then
  begin
     // Instead of full DrawBoard, just draw the revealed cell
     // DrawCell(imgBoard.Picture.Bitmap.Canvas, GridX, GridY);
     // imgBoard.Invalidate;
     // Optimization: Often better to just redraw the whole board after reveals
     DrawBoard;
  end;
end;

procedure TMainForm.FloodFill(GridX, GridY: Integer);
var i, j, nx, ny: Integer;
begin
  // Non-recursive version to avoid stack overflow on huge empty areas
  // Using a simple recursive one here for brevity, be mindful of deep recursion potential
  for i := -1 to 1 do
  begin
    for j := -1 to 1 do
    begin
      if (i = 0) and (j = 0) then Continue;
      nx := GridX + i;
      ny := GridY + j;
      // Check bounds and if the neighbor should be revealed
      if IsValidCoord(nx, ny) and
         not FGrid[nx, ny].IsRevealed and
         not FGrid[nx, ny].IsFlagged then
      begin
         RevealCell(nx, ny); // Recursive call
      end;
    end;
  end;
  // After flood fill completes, ensure the board is fully updated
  DrawBoard;
end;

procedure TMainForm.CheckWinCondition;
begin
  if FRevealedCount = (FGridWidth * FGridHeight - FMineCount) then
  begin
     if FGameState = gsPlaying then // Only trigger win if currently playing
        GameOver(True);
  end;
end;

procedure TMainForm.GameOver(Win: Boolean);
begin
  GameTimer.Enabled := False;
  FEndTime := Now;

  // Final board state reveal happens as part of animations or immediately before overlay
  if Win then
  begin
    // Auto-flag remaining mines on win
    // for x := 0 to FGridWidth - 1 do
    //   for y := 0 to FGridHeight - 1 do
    //     if FGrid[x,y].IsMine and not FGrid[x,y].IsFlagged then
    //       FGrid[x,y].IsFlagged := True;
    FFlagsPlaced := FMineCount; // Set flag count correctly for display
    FGameState := gsWon; // Set state BEFORE starting animation
    UpdateSmiley;
    UpdateStatusBar; // Update flags/time display
    StartWinAnimation;
  end
  else // Lost
  begin
    FGameState := gsLost; // Set state BEFORE starting animation
    UpdateSmiley;
    UpdateStatusBar;
    StartLossAnimation;
  end;
end;

// --- UI Updates ---

procedure TMainForm.UpdateStatusBar;
var ElapsedTime: Int64;
begin
  StatusBar1.Panels[0].Text := Format('Mines: %d', [FMineCount - FFlagsPlaced]);

  if FGameState = gsPlaying then
  begin
    ElapsedTime := Max(0, SecondsBetween(Now, FStartTime)); // Prevent negative if clock changes
    StatusBar1.Panels[1].Text := Format('Time: %d', [ElapsedTime]);
  end
  else if FGameState in [gsReady, gsIntro] then
  begin
     StatusBar1.Panels[1].Text := 'Time: 0';
  end
{HANDMODIFIED WAS
  else if FGameState in [gsWon, gsLost] and (FEndTime > FStartTime) then
}
  else if (FGameState in [gsWon, gsLost]) and (FEndTime > FStartTime) then
  begin
     ElapsedTime := SecondsBetween(FEndTime, FStartTime);
     StatusBar1.Panels[1].Text := Format('Time: %d', [ElapsedTime]);
  end;
end;

procedure TMainForm.UpdateSmiley(Scared: Boolean = False);
var NewState: TSmileyState;
begin
   NewState := ssNormal; // Default

   // Determine desired state
   case FGameState of
     gsPlaying, gsReady:
        if Scared then NewState := ssOoh else NewState := ssNormal;
     gsWon: NewState := ssWin;
     gsLost: NewState := ssLost;
     gsAnimating: NewState := FCurrentSmileyState; // Keep current state during animation
   else // Intro
     NewState := ssNormal;
   end;

   // Only redraw if state changes
   if NewState <> FCurrentSmileyState then
   begin
     FCurrentSmileyState := NewState;
     EnsureImageBitmaps; // Make sure smiley bitmap exists
     DrawSmileyFace(imgSmiley.Picture.Bitmap.Canvas, imgSmiley.ClientRect, FCurrentSmileyState);
     imgSmiley.Invalidate;
   end
   // Handle the temporary 'Ooh' state during click
   else if (FCurrentSmileyState = ssNormal) and Scared then
   begin
      // Temporarily draw Ooh without changing FCurrentSmileyState permanently
     EnsureImageBitmaps;
     DrawSmileyFace(imgSmiley.Picture.Bitmap.Canvas, imgSmiley.ClientRect, ssOoh);
     imgSmiley.Invalidate;
   end
   else if (FCurrentSmileyState = ssOoh) and not Scared then
   begin
       // Revert from temporary Ooh back to the actual FCurrentSmileyState (should be Normal)
     EnsureImageBitmaps;
     DrawSmileyFace(imgSmiley.Picture.Bitmap.Canvas, imgSmiley.ClientRect, FCurrentSmileyState);
     imgSmiley.Invalidate;
   end;
end;

procedure TMainForm.SetDifficultyCheckmark(ADifficulty: TDifficulty);
begin
  EasyItem.Checked := (ADifficulty = dEasy);
  MediumItem.Checked := (ADifficulty = dMedium);
  HardItem.Checked := (ADifficulty = dHard);
end;

// --- Event Handlers ---

procedure TMainForm.GameTimerTimer(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TMainForm.NGameClick(Sender: TObject);
begin
  SetupGame(FCurrentDifficulty);
end;

procedure TMainForm.EasyItemClick(Sender: TObject);
begin SetupGame(dEasy); end;
procedure TMainForm.MediumItemClick(Sender: TObject);
begin SetupGame(dMedium); end;
procedure TMainForm.HardItemClick(Sender: TObject);
begin SetupGame(dHard); end;

procedure TMainForm.ExitItemClick(Sender: TObject);
begin Close; end;

procedure TMainForm.imgSmileyClick(Sender: TObject);
begin SetupGame(FCurrentDifficulty); end;

procedure TMainForm.imgOverlayClick(Sender: TObject);
begin
  // Clicking overlay always starts a new game if in intro/win/loss state
  if FGameState in [gsIntro, gsWon, gsLost] then
  begin
     AnimationTimer.Enabled := False; // Stop any ongoing animation
     imgOverlay.Visible := False;
     SetupGame(FCurrentDifficulty);
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  // CenterBoard handles repositioning based on new ClientWidth/Height
  CenterBoard;

  // If overlay is visible, ensure its bitmap is resized and redrawn
  if imgOverlay.Visible then
  begin
     EnsureImageBitmaps; // Ensure bitmap exists and fits new size
     // Redraw overlay content based on current state
     case FGameState of
       gsIntro: DrawIntroScreen(imgOverlay.Picture.Bitmap.Canvas, imgOverlay.Width, imgOverlay.Height, 999); // Draw final frame
       gsWon: DrawWinScreen(imgOverlay.Picture.Bitmap.Canvas, imgOverlay.Width, imgOverlay.Height, 999);
       gsLost: DrawLossScreen(imgOverlay.Picture.Bitmap.Canvas, imgOverlay.Width, imgOverlay.Height, 999);
     end;
     imgOverlay.Invalidate;
  end;
  // Optional: Might need to call DrawBoard if board size relative to form changed significantly
  // DrawBoard;
end;

// --- OnPaint handlers (Optional alternative to direct bitmap drawing) ---
// If you prefer, you can draw directly in OnPaint events instead of
// managing the Picture.Bitmap manually. Remove EnsureImageBitmaps and
// drawing to Picture.Bitmap if using OnPaint.

procedure TMainForm.imgBoardPaint(Sender: TObject);
begin
// If using OnPaint:
//  var x,y:Integer;
//  for x := 0 to FGridWidth - 1 do
//    for y := 0 to FGridHeight - 1 do
//      DrawCell(imgBoard.Canvas, x, y);
end;

procedure TMainForm.imgSmileyPaint(Sender: TObject);
begin
  // If using OnPaint:
  // DrawSmileyFace(imgSmiley.Canvas, imgSmiley.ClientRect, FCurrentSmileyState);
end;

// --- Animation Handling ---

procedure TMainForm.StartIntro;
begin
  FGameState := gsIntro;
  GameTimer.Enabled := False;
  FAnimationStep := 0;

  EnsureImageBitmaps; // Make sure overlay bitmap exists
  imgOverlay.Visible := True;
  imgOverlay.BringToFront;

  AnimationTimer.Interval := 50; // Animation speed
  AnimationTimer.Enabled := True;

  UpdateSmiley;
  UpdateStatusBar;
end;

procedure TMainForm.StartWinAnimation;
begin
  FGameState := gsAnimating; // Intermediate state
  FAnimationStep := 0;
  // Ensure final board state (all mines flagged) is ready for drawing if needed
  // (GetTileIndex handles showing flags correctly in gsWon state)
  DrawBoard; // Show final board state first

  EnsureImageBitmaps; // Make sure overlay bitmap exists
  imgOverlay.Visible := False; // Hide overlay initially

  AnimationTimer.Interval := 80; // Animation speed
  AnimationTimer.Enabled := True;
end;

procedure TMainForm.StartLossAnimation;
var
  x, y: Integer;
  ptr: PPoint; // Use PPoint directly
begin
  FGameState := gsAnimating;
  FAnimationStep := 0;
  FCellsToReveal.Clear; // Clear previous list if any

  // Prepare list of mine locations to reveal
  for x := 0 to FGridWidth - 1 do
    for y := 0 to FGridHeight - 1 do
      if FGrid[x, y].IsMine and not ((x = FGameLostMineX) and (y = FGameLostMineY)) then
      begin
          ptr := AllocMem(SizeOf(TPoint));
          ptr^.X := x;
          ptr^.Y := y;
          FCellsToReveal.Add(ptr);
      end;
  // Optional: Shuffle FCellsToReveal

  // Draw board showing the initially hit mine immediately
  DrawBoard; // GetTileIndex handles TILE_MINE_HIT

  EnsureImageBitmaps; // Make sure overlay bitmap exists
  imgOverlay.Visible := False; // Hide overlay initially

  AnimationTimer.Interval := 40; // Faster reveal speed
  AnimationTimer.Enabled := True;
end;

procedure TMainForm.AnimationTimerTimer(Sender: TObject);
var
  ptr: PPoint;
  pt: TPoint;
  R: TRect;
begin
  Inc(FAnimationStep);

  case FGameState of
    gsIntro:
      begin
        if FAnimationStep > 50 then // Limit intro animation duration
        begin
           AnimationTimer.Enabled := False;
           // Draw final intro frame
           DrawIntroScreen(imgOverlay.Picture.Bitmap.Canvas, imgOverlay.Width, imgOverlay.Height, FAnimationStep);
           imgOverlay.Invalidate;
        end
        else
        begin
           DrawIntroScreen(imgOverlay.Picture.Bitmap.Canvas, imgOverlay.Width, imgOverlay.Height, FAnimationStep);
           imgOverlay.Invalidate;
        end;
      end;

    gsAnimating:
      begin
        if FCurrentSmileyState = ssWin then // Win Animation
        begin
           // Example: Simple pulsing overlay or celebratory graphics
           if FAnimationStep > 30 then // Animate for ~2.4 seconds
           begin
              AnimationTimer.Enabled := False;
              FGameState := gsWon; // Set final state
              // Draw final win screen on overlay
              DrawWinScreen(imgOverlay.Picture.Bitmap.Canvas, imgOverlay.Width, imgOverlay.Height, FAnimationStep);
              imgOverlay.Visible := True;
              imgOverlay.Invalidate;
           end else
           begin
              // Could draw temporary effects on the board TImage here,
              // or start drawing the win screen progressively on the overlay.
              // For simplicity, we just wait then show the final screen.
           end;

        end
        else if FCurrentSmileyState = ssLost then // Loss Animation (Reveal Mines)
        begin
           if FCellsToReveal.Count > 0 then
           begin
               // Reveal one mine from the list
               ptr := PPoint(FCellsToReveal[0]);
               pt := ptr^;
               // Calculate rect for the cell
               R := Rect(pt.X * FCellSize, pt.Y * FCellSize, (pt.X + 1) * FCellSize, (pt.Y + 1) * FCellSize);
               // Draw the revealed mine primitive directly onto the board bitmap
               DrawTilePrimitive(imgBoard.Picture.Bitmap.Canvas, R, TILE_MINE);
               imgBoard.Invalidate; // Update display

               FreeMem(ptr);
               FCellsToReveal.Delete(0);
           end
           else // All mines revealed
           begin
               AnimationTimer.Enabled := False;
               FGameState := gsLost; // Set final state
               // Draw final loss screen on overlay after short delay?
               DrawLossScreen(imgOverlay.Picture.Bitmap.Canvas, imgOverlay.Width, imgOverlay.Height, FAnimationStep);
               imgOverlay.Visible := True;
               imgOverlay.Invalidate;
           end;
        end;
      end; // gsAnimating
  end; // case FGameState
end;


// --- Utility Functions ---

function TMainForm.IsValidCoord(GridX, GridY: Integer): Boolean;
begin
  Result := (GridX >= 0) and (GridX < FGridWidth) and
            (GridY >= 0) and (GridY < FGridHeight);
end;

end.
