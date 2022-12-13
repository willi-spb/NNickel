unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniTreeView,
  Data.DB, dm_DbFuncs, uniImageList, System.Actions, Vcl.ActnList, uniToolBar,
  uniLabel, uniPanel, uniEdit;

type
  TnnTreeTestForm = class(TUniForm)
    unTree_CL: TUniTreeView;
    unimgList_Act: TUniNativeImageList;
    untlbr_A: TUniToolBar;
    btn_AddItem: TUniToolButton;
    btn_ClearUser: TUniToolButton;
    btn_DeleteThing: TUniToolButton;
    actlst_T: TActionList;
    act_AddItem: TAction;
    act_EditItem: TAction;
    act_DeleteItem: TAction;
    btn_renew: TUniToolButton;
    unpnl_ItemOwner: TUniPanel;
    unlbl_nameC: TUniLabel;
    unlbl_CDate: TUniLabel;
    unlbl_itemOwner: TUniLabel;
    unlbl_ItemDate: TUniLabel;
    unpnl_Filter: TUniPanel;
    unlbl1: TUniLabel;
    undt_TreeFilter: TUniEdit;
    procedure UniFormShow(Sender: TObject);
    procedure UniFormDestroy(Sender: TObject);
    procedure unTree_CLNodeExpand(Sender: TObject; Node: TUniTreeNode);
    procedure act_AddItemExecute(Sender: TObject);
    procedure act_DeleteItemExecute(Sender: TObject);
    procedure btn_renewClick(Sender: TObject);
    procedure unTree_CLChange(Sender: TObject; Node: TUniTreeNode);
    procedure undt_TreeFilterChange(Sender: TObject);
  private
    { Private declarations }
    FCityRootNode:TUniTreeNode;
    procedure renewTreeData(aRenewRg:Integer=0);
    procedure FillTreeForLevelAndID(aLevel,aID:Integer; aFullCityFlag:boolean);
    procedure clb_NodeProps(Sender: TComponent; AResult:Integer);
    procedure clb_DeleteNode(Sender: TComponent; AResult:Integer);
    procedure set_ItemOwnerData(aNode:TUniTreeNode);
  public
    { Public declarations }
  end;

function nnTreeTestForm: TnnTreeTestForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication,
  u_wCodeTrace,
  ServerModule,
  u_udTreeFuncs,
  ufm_PlaceProps;

function nnTreeTestForm: TnnTreeTestForm;
begin
  Result := TnnTreeTestForm(UniMainModule.GetFormInstance(TnnTreeTestForm));
end;

procedure TnnTreeTestForm.act_AddItemExecute(Sender: TObject);
var L_Lvl,L_tag,LParID,L_newID:integer;
begin
  L_Lvl:=1;
  L_Tag:=TAction(Sender).Tag;
  if unTree_CL.Selected=nil then
     LParID:=0
  else begin
         LParID:=unTree_CL.Selected.Tag;
         L_Lvl:=unTree_CL.Selected.Level;
  end;
  ///
  if PlacePropsForm.setData(L_Lvl,LParID,L_Tag) then
     PlacePropsForm.ShowModal(clb_NodeProps);
end;

procedure TnnTreeTestForm.act_DeleteItemExecute(Sender: TObject);
begin
  if unTree_CL.Selected<>nil then
    MessageDlg('Каскадно удалить запись?',mtConfirmation,[mbYes,mbNo],clb_DeleteNode);
end;

procedure TnnTreeTestForm.btn_renewClick(Sender: TObject);
begin
 renewTreeData(0);
end;

procedure TnnTreeTestForm.clb_NodeProps(Sender: TComponent; AResult: Integer);
var L_lvl:integer;
    L_Node,L_parNode:TUniTreeNode;
begin
  with AppDB_DM do
   begin
     L_Lvl:=currLevel-1;
     if L_lvl=0 then L_lvl:=1;
    // FillTreeForLevelAndID(L_lvl,currID,false);
     if currID>0 then
      begin
        L_Node:=utree_getNodeForTag(unTree_CL,currLevel,currID);
        if Assigned(L_Node) then
            L_Node.Text:=currName
        else
         begin
          if currLevel>1 then
             L_parNode:=utree_getNodeForTag(unTree_CL,currLevel-1,currParentID)
          else L_parNode:=FCityRootNode;
          if Assigned(L_parNode) then
             L_Node:=utree_insertNode(unTree_CL,L_parNode,currLevel,currID,currName);
         end;
         if Assigned(L_Node) then
          begin
            L_Node.Selected:=True;
            L_Node.Expanded:=True;
            // unTree_CL.BringToFront;
          end;
      end;
    end;
end;

procedure TnnTreeTestForm.clb_DeleteNode(Sender: TComponent; AResult: Integer);
var LLvl,LID,LparID,L_delID:integer;
    LParentNode:TUniTreeNode;
begin
  if (unTree_CL.Selected=nil) or (unTree_CL.Selected.Level=0) then Exit;
  LLvl:=unTree_CL.Selected.Level;
  LID:=unTree_CL.Selected.Tag;
  LParentNode:=unTree_CL.Selected.Parent;
  with AppDB_DM do
   begin
    if deleteItem(LLvl,LID)=false then
     begin
       MessageDlg('Ошибка при каскадном удалении записей!'+#13#10+LastErrorMess,mtError,[mbOK]);
       Exit;
     end;
    if Assigned(LParentNode) then
     begin
       LLvl:=LParentNode.Level;
       LparID:=LParentNode.Tag;
     end
    else begin
          LParID:=0;
          LLvl:=1;
    end;
    FillTreeForLevelAndID(LLvl,LParID,false);
   end;
end;

procedure TnnTreeTestForm.FillTreeForLevelAndID(aLevel, aID: Integer; aFullCityFlag:boolean);
var LNode:TUniTreeNode;
    i:integer;
begin
 with AppDB_DM do
  if aLevel=1 then
    begin
      if aFullCityFlag then
       begin
         fdqr_City.Active:=False;
         fdqr_City.Active:=True;
         utree_FillCityTree(unTree_CL,fdqr_City,FCityRootNode);
         fdqr_City.Active:=False;
         ///  Только второй уровень
        for i:=0 to unTree_CL.Items.Count-1 do
          begin
           LNode:=unTree_CL.Items[i];
           if LNode.Level=1 then
             if getItemsForID(LNode.Level+1,LNode.Tag,True)>0 then
               utree_FillSubNodesTree(unTree_CL,LNode,fdqr_subItems);
          end;
       end
      else
       begin
         if Assigned(FCityRootNode) then
           begin
            // utree_ClearChildrenItems(unTree_CL,FCityRootNode);
             utree_ClearAllItems(unTree_CL,FCityRootNode);
             ///
             if getItemsForID(1,aID,True)>0 then
                utree_FillSubNodesTree(unTree_CL,FCityRootNode,fdqr_subItems,1);
             ///
             for i:=0 to unTree_CL.Items.Count-1 do
              begin
                LNode:=unTree_CL.Items[i];
                if (Assigned(LNode)) and (LNode.Level=1) then
                  if getItemsForID(LNode.Level+1,LNode.Tag,True)>0 then
                       utree_FillSubNodesTree(unTree_CL,LNode,fdqr_subItems);
              end;
           end;
       end;
     end
   else
    begin
     LNode:=utree_getNodeForTag(unTree_CL,aLevel,aID);
     if Assigned(LNode) and (aLevel<4) then
         begin
           if getItemsForID(aLevel+1,aID,True)>0 then
            begin
              utree_FillSubNodesTree(unTree_CL,LNode,fdqr_subItems,1);
             ///
             if aLevel<3 then
              for i:=0 to unTree_CL.Items.Count-1 do
                 begin
                   LNode:=unTree_CL.Items[i];
                   if (Assigned(LNode)) and (LNode.Level=aLevel+1) then
                    if getItemsForID(LNode.Level+1,LNode.Tag,True)>0 then
                         utree_FillSubNodesTree(unTree_CL,LNode,fdqr_subItems);
                end;
            end
           else utree_ClearChildrenItems(unTree_CL,LNode);
         end;
     end;
 set_ItemOwnerData(unTree_CL.Selected);
end;

procedure TnnTreeTestForm.renewTreeData(aRenewRg: Integer);
var LNode:TUniTreeNode;
begin
 LNode:=unTree_CL.Selected;
 FillTreeForLevelAndID(1,0,false);
 if Assigned(LNode) then
    LNode.Selected:=True;
end;

procedure TnnTreeTestForm.set_ItemOwnerData(aNode: TUniTreeNode);
var L_Arr:Variant;
    L_Lvl:integer;
begin
 if Assigned(aNode) then
  begin
    L_Lvl:=aNode.Level;
    if (L_Lvl>0) and (AppDB_DM.getPLOwnerData(L_Lvl,aNode.Tag,L_Arr)>0) then
     begin
       unlbl_itemOwner.Text:=L_Arr[1];
       unlbl_ItemDate.Text:=FormatDateTime('dd-MM-YYYY',L_Arr[2]);
     end
    else
     begin
       unlbl_itemOwner.Text:='---------------';
       unlbl_ItemDate.Text:='нет данных';
     end;
  end;
end;

procedure TnnTreeTestForm.undt_TreeFilterChange(Sender: TObject);
var LFilter:string;
begin
 LFilter:=Trim(undt_TreeFilter.Text);
 with AppDB_DM do
   nameFilterValue:=LFilter;
 renewTreeData(0);
end;

procedure TnnTreeTestForm.UniFormDestroy(Sender: TObject);
begin
  AppDB_DM.Free;
end;

procedure TnnTreeTestForm.UniFormShow(Sender: TObject);
begin
 FCityRootNode:=nil;
 with AppDB_DM do
  begin
   setConnRef(UniServerModule.Conn); // !
   if FillHomeData then
          wLog('i','refillData');
   ///
   FillTreeForLevelAndID(1,0,true);
  end;
end;

procedure TnnTreeTestForm.unTree_CLChange(Sender: TObject; Node: TUniTreeNode);
begin
  set_ItemOwnerData(Node);
end;

procedure TnnTreeTestForm.unTree_CLNodeExpand(Sender: TObject;
  Node: TUniTreeNode);
var L_Lvl,i:integer;
    LNode:TUniTreeNode;
begin
  L_Lvl:=Node.Level;
  wLog('n',Format('level=%d, tag=%d',[L_Lvl,Node.Tag]));
  if L_Lvl<4 then
   with AppDB_DM do
    begin
      if getItemsForID(L_Lvl+1,Node.Tag,True)>0 then
       begin
         utree_FillSubNodesTree(unTree_CL,Node,fdqr_subItems);
          for i:=0 to unTree_CL.Items.Count-1 do
              begin
                LNode:=unTree_CL.Items[i];
                if (LNode.Level=L_Lvl+1) then
                  if getItemsForID(LNode.Level+1,LNode.Tag,True)>0 then
                       utree_FillSubNodesTree(unTree_CL,LNode,fdqr_subItems);
              end;
       end
      else utree_ClearChildrenItems(unTree_CL,Node);
    end;
end;

initialization
  RegisterAppFormClass(TnnTreeTestForm);

end.
