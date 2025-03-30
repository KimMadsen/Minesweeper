object MainForm: TMainForm
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  Caption = 'Minesweeper Delphi (Primitives)'
  ClientHeight = 515
  ClientWidth = 468
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 17
  object imgBoard: TImage
    Left = 30
    Top = 90
    Width = 381
    Height = 381
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    OnMouseDown = imgBoardMouseDown
  end
  object imgSmiley: TImage
    Left = 209
    Top = 30
    Width = 60
    Height = 60
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    OnClick = imgSmileyClick
  end
  object imgOverlay: TImage
    Left = 0
    Top = 0
    Width = 468
    Height = 515
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Visible = False
    OnClick = imgOverlayClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 491
    Width = 468
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <
      item
        Width = 125
      end
      item
        Width = 100
      end>
  end
  object GameTimer: TTimer
    Enabled = False
    OnTimer = GameTimerTimer
    Left = 48
    Top = 16
  end
  object AnimationTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = AnimationTimerTimer
    Left = 120
    Top = 16
  end
  object MainMenu1: TMainMenu
    Left = 192
    Top = 16
    object FileMenu: TMenuItem
      Caption = '&File'
      object NGame: TMenuItem
        Caption = '&New Game'
        ShortCut = 113
        OnClick = NGameClick
      end
      object DifficultyMenu: TMenuItem
        Caption = '&Difficulty'
        object EasyItem: TMenuItem
          Caption = '&Easy'
          Checked = True
          GroupIndex = 1
          RadioItem = True
          OnClick = EasyItemClick
        end
        object MediumItem: TMenuItem
          Caption = '&Medium'
          GroupIndex = 1
          RadioItem = True
          OnClick = MediumItemClick
        end
        object HardItem: TMenuItem
          Caption = '&Hard'
          GroupIndex = 1
          RadioItem = True
          OnClick = HardItemClick
        end
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ExitItem: TMenuItem
        Caption = 'E&xit'
        OnClick = ExitItemClick
      end
    end
  end
end
