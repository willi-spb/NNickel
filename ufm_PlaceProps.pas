unit ufm_PlaceProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniButton, uniPanel, uniLabel, uniGUIBaseClasses,
  uniEdit, System.Actions, Vcl.ActnList;

type
  TPlacePropsForm = class(TUniForm)
    undt_Name: TUniEdit;
    unlbl_nameC: TUniLabel;
    undt_plOwner: TUniEdit;
    unlbl1: TUniLabel;
    unpnl1: TUniPanel;
    btnOk: TUniButton;
    btn2: TUniButton;
    actlst_pProps: TActionList;
    act_propsOk: TAction;
    unlbl_DateCapt: TUniLabel;
    unlbl_Date: TUniLabel;
    procedure act_propsOkUpdate(Sender: TObject);
    procedure act_propsOkExecute(Sender: TObject);
    procedure UniFormCreate(Sender: TObject);
  private
    { Private declarations }
    F_Regime:integer;
    F_Level,F_ID:integer;
    F_Date:TDateTime;
    function applyData:Boolean;
  public
    { Public declarations }
    function setData(aLvl,aID:Integer; aRegime:integer=0):Boolean;
  end;

function PlacePropsForm: TPlacePropsForm;

implementation

{$R *.dfm}

uses
  MainModule, uniGUIApplication, u_wCodeTrace,
  dm_DbFuncs;

function PlacePropsForm: TPlacePropsForm;
begin
  Result := TPlacePropsForm(UniMainModule.GetFormInstance(TPlacePropsForm));
end;

{ TPlacePropsForm }

procedure TPlacePropsForm.act_propsOkExecute(Sender: TObject);
begin
if applyData=false then
     MessageDlg('Ошибка записи!',mtError,[mbOk])
 else ModalResult:=mrOk;
end;

procedure TPlacePropsForm.act_propsOkUpdate(Sender: TObject);
begin
 // TAction(Sender).Enabled:=(Trim(undt_Name.Text)<>'') and (Trim(undt_plOwner.Text)<>'');
 TAction(Sender).Enabled:=True;
end;

function TPlacePropsForm.applyData: Boolean;
var L_Arr:Variant;
    L_newID,L_ownID:integer;
begin
 Result:=false;
 L_newID:=0;
 L_Arr:=VarArrayOf([Trim(undt_Name.Text),Trim(undt_plOwner.Text),Now]);
 with AppDB_DM do
  begin
   if F_Regime=0 then
      begin
        L_newID:=addItemData(F_Level,F_ID,L_Arr);
      end
   else
    begin
      L_newID:=setItemData(F_Level,F_ID,L_Arr);
    end;
    if L_newID>0 then
          L_ownID:=setPLOwnerData(F_Level,L_newID,L_Arr);
        Result:=(L_ownID>0);
  end;
end;

function TPlacePropsForm.setData(aLvl, aID, aRegime: integer): Boolean;
var L_Arr:Variant;
begin
  Result:=false;
  F_Regime:=aRegime;
  F_Level:=aLvl;
  F_ID:=aID;
  undt_plOwner.Text:='';
  undt_Name.Text:='';
  unlbl_Date.Caption:='---';
  if F_Regime>0 then
   with AppDB_DM do
    begin
      if getItemData(F_Level,F_ID,L_Arr) then
       begin
         if VarIsNull(L_Arr[0])=False then
            undt_Name.Text:=L_Arr[0];
         if VarIsNull(L_Arr[2])=False then
            undt_plOwner.Text:=L_Arr[2];
         if VarIsNull(L_Arr[3])=False then
          begin
            F_Date:=L_Arr[3];
            unlbl_Date.Caption:=FormatDateTime('dd-mm-YYYY',F_Date);
          end;
        Result:=true;
       end;
    end
  else
   begin
    F_Level:=aLvl+1; // !!
    if F_Level>4 then F_Level:=4;
    case F_level of
     1: Caption:=Caption+' - Город';
     2: Caption:=Caption+' - Район';
     3: Caption:=Caption+' - Улица';
     4: Caption:=Caption+' - Дом (строение)';
    end;
    unlbl_Date.Caption:=FormatDateTime('dd-mm-YYYY',Now);
    F_Date:=Now;
    Result:=true;
   end;
end;

procedure TPlacePropsForm.UniFormCreate(Sender: TObject);
begin
  F_Date:=0;
  F_Regime:=0;
  F_ID:=0;
end;

end.
