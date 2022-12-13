object PlacePropsForm: TPlacePropsForm
  Left = 0
  Top = 0
  ClientHeight = 244
  ClientWidth = 364
  Caption = #1057#1074#1086#1081#1089#1090#1074#1072
  Constraints.MinHeight = 200
  Constraints.MinWidth = 300
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  OnCreate = UniFormCreate
  DesignSize = (
    364
    244)
  PixelsPerInch = 96
  TextHeight = 13
  object undt_Name: TUniEdit
    Left = 30
    Top = 39
    Width = 305
    Hint = ''
    Text = ''
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object unlbl_nameC: TUniLabel
    Left = 30
    Top = 20
    Width = 52
    Height = 13
    Hint = ''
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
    TabOrder = 1
  end
  object undt_plOwner: TUniEdit
    Left = 30
    Top = 103
    Width = 305
    Hint = ''
    Text = ''
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object unlbl1: TUniLabel
    Left = 30
    Top = 84
    Width = 165
    Height = 13
    Hint = ''
    Caption = #1050#1090#1086' '#1076#1086#1073#1072#1074#1080#1083', '#1060#1048#1054' '#1085#1077' '#1080#1079' '#1089#1087#1080#1089#1082#1072':'
    TabOrder = 3
  end
  object unpnl1: TUniPanel
    Left = 0
    Top = 197
    Width = 364
    Height = 47
    Hint = ''
    Align = alBottom
    TabOrder = 4
    BorderStyle = ubsFrameLowered
    Caption = ''
    DesignSize = (
      364
      47)
    object btnOk: TUniButton
      Left = 265
      Top = 10
      Width = 75
      Height = 25
      Action = act_propsOk
      Anchors = [akTop, akRight]
      TabOrder = 1
      Default = True
    end
    object btn2: TUniButton
      Left = 30
      Top = 10
      Width = 75
      Height = 25
      Hint = ''
      Caption = #1054#1090#1084#1077#1085#1072
      Cancel = True
      ModalResult = 2
      TabOrder = 2
    end
  end
  object unlbl_DateCapt: TUniLabel
    Left = 30
    Top = 144
    Width = 94
    Height = 13
    Hint = ''
    Alignment = taRightJustify
    Caption = #1044#1072#1090#1072' '#1076#1086#1073#1072#1074#1083#1077#1085#1080#1103':'
    TabOrder = 5
  end
  object unlbl_Date: TUniLabel
    Left = 152
    Top = 144
    Width = 16
    Height = 13
    Hint = ''
    Caption = '----'
    TabOrder = 6
  end
  object actlst_pProps: TActionList
    Left = 248
    Top = 80
    object act_propsOk: TAction
      Caption = 'OK'
      OnExecute = act_propsOkExecute
      OnUpdate = act_propsOkUpdate
    end
  end
end
