unit u_udTreeFuncs;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics,
    // Controls, Forms,
    Data.DB,
    uniGUITypes, uniGUIAbstractClasses,
    uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniTreeView;

function utree_ClearChildrenItems(aTree:TUniTreeView; aNode:TUniTreeNode):Boolean;
function utree_ClearAllItems(aTree:TUniTreeView; aRootNode:TUniTreeNode):Boolean;
function utree_getNodeForTag(aTree:TUniTreeView; aLevel,aTag:Integer):TUniTreeNode;
function utree_insertNode(aTree:TUniTreeView; aParNode:TUniTreeNode; aLevel,aTag:Integer; const aText:string):TUniTreeNode;
function utree_FillCityTree(aTree:TUniTreeView; aDS:TDataSet; var aRootNode: TUniTreeNode):Boolean;
function utree_FillSubNodesTree(aTree:TUniTreeView; aParentNode:TUniTreeNode; aDS:TDataSet; aFillRg:Integer=1):Boolean;


implementation

uses u_wCodeTrace;

function utree_ClearChildrenItems(aTree:TUniTreeView; aNode:TUniTreeNode):Boolean;
var LLastNode:TUniTreeNode;
 begin
   Result:=False;
   if Assigned(aNode)=False then Exit;
   if aNode.HasChildren then
    begin
       repeat
        LLastNode:=aNode.GetLastChild;
        if LLastNode<>nil then aTree.Items.Delete(LLastNode);
       until (LLastNode=nil);
      Result:=True;
    end;
 end;

function utree_ClearAllItems(aTree:TUniTreeView; aRootNode:TUniTreeNode):Boolean;
 var i:integer;
     LL:integer;
  begin
   Result:=False;
   i:=aTree.Items.Count-1;
   LL:=0;
   while i>=LL do
    begin
      if aTree.Items[i]=aRootNode then LL:=1
      else aTree.Items.Delete(aTree.Items[i]);
      Dec(i);
    end;
    Result:=True;
  end;


function utree_getNodeForTag(aTree:TUniTreeView; aLevel,aTag:Integer):TUniTreeNode;
var i:integer;
 begin
   Result:=nil;
   for i:=0 to aTree.Items.Count-1 do
     if (aTree.Items[i].Tag=aTag) and (aTree.Items[i].Level=aLevel) then
      begin
        Result:=aTree.Items[i];
        Exit;
      end;
 end;

function utree_insertNode(aTree:TUniTreeView; aParNode:TUniTreeNode; aLevel,aTag:Integer; const aText:string):TUniTreeNode;
 begin
   Result:=aTree.Items.Add(aParNode,aText);
   Result.Tag:=aTag;
 end;

function utree_FillCityTree(aTree:TUniTreeView; aDS:TDataSet; var aRootNode: TUniTreeNode):Boolean;
var LNode:TUniTreeNode;
    LID,i:Integer;
 begin
   i:=0;
   aTree.Items.Clear;
   try
     aDS.First;
     aRootNode:=aTree.Items.Add(nil,'Города-миллионники');
     aRootNode.Expanded:=True;
     while not(aDS.Eof) do
      begin
        LNode:=aTree.Items.Add(aRootNode);
        LNode.Text:=aDS.FieldByName('name').AsWideString;
        LID:=aDS.FieldByName('ID').AsInteger;
        LNode.Tag:=LID;
        LNode.Data:=@LID;
        {if LID=1 then
         begin
           LNode:=aTree.Items.Add(LNode);
           LNode.Text:='Красная пресня';
           LNode.Data:=@i;
         end;
         }
        aDS.Next;
        Inc(i);
      end;
    except on E:Exception do
     wLogE('utree_FillCityTree',E);
   end;
   Result:=(i>0);
 end;

function utree_FillSubNodesTree(aTree:TUniTreeView; aParentNode:TUniTreeNode; aDS:TDataSet; aFillRg:Integer):Boolean;
var LNode,LLastNode:TUniTreeNode;
    LLevel,LID,i:Integer;
 begin
   i:=0;
   LLevel:=aParentNode.Level;
   utree_ClearChildrenItems(aTree,aParentNode);
   ///
   aDS.First;
   i:=0;
   while not(aDS.Eof) do
    begin
      LNode:=aTree.Items.Add(aParentNode);
      LNode.Text:=aDS.FieldByName('name').AsWideString;
      LID:=aDS.FieldByName('ID').AsInteger;
      LNode.Tag:=LID;
      LNode.Data:=@LID;
      aDS.Next;
      Inc(i);
    end;
  Result:=(i>0);
 end;


end.
