object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 681
  ClientWidth = 1162
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
  object Label1: TLabel
    Left = 743
    Top = 558
    Width = 3
    Height = 13
  end
  object Label2: TLabel
    Left = 96
    Top = 525
    Width = 3
    Height = 13
  end
  object Label3: TLabel
    Left = 96
    Top = 561
    Width = 48
    Height = 13
    Caption = 'Channel 1'
  end
  object Label4: TLabel
    Left = 192
    Top = 561
    Width = 48
    Height = 13
    Caption = 'Channel 2'
  end
  object Label5: TLabel
    Left = 290
    Top = 561
    Width = 48
    Height = 13
    Caption = 'Channel 3'
  end
  object Label6: TLabel
    Left = 384
    Top = 561
    Width = 48
    Height = 13
    Caption = 'Channel 4'
  end
  object Panel1: TPanel
    Left = 7
    Top = 35
    Width = 640
    Height = 480
    Caption = 'Panel1'
    TabOrder = 0
    OnMouseMove = Panel1MouseMove
  end
  object Button3: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 572
    Top = 521
    Width = 75
    Height = 25
    Caption = 'Full screen'
    TabOrder = 2
    OnClick = Button4Click
  end
  object Memo1: TMemo
    Left = 653
    Top = 589
    Width = 501
    Height = 84
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object compile: TButton
    Left = 653
    Top = 558
    Width = 75
    Height = 25
    Caption = 'compile'
    TabOrder = 4
    OnClick = compileClick
  end
  object Button1: TButton
    Left = 8
    Top = 525
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 5
    OnClick = Button1Click
  end
  object TabControl1: TTabControl
    Left = 654
    Top = 8
    Width = 500
    Height = 544
    TabOrder = 6
    Tabs.Strings = (
      'main'
      'Common'
      'BufferA'
      'BufferB'
      'BufferC'
      'BufferD'
      'Image'
      '')
    TabIndex = 0
    object RichEdit1: TRichEdit
      Left = 3
      Top = 24
      Width = 494
      Height = 517
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        'RichEdit1')
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      Zoom = 100
    end
  end
  object Button2: TButton
    Left = 573
    Top = 8
    Width = 75
    Height = 25
    Caption = 'New'
    TabOrder = 7
    OnClick = Button2Click
  end
  object Button5: TButton
    Left = 8
    Top = 556
    Width = 75
    Height = 25
    Caption = 'Resources'
    TabOrder = 8
  end
  object Panel2: TPanel
    Left = 96
    Top = 580
    Width = 90
    Height = 90
    TabOrder = 9
  end
  object Panel3: TPanel
    Left = 194
    Top = 580
    Width = 90
    Height = 90
    TabOrder = 10
  end
  object Panel4: TPanel
    Left = 290
    Top = 580
    Width = 90
    Height = 90
    TabOrder = 11
  end
  object Panel6: TPanel
    Left = 386
    Top = 580
    Width = 90
    Height = 90
    TabOrder = 12
  end
  object OpenDialog1: TOpenDialog
    Left = 512
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 552
  end
end
