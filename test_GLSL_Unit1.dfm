object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 682
  ClientWidth = 654
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 640
    Height = 480
    Caption = 'Panel1'
    TabOrder = 0
  end
  object Button3: TButton
    Left = 573
    Top = 494
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 573
    Top = 525
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 2
    OnClick = Button4Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 494
    Width = 561
    Height = 89
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object Memo2: TMemo
    Left = 8
    Top = 589
    Width = 561
    Height = 89
    Lines.Strings = (
      'Memo2')
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object OpenDialog1: TOpenDialog
    Left = 592
    Top = 560
  end
end
