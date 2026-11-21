unit uProjectMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Menus, Dialogs, ComCtrls, ActnList,
  // LazUtils
  LazFileUtils, FileUtil,
  // BuildIntf
  ProjectIntf, CompOptsIntf,
  // IDEIntf
  LazIDEIntf, MenuIntf, IDECommands, IDEDialogs, IDEImagesIntf;

type
  { TPGEditorHook: Helper that hooks a TProjectGroupEditorForm instance dynamically }
  TPGEditorHook = class(TComponent)
  private
    FForm: TCustomForm;
    FTreeMenu: TPopupMenu;
    FTreeView: TTreeView;
    FOldPopup: TNotifyEvent;
    // Context menu items in Project Group
    FMICompile: TMenuItem;
    FMIBuild: TMenuItem;
    FMIClean: TMenuItem;
    FMISep1: TMenuItem;
    FMIRun: TMenuItem;
    FMIRunWithoutDebug: TMenuItem;
    FMISep2: TMenuItem;
    FMIAdd: TMenuItem;
    FMIAddNew: TMenuItem;
    FMIAddNewForm: TMenuItem;
    FMIAddNewFrame: TMenuItem;
    FMIAddNewDataModule: TMenuItem;
    FMIAddNewUnit: TMenuItem;
    FMISepAddNew: TMenuItem;
    FMIAddNewOther: TMenuItem;
    FMISep3: TMenuItem;
    FMIRemoveFile: TMenuItem;
    FMIRemoveProject: TMenuItem;
    FMISep4: TMenuItem;
    FMISave: TMenuItem;
    FMISaveAs: TMenuItem;
    FMIRename: TMenuItem;
    FMISep5: TMenuItem;
    FMIActivate: TMenuItem;
    procedure ExecuteActionByName(const AActionName: string);
    procedure DoEnsureTargetProjectOpen(out AProject: TLazProject);
    procedure DoAddNewFileToTarget(const ADescName: string);
    procedure OnMenuPopup(Sender: TObject);
    procedure OnCompileClick(Sender: TObject);
    procedure OnBuildClick(Sender: TObject);
    procedure OnCleanClick(Sender: TObject);
    procedure OnRunClick(Sender: TObject);
    procedure OnRunWithoutDebugClick(Sender: TObject);
    procedure OnAddFilesClick(Sender: TObject);
    procedure OnNewFormClick(Sender: TObject);
    procedure OnNewFrameClick(Sender: TObject);
    procedure OnNewDataModuleClick(Sender: TObject);
    procedure OnNewUnitClick(Sender: TObject);
    procedure OnNewOtherClick(Sender: TObject);
    procedure OnRemoveFileClick(Sender: TObject);
    procedure OnRemoveProjectClick(Sender: TObject);
    procedure OnSaveClick(Sender: TObject);
    procedure OnSaveAsClick(Sender: TObject);
    procedure OnRenameClick(Sender: TObject);
    procedure OnActivateClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetupMenu;
    property Form: TCustomForm read FForm write FForm;
    property TreeMenu: TPopupMenu read FTreeMenu write FTreeMenu;
    property TreeView: TTreeView read FTreeView write FTreeView;
  end;

  { TProjectMenuManager: Coordinates Project Inspector & Project Groups }
  TProjectMenuManager = class
  private
    class var FInitialized: Boolean;
    class var FProjInspMenuSectionBuild: TIDEMenuSection;
    class var FProjInspMenuCompile: TIDEMenuCommand;
    class var FProjInspMenuBuild: TIDEMenuCommand;
    class var FProjInspMenuClean: TIDEMenuCommand;
    class var FProjInspMenuSectionRun: TIDEMenuSection;
    class var FProjInspMenuRun: TIDEMenuCommand;
    class var FProjInspMenuRunWithoutDebugging: TIDEMenuCommand;
    class var FProjInspMenuSectionAdd: TIDEMenuSection;
    class var FProjInspMenuAddFiles: TIDEMenuCommand;
    class var FProjInspMenuAddNew: TIDEMenuSection;
    class var FProjInspMenuAddNewForm: TIDEMenuCommand;
    class var FProjInspMenuAddNewFrame: TIDEMenuCommand;
    class var FProjInspMenuAddNewDataModule: TIDEMenuCommand;
    class var FProjInspMenuAddNewUnit: TIDEMenuCommand;
    class var FProjInspMenuSectionAddNewOther: TIDEMenuSection;
    class var FProjInspMenuAddNewOther: TIDEMenuCommand;
    class var FProjInspMenuSectionRemove: TIDEMenuSection;
    class var FProjInspMenuRemoveFile: TIDEMenuCommand;
    class var FProjInspMenuSectionSave: TIDEMenuSection;
    class var FProjInspMenuSave: TIDEMenuCommand;
    class var FProjInspMenuSaveAs: TIDEMenuCommand;
    class var FProjInspMenuRename: TIDEMenuCommand;
    class procedure OnProjectInspectorMenuShow(Sender: TObject);
    class procedure OnScreenFormAdded(Sender: TObject; AForm: TCustomForm);
    class procedure HookProjectGroupEditor(AForm: TCustomForm);
    class procedure HookExistingProjectGroupEditors;
    class procedure DoAddNewFile(const ADescName: string);
    class procedure DoCompileClick(Sender: TObject);
    class procedure DoBuildClick(Sender: TObject);
    class procedure DoCleanClick(Sender: TObject);
    class procedure DoRunClick(Sender: TObject);
    class procedure DoRunWithoutDebugClick(Sender: TObject);
    class procedure DoAddFilesClick(Sender: TObject);
    class procedure DoNewFormClick(Sender: TObject);
    class procedure DoNewFrameClick(Sender: TObject);
    class procedure DoNewDataModuleClick(Sender: TObject);
    class procedure DoNewUnitClick(Sender: TObject);
    class procedure DoNewOtherClick(Sender: TObject);
    class procedure DoRemoveFileClick(Sender: TObject);
    class procedure DoSaveClick(Sender: TObject);
    class procedure DoSaveAsClick(Sender: TObject);
    class procedure DoRenameClick(Sender: TObject);
  public
    class procedure Initialize;
  end;

procedure Register;

implementation

procedure Register;
begin
  TProjectMenuManager.Initialize;
end;

{ Helper function to create a TMenuItem with caption, icon and handler }
function CreateProjectMenuItem(AOwner: TComponent; const ACaption: string;
  AOnClick: TNotifyEvent; const AImageName: string = ''): TMenuItem;
begin
  Result := TMenuItem.Create(AOwner);
  Result.Caption := ACaption;
  Result.OnClick := AOnClick;
  if (AImageName <> '') and (IDEImages <> nil) then
    Result.ImageIndex := IDEImages.GetImageIndex(AImageName);
end;

{ TPGEditorHook }

constructor TPGEditorHook.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TPGEditorHook.Destroy;
begin
  if FTreeMenu <> nil then
    FTreeMenu.OnPopup := FOldPopup;
  inherited Destroy;
end;

procedure TPGEditorHook.ExecuteActionByName(const AActionName: string);
var
  Comp: TComponent;
  Act: TAction;
begin
  if FForm = nil then Exit;
  Comp := FForm.FindComponent(AActionName);
  if (Comp <> nil) and (Comp is TAction) then
  begin
    Act := TAction(Comp);
    if Act.Enabled then
      Act.Execute;
  end;
end;

procedure TPGEditorHook.DoEnsureTargetProjectOpen(out AProject: TLazProject);
var
  SelNode: TTreeNode;
begin
  AProject := nil;
  if FTreeView = nil then Exit;
  SelNode := FTreeView.Selected;
  if SelNode = nil then Exit;

  // If active project is already open
  AProject := LazarusIDE.ActiveProject;
  if AProject <> nil then Exit;

  // Try activating target
  ExecuteActionByName('ATargetActivate');
  AProject := LazarusIDE.ActiveProject;
end;

procedure TPGEditorHook.DoAddNewFileToTarget(const ADescName: string);
var
  Prj: TLazProject;
  Desc: TProjectFileDescriptor;
  Flags: TNewFlags;
  NewFilename: string;
begin
  DoEnsureTargetProjectOpen(Prj);
  if Prj = nil then Exit;
  Desc := ProjectFileDescriptors.FindByName(ADescName);
  if Desc = nil then Exit;
  Flags := [nfOpenInEditor, nfCreateDefaultSrc];
  Desc.Owner := Prj;
  try
    NewFilename := '';
    LazarusIDE.DoNewEditorFile(Desc, NewFilename, '', Flags);
  finally
    Desc.Owner := nil;
  end;
end;

procedure TPGEditorHook.SetupMenu;
var
  InsertIdx: Integer;

  procedure AddItem(AItem: TMenuItem);
  begin
    FTreeMenu.Items.Insert(InsertIdx, AItem);
    Inc(InsertIdx);
  end;

begin
  if FTreeMenu = nil then Exit;

  // If already hooked in the LFM or core, do not duplicate
  if (FForm <> nil) and ((FForm.FindComponent('PMIProjCompile') <> nil) or (FForm.FindComponent('PMIBuild') <> nil)) then Exit;
  if (FTreeMenu <> nil) and (FTreeMenu.FindComponent('PMIProjCompile') <> nil) then Exit;

  FOldPopup := FTreeMenu.OnPopup;
  FTreeMenu.OnPopup := @OnMenuPopup;

  InsertIdx := 0;

  // 1-3. Compile, Build, Clean
  FMICompile := CreateProjectMenuItem(Self, 'Compile', @OnCompileClick, 'menu_build');
  FMICompile.Name := 'PMIProjCompile';
  AddItem(FMICompile);

  FMIBuild := CreateProjectMenuItem(Self, 'Build', @OnBuildClick, 'menu_build');
  FMIBuild.Name := 'PMIProjBuild';
  AddItem(FMIBuild);

  FMIClean := CreateProjectMenuItem(Self, 'Clean', @OnCleanClick, 'menu_build_clean');
  FMIClean.Name := 'PMIProjClean';
  AddItem(FMIClean);

  // 4. Separator
  FMISep1 := CreateProjectMenuItem(Self, '-', nil);
  AddItem(FMISep1);

  // 5-6. Run, Run Without Debugging
  FMIRun := CreateProjectMenuItem(Self, 'Run', @OnRunClick, 'menu_run');
  FMIRun.Name := 'PMIProjRun';
  AddItem(FMIRun);

  FMIRunWithoutDebug := CreateProjectMenuItem(Self, 'Run Without Debugging', @OnRunWithoutDebugClick, 'menu_run');
  FMIRunWithoutDebug.Name := 'PMIProjRunWithoutDebug';
  AddItem(FMIRunWithoutDebug);

  // 7. Separator
  FMISep2 := CreateProjectMenuItem(Self, '-', nil);
  AddItem(FMISep2);

  // 8. Add...
  FMIAdd := CreateProjectMenuItem(Self, 'Add...', @OnAddFilesClick, 'laz_add');
  FMIAdd.Name := 'PMIProjAdd';
  AddItem(FMIAdd);

  // 9. Add New >
  FMIAddNew := CreateProjectMenuItem(Self, 'Add New', nil);
  FMIAddNew.Name := 'PMIProjAddNew';

  FMIAddNewForm := CreateProjectMenuItem(Self, 'Form', @OnNewFormClick, 'item_form');
  FMIAddNew.Add(FMIAddNewForm);

  FMIAddNewFrame := CreateProjectMenuItem(Self, 'Frame', @OnNewFrameClick, 'item_frame');
  FMIAddNew.Add(FMIAddNewFrame);

  FMIAddNewDataModule := CreateProjectMenuItem(Self, 'Data Module', @OnNewDataModuleClick, 'item_datamodule');
  FMIAddNew.Add(FMIAddNewDataModule);

  FMIAddNewUnit := CreateProjectMenuItem(Self, 'Unit', @OnNewUnitClick, 'item_unit');
  FMIAddNew.Add(FMIAddNewUnit);

  FMISepAddNew := CreateProjectMenuItem(Self, '-', nil);
  FMIAddNew.Add(FMISepAddNew);

  FMIAddNewOther := CreateProjectMenuItem(Self, 'Other...', @OnNewOtherClick, 'laz_add');
  FMIAddNew.Add(FMIAddNewOther);

  AddItem(FMIAddNew);

  // 10. Separator
  FMISep3 := CreateProjectMenuItem(Self, '-', nil);
  AddItem(FMISep3);

  // 11. Remove File...
  FMIRemoveFile := CreateProjectMenuItem(Self, 'Remove File...', @OnRemoveFileClick, 'laz_delete');
  FMIRemoveFile.Name := 'PMIProjRemoveFile';
  AddItem(FMIRemoveFile);

  // 12. Remove Project
  FMIRemoveProject := CreateProjectMenuItem(Self, 'Remove Project', @OnRemoveProjectClick, 'laz_delete');
  FMIRemoveProject.Name := 'PMIProjRemoveProject';
  AddItem(FMIRemoveProject);

  // 13. Separator
  FMISep4 := CreateProjectMenuItem(Self, '-', nil);
  AddItem(FMISep4);

  // 14-16. Save, Save As..., Rename
  FMISave := CreateProjectMenuItem(Self, 'Save', @OnSaveClick);
  FMISave.Name := 'PMIProjSave';
  AddItem(FMISave);

  FMISaveAs := CreateProjectMenuItem(Self, 'Save As...', @OnSaveAsClick);
  FMISaveAs.Name := 'PMIProjSaveAs';
  AddItem(FMISaveAs);

  FMIRename := CreateProjectMenuItem(Self, 'Rename', @OnRenameClick);
  FMIRename.Name := 'PMIProjRename';
  AddItem(FMIRename);

  // 17. Separator
  FMISep5 := CreateProjectMenuItem(Self, '-', nil);
  AddItem(FMISep5);

  // 18. Activate
  FMIActivate := CreateProjectMenuItem(Self, 'Activate', @OnActivateClick, 'pg_active');
  FMIActivate.Name := 'PMIProjActivate';
  AddItem(FMIActivate);
end;

procedure TPGEditorHook.OnMenuPopup(Sender: TObject);
var
  HasSelection: Boolean;
begin
  if Assigned(FOldPopup) then
    FOldPopup(Sender);

  HasSelection := (FTreeView <> nil) and (FTreeView.Selected <> nil);

  if FMICompile <> nil then FMICompile.Visible := HasSelection;
  if FMIBuild <> nil then FMIBuild.Visible := HasSelection;
  if FMIClean <> nil then FMIClean.Visible := HasSelection;
  if FMISep1 <> nil then FMISep1.Visible := HasSelection;

  if FMIRun <> nil then FMIRun.Visible := HasSelection;
  if FMIRunWithoutDebug <> nil then FMIRunWithoutDebug.Visible := HasSelection;
  if FMISep2 <> nil then FMISep2.Visible := HasSelection;

  if FMIAdd <> nil then FMIAdd.Visible := HasSelection;
  if FMIAddNew <> nil then FMIAddNew.Visible := HasSelection;
  if FMISep3 <> nil then FMISep3.Visible := HasSelection;

  if FMIRemoveFile <> nil then FMIRemoveFile.Visible := HasSelection;
  if FMIRemoveProject <> nil then FMIRemoveProject.Visible := HasSelection;
  if FMISep4 <> nil then FMISep4.Visible := HasSelection;

  if FMISave <> nil then FMISave.Visible := HasSelection;
  if FMISaveAs <> nil then FMISaveAs.Visible := HasSelection;
  if FMIRename <> nil then FMIRename.Visible := HasSelection;
  if FMISep5 <> nil then FMISep5.Visible := HasSelection;

  if FMIActivate <> nil then FMIActivate.Visible := HasSelection;
end;

procedure TPGEditorHook.OnCompileClick(Sender: TObject);
begin
  ExecuteActionByName('ATargetCompile');
end;

procedure TPGEditorHook.OnBuildClick(Sender: TObject);
var
  Prj: TLazProject;
begin
  Prj := LazarusIDE.ActiveProject;
  if Prj <> nil then
  begin
    if LazarusIDE.DoSaveProject([]) = mrOk then
      LazarusIDE.DoBuildProject(crBuild, []);
  end else
    ExecuteActionByName('ATargetCompileClean');
end;

procedure TPGEditorHook.OnCleanClick(Sender: TObject);
var
  Prj: TLazProject;
begin
  Prj := LazarusIDE.ActiveProject;
  if Prj <> nil then
  begin
    if LazarusIDE.DoSaveProject([]) = mrOk then
      ExecuteIDECommand(Self, ecCleanUpAndBuild);
  end else
    ExecuteActionByName('ATargetCompileClean');
end;

procedure TPGEditorHook.OnRunClick(Sender: TObject);
begin
  ExecuteActionByName('ATargetRun');
end;

procedure TPGEditorHook.OnRunWithoutDebugClick(Sender: TObject);
begin
  ExecuteActionByName('ATargetActivate');
  LazarusIDE.DoRunProjectWithoutDebug;
end;

procedure TPGEditorHook.OnAddFilesClick(Sender: TObject);
var
  Prj: TLazProject;
  OpenDlg: TOpenDialog;
  i: Integer;
  NewPrjFile: TLazProjectFile;
begin
  DoEnsureTargetProjectOpen(Prj);
  if Prj = nil then Exit;
  OpenDlg := TOpenDialog.Create(nil);
  try
    if (Prj.Directory <> '') and FilenameIsAbsolute(Prj.Directory) then
      OpenDlg.InitialDir := Prj.Directory;
    OpenDlg.Title := 'Add Existing Files';
    OpenDlg.Options := OpenDlg.Options + [ofFileMustExist, ofPathMustExist, ofAllowMultiSelect];
    OpenDlg.Filter := 'All Files (*.*)|*.*|Pascal Files (*.pas;*.pp)|*.pas;*.pp|Forms (*.lfm;*.dfm)|*.lfm;*.dfm';
    if OpenDlg.Execute then
    begin
      for i := 0 to OpenDlg.Files.Count - 1 do
      begin
        NewPrjFile := Prj.CreateProjectFile(OpenDlg.Files[i]);
        Prj.AddFile(NewPrjFile, false);
      end;
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TPGEditorHook.OnNewFormClick(Sender: TObject);
begin
  DoAddNewFileToTarget(FileDescNameLCLForm);
end;

procedure TPGEditorHook.OnNewFrameClick(Sender: TObject);
begin
  DoAddNewFileToTarget(FileDescNameFrame);
end;

procedure TPGEditorHook.OnNewDataModuleClick(Sender: TObject);
begin
  DoAddNewFileToTarget(FileDescNameDatamodule);
end;

procedure TPGEditorHook.OnNewUnitClick(Sender: TObject);
begin
  DoAddNewFileToTarget(FileDescNamePascalUnit);
end;

procedure TPGEditorHook.OnNewOtherClick(Sender: TObject);
var
  Prj: TLazProject;
begin
  DoEnsureTargetProjectOpen(Prj);
  ExecuteIDECommand(nil, ecNew);
end;

procedure TPGEditorHook.OnRemoveFileClick(Sender: TObject);
var
  Prj: TLazProject;
  Items: TStringList;
  i, ChosenIdx: Integer;
  CurFile: TLazProjectFile;
begin
  DoEnsureTargetProjectOpen(Prj);
  if (Prj = nil) or (Prj.FileCount <= 1) then Exit;
  Items := TStringList.Create;
  try
    for i := 0 to Prj.FileCount - 1 do
    begin
      CurFile := Prj.Files[i];
      if (CurFile <> Prj.MainFile) and CurFile.IsPartOfProject then
        Items.AddObject(ExtractFileName(CurFile.Filename), CurFile);
    end;
    if Items.Count = 0 then Exit;
    ChosenIdx := InputCombo('Confirm Removal', 'Select file to remove:', Items);
    if (ChosenIdx >= 0) and (ChosenIdx < Items.Count) then
    begin
      CurFile := TLazProjectFile(Items.Objects[ChosenIdx]);
      if (CurFile <> nil) and (IDEMessageDialog('Confirm Removal',
        Format('Remove "%s" from project?', [CurFile.Filename]),
        mtConfirmation, [mbYes, mbNo]) = mrYes) then
      begin
        for i := 0 to Prj.FileCount - 1 do
        begin
          if Prj.Files[i] = CurFile then
          begin
            Prj.RemoveUnit(i, true);
            Break;
          end;
        end;
      end;
    end;
  finally
    Items.Free;
  end;
end;

procedure TPGEditorHook.OnRemoveProjectClick(Sender: TObject);
begin
  ExecuteActionByName('AProjectGroupDelete');
end;

procedure TPGEditorHook.OnSaveClick(Sender: TObject);
var
  Prj: TLazProject;
begin
  Prj := LazarusIDE.ActiveProject;
  if Prj <> nil then
    LazarusIDE.DoSaveProject([])
  else
    ExecuteActionByName('AProjectGroupSave');
end;

procedure TPGEditorHook.OnSaveAsClick(Sender: TObject);
var
  Prj: TLazProject;
begin
  Prj := LazarusIDE.ActiveProject;
  if Prj <> nil then
    LazarusIDE.DoSaveProject([sfSaveAs])
  else
    ExecuteActionByName('AProjectGroupSaveAs');
end;

procedure TPGEditorHook.OnRenameClick(Sender: TObject);
var
  Prj: TLazProject;
begin
  Prj := LazarusIDE.ActiveProject;
  if Prj <> nil then
    LazarusIDE.DoSaveProject([sfSaveAs]);
end;

procedure TPGEditorHook.OnActivateClick(Sender: TObject);
begin
  ExecuteActionByName('ATargetActivate');
end;

{ TProjectMenuManager }

class procedure TProjectMenuManager.Initialize;
var
  AParent: TIDEMenuSection;
begin
  if FInitialized then Exit;
  FInitialized := True;

  // 1. Hook Project Inspector popup menu via MenuIntf
  if ProjectInspectorItemsMenuRoot <> nil then
  begin
    if ProjectInspectorItemsMenuRoot.FindByName('ProjectMenuBuild') = nil then
    begin
      // 1. Build Section (Compile, Build, Clean)
      FProjInspMenuSectionBuild := RegisterIDEMenuSection(ProjectInspectorItemsMenuRoot, 'ProjectMenuBuild');
      AParent := FProjInspMenuSectionBuild;
      FProjInspMenuCompile := RegisterIDEMenuCommand(AParent, 'Compile', 'Compile', @DoCompileClick, nil, IDECommandList.FindIDECommand(ecCompile));
      FProjInspMenuBuild := RegisterIDEMenuCommand(AParent, 'Build', 'Build', @DoBuildClick, nil, IDECommandList.FindIDECommand(ecBuild));
      FProjInspMenuClean := RegisterIDEMenuCommand(AParent, 'Clean', 'Clean', @DoCleanClick, nil, IDECommandList.FindIDECommand(ecCleanUpAndBuild));

      // 2. Run Section (Run, Run Without Debugging)
      FProjInspMenuSectionRun := RegisterIDEMenuSection(ProjectInspectorItemsMenuRoot, 'ProjectMenuRun');
      AParent := FProjInspMenuSectionRun;
      FProjInspMenuRun := RegisterIDEMenuCommand(AParent, 'Run', 'Run', @DoRunClick, nil, IDECommandList.FindIDECommand(ecRun));
      FProjInspMenuRunWithoutDebugging := RegisterIDEMenuCommand(AParent, 'RunWithoutDebugging', 'Run Without Debugging', @DoRunWithoutDebugClick, nil, IDECommandList.FindIDECommand(ecRunWithoutDebugging));

      // 3. Add Section (Add..., Add New >)
      FProjInspMenuSectionAdd := RegisterIDEMenuSection(ProjectInspectorItemsMenuRoot, 'ProjectMenuAdd');
      AParent := FProjInspMenuSectionAdd;
      FProjInspMenuAddFiles := RegisterIDEMenuCommand(AParent, 'AddFiles', 'Add...', @DoAddFilesClick, nil, nil, 'laz_add');
      FProjInspMenuAddNew := RegisterIDESubMenu(AParent, 'AddNew', 'Add New');
      FProjInspMenuAddNewForm := RegisterIDEMenuCommand(FProjInspMenuAddNew, 'Form', 'Form', @DoNewFormClick, nil, nil, 'item_form');
      FProjInspMenuAddNewFrame := RegisterIDEMenuCommand(FProjInspMenuAddNew, 'Frame', 'Frame', @DoNewFrameClick, nil, nil, 'item_frame');
      FProjInspMenuAddNewDataModule := RegisterIDEMenuCommand(FProjInspMenuAddNew, 'DataModule', 'Data Module', @DoNewDataModuleClick, nil, nil, 'item_datamodule');
      FProjInspMenuAddNewUnit := RegisterIDEMenuCommand(FProjInspMenuAddNew, 'Unit', 'Unit', @DoNewUnitClick, nil, nil, 'item_unit');
      FProjInspMenuSectionAddNewOther := RegisterIDEMenuSection(FProjInspMenuAddNew, 'OtherSection');
      FProjInspMenuAddNewOther := RegisterIDEMenuCommand(FProjInspMenuSectionAddNewOther, 'Other', 'Other...', @DoNewOtherClick, nil, IDECommandList.FindIDECommand(ecNew));

      // 4. Remove Section (Remove File...)
      FProjInspMenuSectionRemove := RegisterIDEMenuSection(ProjectInspectorItemsMenuRoot, 'ProjectMenuRemove');
      AParent := FProjInspMenuSectionRemove;
      FProjInspMenuRemoveFile := RegisterIDEMenuCommand(AParent, 'RemoveFile', 'Remove File...', @DoRemoveFileClick, nil, nil, 'laz_delete');

      // 5. Save Section (Save, Save As..., Rename)
      FProjInspMenuSectionSave := RegisterIDEMenuSection(ProjectInspectorItemsMenuRoot, 'ProjectMenuSave');
      AParent := FProjInspMenuSectionSave;
      FProjInspMenuSave := RegisterIDEMenuCommand(AParent, 'Save', 'Save', @DoSaveClick, nil, IDECommandList.FindIDECommand(ecSaveProject));
      FProjInspMenuSaveAs := RegisterIDEMenuCommand(AParent, 'SaveAs', 'Save As...', @DoSaveAsClick, nil, IDECommandList.FindIDECommand(ecSaveProjectAs));
      FProjInspMenuRename := RegisterIDEMenuCommand(AParent, 'Rename', 'Rename', @DoRenameClick);

      // Register OnShow handler on the section
      FProjInspMenuSectionBuild.AddHandlerOnShow(@OnProjectInspectorMenuShow);
    end;
  end;

  // 2. Hook Project Groups forms
  Screen.AddHandlerFormAdded(@OnScreenFormAdded);
  HookExistingProjectGroupEditors;
end;

class procedure TProjectMenuManager.OnProjectInspectorMenuShow(Sender: TObject);
var
  AForm: TCustomForm;
  TV: TTreeView;
  HasProject, IsDepSelected: Boolean;
  SelNode: TTreeNode;
begin
  HasProject := (LazarusIDE <> nil) and (LazarusIDE.ActiveProject <> nil);
  IsDepSelected := False;

  if (Sender <> nil) and (Sender is TCustomForm) then
  begin
    AForm := TCustomForm(Sender);
    TV := AForm.FindComponent('ItemsTreeView') as TTreeView;
    if (TV <> nil) and (TV.Selected <> nil) then
    begin
      SelNode := TV.Selected;
      while SelNode <> nil do
      begin
        if SameText(SelNode.Text, 'Required Packages') or ((SelNode.Parent = nil) and (SelNode.Index = 1)) then
        begin
          IsDepSelected := True;
          Break;
        end;
        SelNode := SelNode.Parent;
      end;
    end;
  end;

  if FProjInspMenuSectionBuild <> nil then
    FProjInspMenuSectionBuild.Visible := HasProject and not IsDepSelected;
  if FProjInspMenuSectionRun <> nil then
    FProjInspMenuSectionRun.Visible := HasProject and not IsDepSelected;
  if FProjInspMenuSectionAdd <> nil then
    FProjInspMenuSectionAdd.Visible := HasProject and not IsDepSelected;
  if FProjInspMenuSectionRemove <> nil then
    FProjInspMenuSectionRemove.Visible := HasProject and not IsDepSelected;
  if FProjInspMenuSectionSave <> nil then
    FProjInspMenuSectionSave.Visible := HasProject and not IsDepSelected;
end;

class procedure TProjectMenuManager.OnScreenFormAdded(Sender: TObject; AForm: TCustomForm);
begin
  if (AForm <> nil) and (AForm.ClassNameIs('TProjectGroupEditorForm') or (AForm.Name = 'ProjectGroupEditor')) then
    HookProjectGroupEditor(AForm);
end;

class procedure TProjectMenuManager.HookProjectGroupEditor(AForm: TCustomForm);
var
  PM: TPopupMenu;
  TV: TTreeView;
  HookObj: TPGEditorHook;
begin
  if AForm = nil then Exit;
  if AForm.FindComponent('PGMenuHook') <> nil then Exit;

  PM := AForm.FindComponent('PopupMenuTree') as TPopupMenu;
  TV := AForm.FindComponent('TVPG') as TTreeView;
  if PM = nil then Exit;

  HookObj := TPGEditorHook.Create(AForm);
  HookObj.Name := 'PGMenuHook';
  HookObj.Form := AForm;
  HookObj.TreeMenu := PM;
  HookObj.TreeView := TV;
  HookObj.SetupMenu;
end;

class procedure TProjectMenuManager.HookExistingProjectGroupEditors;
var
  i: Integer;
  AForm: TCustomForm;
begin
  for i := 0 to Screen.CustomFormCount - 1 do
  begin
    AForm := Screen.CustomForms[i];
    if (AForm <> nil) and (AForm.ClassNameIs('TProjectGroupEditorForm') or (AForm.Name = 'ProjectGroupEditor')) then
      HookProjectGroupEditor(AForm);
  end;
end;

class procedure TProjectMenuManager.DoAddNewFile(const ADescName: string);
var
  Prj: TLazProject;
  Desc: TProjectFileDescriptor;
  Flags: TNewFlags;
  NewFilename: string;
begin
  Prj := LazarusIDE.ActiveProject;
  if Prj = nil then Exit;
  Desc := ProjectFileDescriptors.FindByName(ADescName);
  if Desc = nil then Exit;
  Flags := [nfOpenInEditor, nfCreateDefaultSrc];
  Desc.Owner := Prj;
  try
    NewFilename := '';
    LazarusIDE.DoNewEditorFile(Desc, NewFilename, '', Flags);
  finally
    Desc.Owner := nil;
  end;
end;

class procedure TProjectMenuManager.DoCompileClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecCompile);
end;

class procedure TProjectMenuManager.DoBuildClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecBuild);
end;

class procedure TProjectMenuManager.DoCleanClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecCleanUpAndBuild);
end;

class procedure TProjectMenuManager.DoRunClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecRun);
end;

class procedure TProjectMenuManager.DoRunWithoutDebugClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecRunWithoutDebugging);
end;

class procedure TProjectMenuManager.DoAddFilesClick(Sender: TObject);
var
  Prj: TLazProject;
  OpenDlg: TOpenDialog;
  i: Integer;
  NewPrjFile: TLazProjectFile;
begin
  Prj := LazarusIDE.ActiveProject;
  if Prj = nil then Exit;
  OpenDlg := TOpenDialog.Create(nil);
  try
    if (Prj.Directory <> '') and FilenameIsAbsolute(Prj.Directory) then
      OpenDlg.InitialDir := Prj.Directory;
    OpenDlg.Title := 'Add Existing Files';
    OpenDlg.Options := OpenDlg.Options + [ofFileMustExist, ofPathMustExist, ofAllowMultiSelect];
    OpenDlg.Filter := 'All Files (*.*)|*.*|Pascal Files (*.pas;*.pp)|*.pas;*.pp|Forms (*.lfm;*.dfm)|*.lfm;*.dfm';
    if OpenDlg.Execute then
    begin
      for i := 0 to OpenDlg.Files.Count - 1 do
      begin
        NewPrjFile := Prj.CreateProjectFile(OpenDlg.Files[i]);
        Prj.AddFile(NewPrjFile, false);
      end;
    end;
  finally
    OpenDlg.Free;
  end;
end;

class procedure TProjectMenuManager.DoNewFormClick(Sender: TObject);
begin
  DoAddNewFile(FileDescNameLCLForm);
end;

class procedure TProjectMenuManager.DoNewFrameClick(Sender: TObject);
begin
  DoAddNewFile(FileDescNameFrame);
end;

class procedure TProjectMenuManager.DoNewDataModuleClick(Sender: TObject);
begin
  DoAddNewFile(FileDescNameDatamodule);
end;

class procedure TProjectMenuManager.DoNewUnitClick(Sender: TObject);
begin
  DoAddNewFile(FileDescNamePascalUnit);
end;

class procedure TProjectMenuManager.DoNewOtherClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecNew);
end;

class procedure TProjectMenuManager.DoRemoveFileClick(Sender: TObject);
var
  Prj: TLazProject;
  Items: TStringList;
  i, ChosenIdx: Integer;
  CurFile: TLazProjectFile;
begin
  Prj := LazarusIDE.ActiveProject;
  if (Prj = nil) or (Prj.FileCount <= 1) then Exit;
  Items := TStringList.Create;
  try
    for i := 0 to Prj.FileCount - 1 do
    begin
      CurFile := Prj.Files[i];
      if (CurFile <> Prj.MainFile) and CurFile.IsPartOfProject then
        Items.AddObject(ExtractFileName(CurFile.Filename), CurFile);
    end;
    if Items.Count = 0 then Exit;
    ChosenIdx := InputCombo('Confirm Removal', 'Select file to remove:', Items);
    if (ChosenIdx >= 0) and (ChosenIdx < Items.Count) then
    begin
      CurFile := TLazProjectFile(Items.Objects[ChosenIdx]);
      if (CurFile <> nil) and (IDEMessageDialog('Confirm Removal',
        Format('Remove "%s" from project?', [CurFile.Filename]),
        mtConfirmation, [mbYes, mbNo]) = mrYes) then
      begin
        for i := 0 to Prj.FileCount - 1 do
        begin
          if Prj.Files[i] = CurFile then
          begin
            Prj.RemoveUnit(i, true);
            Break;
          end;
        end;
      end;
    end;
  finally
    Items.Free;
  end;
end;

class procedure TProjectMenuManager.DoSaveClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecSaveProject);
end;

class procedure TProjectMenuManager.DoSaveAsClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecSaveProjectAs);
end;

class procedure TProjectMenuManager.DoRenameClick(Sender: TObject);
begin
  ExecuteIDECommand(nil, ecSaveProjectAs);
end;

end.
