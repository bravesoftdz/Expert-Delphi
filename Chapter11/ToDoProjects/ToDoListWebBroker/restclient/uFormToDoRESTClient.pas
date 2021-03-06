unit uFormToDoRESTClient;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uToDoTypes,
  FMX.TabControl, System.Actions, FMX.ActnList, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, FMX.Edit;

type
  TFormToDoRESTClient = class(TForm)
    tbctrlMain: TTabControl;
    tbiList: TTabItem;
    tbiEdit: TTabItem;
    ActionList1: TActionList;
    ctaList: TChangeTabAction;
    ctaEdit: TChangeTabAction;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    lstvwToDos: TListView;
    spdbtnAdd: TSpeedButton;
    lblToDoList: TLabel;
    actAdd: TAction;
    actDelete: TAction;
    spdbtnBack: TSpeedButton;
    lblToDoEdit: TLabel;
    edtTitle: TEdit;
    lblTitle: TLabel;
    edtCategory: TEdit;
    lblCategory: TLabel;
    actSave: TAction;
    spdbtnSave: TSpeedButton;
    spdbtnDelete: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure lstvwToDosDeleteItem(Sender: TObject; AIndex: Integer);
    procedure lstvwToDosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    FCurrentId: integer;
    FToDos: TToDos;
    function GetToDoData: IToDoData;
    procedure RefreshList;
  public
    { Public declarations }
  end;

var
  FormToDoRESTClient: TFormToDoRESTClient;

implementation

{$R *.fmx}

uses uDMToDoWebBrokREST;

{ TFormToDo }

function TFormToDoRESTClient.GetToDoData: IToDoData;
begin
  if DMToDoWebBrokREST = nil then
    DMToDoWebBrokREST := TDMToDoWebBrokREST.Create(Application);
  Result := DMToDoWebBrokREST;
end;

procedure TFormToDoRESTClient.actAddExecute(Sender: TObject);
begin
  FCurrentId := -1;
  edtTitle.Text := '';
  edtCategory.Text := '';
  ctaEdit.ExecuteTarget(self);
end;

procedure TFormToDoRESTClient.actDeleteExecute(Sender: TObject);
begin
  if FCurrentId > 0 then
  begin
    GetToDoData.ToDoDelete(FCurrentId);
    RefreshList;
  end;
  if tbctrlMain.ActiveTab <> tbiList then
    ctaList.ExecuteTarget(self);
end;

procedure TFormToDoRESTClient.actSaveExecute(Sender: TObject);
var todo: TToDo;
begin
  todo.Title := edtTitle.Text;
  todo.Category := edtCategory.Text;
  if FCurrentId < 0 then
    GetToDoData.ToDoCreate(todo)
  else
  begin
    todo.Id := FCurrentId;
    GetToDoData.ToDoUpdate(todo);
  end;
  RefreshList;
  ctaList.ExecuteTarget(self);
end;

procedure TFormToDoRESTClient.FormCreate(Sender: TObject);
begin
  FToDos := TToDos.Create;
  tbctrlMain.ActiveTab := tbiList;
  RefreshList;
end;

procedure TFormToDoRESTClient.FormDestroy(Sender: TObject);
begin
  FToDos.Free;
end;

procedure TFormToDoRESTClient.lstvwToDosDeleteItem(Sender: TObject; AIndex: Integer);
begin
  FCurrentId := FToDos[AIndex].Id;
  actDelete.Execute;
end;

procedure TFormToDoRESTClient.lstvwToDosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
var todo: TToDo;
begin
  FCurrentId := AItem.Tag;
  GetToDoData.ToDoRead(FCurrentId, todo);
  edtTitle.Text := todo.Title;
  edtCategory.Text := todo.Category;
  ctaEdit.ExecuteTarget(self);
end;

procedure TFormToDoRESTClient.RefreshList;
var todo: TToDo; item: TListViewItem;
begin
  GetToDoData.ToDoList(FToDos);
  lstvwToDos.BeginUpdate;
  try
    lstvwToDos.Items.Clear;
    for todo in FToDos do
    begin
      item := lstvwToDos.Items.Add;
      item.Tag := todo.Id;
      item.Objects.FindObjectT<TListItemText>('Title').Text := todo.Title;
      item.Objects.FindObjectT<TListItemText>('Category').Text := todo.Category;
    end;
  finally
    lstvwToDos.EndUpdate;
  end;
end;

end.
