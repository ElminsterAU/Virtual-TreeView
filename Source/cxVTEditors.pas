{*******************************************************************************

     The contents of this file are subject to the Mozilla Public License
     Version 1.1 (the "License"); you may not use this file except in
     compliance with the License. You may obtain a copy of the License at
     http://www.mozilla.org/MPL/

     Software distributed under the License is distributed on an "AS IS"
     basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
     License for the specific language governing rights and limitations
     under the License.

*******************************************************************************}

unit cxVTEditors;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Controls,
  VTEditors, VirtualTrees,
  cxEdit, cxTextEdit, cxDropDownEdit,cxCheckComboBox,
  cxLookAndFeelPainters, cxLookAndFeels;

type
  TcxCustomEditLink = class(TCustomEditLink)
  end;

  TcxCustomTextEditLink = class(TcxCustomEditLink)
  protected
    function GetHookableWindowProc: TWndMethod; override;
    procedure SetHookableWindowProc(const Value: TWndMethod); override;

    procedure SetBounds(R: TRect); override;
    procedure AfterBeginEdit; override;
  end;

  TcxTextEditLink = class(TcxCustomTextEditLink)
  protected {private}
    telProperties: TcxTextEditProperties;
    function telGetProperties: TcxTextEditProperties;
    procedure telSetProperties(const Value: TcxTextEditProperties);

    procedure KeyPress(Sender: TObject; var Key: Char);
  protected
    function CreateEditControl: TWinControl; override;
    function GetEditText: WideString; override;
    procedure SetEditText(const Value: WideString); override;
    procedure PrepareEditControl; override;
    function IsMultiLine: Boolean; override;
    procedure AfterBeginEdit; override;
  public
    destructor Destroy; override;
  published
    property Properties: TcxTextEditProperties
      read telGetProperties
      write telSetProperties;
  end;

  TcxCustomMaskEditLink = class(TcxCustomTextEditLink)

  end;

  TcxCustomDropDownEditLink = class(TcxCustomMaskEditLink)

  end;

  TcxCustomComboBoxLink = class(TcxCustomDropDownEditLink)

  end;

  TcxComboEditLink = class(TcxCustomComboBoxLink)
  protected {private}
    celProperties: TcxComboBoxProperties;
    function celGetProperties: TcxComboBoxProperties;
    procedure celSetProperties(const Value: TcxComboBoxProperties);

    procedure KeyPress(Sender: TObject; var Key: Char);
  protected
    function CreateEditControl: TWinControl; override;
    function GetEditText: WideString; override;
    procedure SetEditText(const Value: WideString); override;
    procedure PrepareEditControl; override;
    function IsMultiLine: Boolean; override;
    procedure AfterBeginEdit; override;
  public
    destructor Destroy; override;
  published
    property Properties: TcxComboBoxProperties
      read celGetProperties
      write celSetProperties;
  end;

  TcxCustomCheckComboBoxLink = class(TcxCustomComboBoxLink)
  end;

  TcxCheckComboEditLink = class(TcxCustomCheckComboBoxLink)
  protected {private}
    ccelProperties: TcxCheckComboBoxProperties;
    function ccelGetProperties: TcxCheckComboBoxProperties;
    procedure ccelSetProperties(const Value: TcxCheckComboBoxProperties);

    procedure KeyPress(Sender: TObject; var Key: Char);
  protected
    function CreateEditControl: TWinControl; override;
    function GetEditText: WideString; override;
    procedure SetEditText(const aValue: WideString); override;
    procedure PrepareEditControl; override;
    function IsMultiLine: Boolean; override;
    procedure AfterBeginEdit; override;
  public
    destructor Destroy; override;
  published
    property Properties: TcxCheckComboBoxProperties
      read ccelGetProperties
      write ccelSetProperties;
  end;

implementation

type
  TcxCustomEditHacker = class(TcxCustomEdit);
  TcxCustomTextEditHacker = class(TcxCustomTextEdit);

  TcxComboBoxForLink = class(TcxComboBox)
  protected
    function GetScrollLookupDataList(AScrollCause: TcxEditScrollCause): Boolean; override;
  end;

{ TcxComboEditLink }

procedure TcxComboEditLink.AfterBeginEdit;
begin
  inherited;
  TcxComboBoxForLink(EditControl).SelectAll;
  TcxComboBoxForLink(EditControl).Repaint;
end;

function TcxComboEditLink.celGetProperties: TcxComboBoxProperties;
begin
  if not Assigned(celProperties) then begin
    celProperties := TcxComboBoxProperties.Create(Self);
    celProperties.ImmediateUpdateText := True;
    celProperties.ImmediatePost := True;
  end;
  Result := celProperties;
end;

procedure TcxComboEditLink.celSetProperties(const Value: TcxComboBoxProperties);
begin
  if not Assigned(celProperties) then
    celProperties := TcxComboBoxProperties.Create(Self);
  celGetProperties.Assign(Value);
end;

function TcxComboEditLink.CreateEditControl: TWinControl;
begin
  Result := TcxComboBoxForLink.Create(nil, True);
end;

destructor TcxComboEditLink.Destroy;
begin
  FreeAndNil(celProperties);
  inherited;
end;

function TcxComboEditLink.GetEditText: WideString;
begin
  Result := TcxComboBoxForLink(EditControl).Text;
end;

function TcxComboEditLink.IsMultiLine: Boolean;
begin
  Result := True;
end;

procedure TcxComboEditLink.KeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key = #13) or (Key = #27)) then Key := #0; // Eliminate beep
end;

procedure TcxComboEditLink.PrepareEditControl;
begin
  inherited;
  with TcxComboBoxForLink(EditControl) do begin
    if Assigned(celProperties) then
      Properties := celProperties;
    OnKeyPress := Self.KeyPress;
    Properties.PopupSizeable := True;
    Properties.PopupAutoSize := False;

    LookAndFeel.ScrollbarMode := sbmClassic;
    LookAndFeel.TouchScrollUIMode := tsmDisabled;
    PopupControlsLookAndFeel.ScrollbarMode := sbmClassic;
    PopupControlsLookAndFeel.TouchScrollUIMode := tsmDisabled;
  end;
  RootLookAndFeel.ScrollbarMode := sbmClassic;
  RootLookAndFeel.TouchScrollUIMode := tsmDisabled;
end;

procedure TcxComboEditLink.SetEditText(const Value: WideString);
begin
  TcxComboBoxForLink(EditControl).Text := Value;
end;

{ TcxCustomTextEditLink }

procedure TcxCustomTextEditLink.AfterBeginEdit;
var
  lEditData: TcxCustomEditData;
begin
  inherited;
  lEditData := nil;
  TcxCustomTextEditHacker(EditControl).Activate(lEditData, False);
  ShowCaret(TcxCustomTextEditHacker(EditControl).InnerTextEdit.Control.Handle);
end;

function TcxCustomTextEditLink.GetHookableWindowProc: TWndMethod;
begin
  Result := TcxCustomTextEditHacker(EditControl).InnerTextEdit.Control.WindowProc
end;

procedure TcxCustomTextEditLink.SetBounds(R: TRect);
var
  lOffsets: TVTOffsets;
begin
  if not FStopping then begin
    with R do begin
      // Set the edit's bounds but make sure there's a minimum width and the right border does not
      // extend beyond the parent's left/right border.
      if Left < 0 then
        Left := 0;
      Dec(Right);
      if Right - Left < 30 then
        Right := Left + 30;
      if Right > FTree.ClientWidth then
        Right := FTree.ClientWidth;
      FEdit.BoundsRect := R;

      FTree.GetOffsets(FNode, lOffsets, TVTElement.ofsLabel, FColumn);

      R.Left := FTree.TextMargin + lOffSets[TVTElement.ofsLabel];
      R.Top := 0;
      R.Right := 0;
      R.Bottom := 0;

      TcxCustomTextEditHacker(EditControl).ContentParams.Offsets := R;
    end;
  end;
end;

procedure TcxCustomTextEditLink.SetHookableWindowProc(const Value: TWndMethod);
begin
  TcxCustomTextEditHacker(EditControl).InnerTextEdit.Control.WindowProc := Value;
end;

{ TcxCheckComboEditLink }

procedure TcxCheckComboEditLink.AfterBeginEdit;
begin
  inherited;
  with TcxCheckComboBox(EditControl) do
    DroppedDown := True;
end;

function TcxCheckComboEditLink.ccelGetProperties: TcxCheckComboBoxProperties;
begin
  if not Assigned(ccelProperties) then
    ccelProperties := TcxCheckComboBoxProperties.Create(Self);
  Result := ccelProperties;
end;

procedure TcxCheckComboEditLink.ccelSetProperties(const Value: TcxCheckComboBoxProperties);
begin
  if not Assigned(ccelProperties) then
    ccelProperties := TcxCheckComboBoxProperties.Create(Self);
  ccelProperties.Assign(ccelProperties);
end;

function TcxCheckComboEditLink.CreateEditControl: TWinControl;
begin
  Result := TcxCheckComboBox.Create(nil, True);
end;

destructor TcxCheckComboEditLink.Destroy;
begin
  FreeAndNil(ccelProperties);
  inherited;
end;

function TcxCheckComboEditLink.GetEditText: WideString;
var
  i : Integer;
begin
  with TcxCheckComboBox(EditControl) do begin
    Result := StringOfChar('0', Properties.Items.Count);
    for i := 0 to Pred(Properties.Items.Count) do
      if States[i] = cbsChecked then
        Result[Succ(i)] := '1';
  end;
end;

function TcxCheckComboEditLink.IsMultiLine: Boolean;
begin
  Result := True;
end;

procedure TcxCheckComboEditLink.KeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key = #13) or (Key = #27)) then Key := #0; // Eliminate beep
end;

type TcxCheckComboBoxHacker = class(TcxCheckComboBox);

procedure TcxCheckComboEditLink.PrepareEditControl;
begin
  inherited;
  with TcxCheckComboBox(EditControl) do begin
    if Assigned(ccelProperties) then
      Properties := ccelProperties;
    OnKeyPress := KeyPress;
  end;
  with TcxCheckComboBoxHacker(EditControl) do begin
    LookAndFeel.ScrollbarMode := sbmClassic;
    LookAndFeel.TouchScrollUIMode := tsmDisabled;
    PopupControlsLookAndFeel.ScrollbarMode := sbmClassic;
    PopupControlsLookAndFeel.TouchScrollUIMode := tsmDisabled;
  end;
  RootLookAndFeel.ScrollbarMode := sbmClassic;
  RootLookAndFeel.TouchScrollUIMode := tsmDisabled;
end;

procedure TcxCheckComboEditLink.SetEditText(const aValue: WideString);
var
  i : Integer;
begin
  with TcxCheckComboBox(EditControl) do
    for i := 0 to Pred(Properties.Items.Count) do
      if (Succ(i) <= Length(aValue)) and (aValue[Succ(i)] = '1') then
        States[i] := cbsChecked
      else
        States[i] := cbsUnchecked;
end;

{ TcxTextEditLink }

procedure TcxTextEditLink.AfterBeginEdit;
begin
  inherited;
  TcxTextEdit(EditControl).SelectAll;
end;

function TcxTextEditLink.CreateEditControl: TWinControl;
begin
  Result := TcxTextEdit.Create(nil, True);
end;

destructor TcxTextEditLink.Destroy;
begin
  FreeAndNil(telProperties);
  inherited;
end;

function TcxTextEditLink.GetEditText: WideString;
begin
  Result := TcxTextEdit(EditControl).Text;
end;

function TcxTextEditLink.IsMultiLine: Boolean;
begin
  Result := True;
end;

procedure TcxTextEditLink.KeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key = #13) or (Key = #27)) then Key := #0; // Eliminate beep
end;

procedure TcxTextEditLink.PrepareEditControl;
begin
  inherited;
  with TcxTextEdit(EditControl) do begin
    if Assigned(telProperties) then
      Properties := telProperties;
    OnKeyPress := KeyPress;
  end;
end;

procedure TcxTextEditLink.SetEditText(const Value: WideString);
begin
  TcxTextEdit(EditControl).Text := Value;
end;

function TcxTextEditLink.telGetProperties: TcxTextEditProperties;
begin
  if not Assigned(telProperties) then
    telProperties := TcxTextEditProperties.Create(Self);
  Result := telProperties;
end;

procedure TcxTextEditLink.telSetProperties(const Value: TcxTextEditProperties);
begin
  if not Assigned(telProperties) then
    telProperties := TcxTextEditProperties.Create(Self);
  telGetProperties.Assign(Value);
end;

{ TcxComboBoxForLink }

function TcxComboBoxForLink.GetScrollLookupDataList(AScrollCause: TcxEditScrollCause): Boolean;
begin
  Result := not PropertiesChangeLocked and (not IsInplace or
    (AScrollCause in [escMouseWheel, escKeyboard]) or not InplaceParams.MultiRowParent or HasPopupWindow);
end;

end.
