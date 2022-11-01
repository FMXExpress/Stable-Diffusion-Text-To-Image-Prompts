unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageBin, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, REST.Types,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.MultiView, REST.Response.Adapter,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  FireDAC.Comp.BatchMove.Text, FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.DataSet, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.ListBox, FMX.Layouts, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.DBScope, FMX.ExtCtrls,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TMainForm = class(TForm)
    ImageFormatTable: TFDMemTable;
    PerspectiveTable: TFDMemTable;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDBatchMove1: TFDBatchMove;
    StyleTable: TFDMemTable;
    VariationTable: TFDMemTable;
    SuperChargeTable: TFDMemTable;
    FDBatchMoveDataSetWriter1: TFDBatchMoveDataSetWriter;
    FDBatchMoveTextReader1: TFDBatchMoveTextReader;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    ResponseMemTable: TFDMemTable;
    MultiView1: TMultiView;
    GenerateButton: TButton;
    PostBodyMemo: TMemo;
    Layout1: TLayout;
    ImageFormatCB: TComboBox;
    Label1: TLabel;
    Layout2: TLayout;
    VariationCB: TComboBox;
    Label2: TLabel;
    Layout3: TLayout;
    SuperChargeCB: TComboBox;
    Label3: TLabel;
    Layout4: TLayout;
    StyleCB: TComboBox;
    Label4: TLabel;
    Layout5: TLayout;
    PerspectiveCB: TComboBox;
    Label5: TLabel;
    Layout6: TLayout;
    Label6: TLabel;
    SubjectEdit: TEdit;
    RandomButton: TButton;
    BuildPromptButton: TButton;
    PromptMemo: TMemo;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    BindSourceDB3: TBindSourceDB;
    LinkListControlToField3: TLinkListControlToField;
    BindSourceDB4: TBindSourceDB;
    LinkListControlToField4: TLinkListControlToField;
    BindSourceDB5: TBindSourceDB;
    LinkListControlToField5: TLinkListControlToField;
    Label7: TLabel;
    NegativePromptMemo: TMemo;
    ImageViewer: TImageViewer;
    NetHTTPClient1: TNetHTTPClient;
    MaterialOxfordBlueSB: TStyleBook;
    StatusBar: TStatusBar;
    StatusLabel: TLabel;
    ProgressBar: TProgressBar;
    ProgressTimer: TTimer;
    procedure GenerateButtonClick(Sender: TObject);
    procedure RandomButtonClick(Sender: TObject);
    procedure BuildPromptButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProgressTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  const
    // Get your own free API key here: https://stablediffusionapi.com/pricing
    API_KEY = '';


var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.Threading, System.Math, IdHashMessageDigest, System.IOUtils;

function MD5(const AString: String): String;
var
  LHash: TIdHashMessageDigest5;
begin
  LHash := TIdHashMessageDigest5.Create;
  try
    Result := LHash.HashStringAsHex(AString);
  finally
    LHash.Free;
  end;
end;

procedure TMainForm.BuildPromptButtonClick(Sender: TObject);
begin
  PromptMemo.Lines.Text := ImageFormatCB.Items[ImageFormatCB.ItemIndex];
  PromptMemo.Lines.Text := PromptMemo.Lines.Text + ' of ' + SubjectEdit.Text;
  PromptMemo.Lines.Text := PromptMemo.Lines.Text + ', ' + PerspectiveCB.Items[PerspectiveCB.ItemIndex];
  PromptMemo.Lines.Text := PromptMemo.Lines.Text + ', in the style of ' + StyleCB.Items[StyleCB.ItemIndex];
  PromptMemo.Lines.Text := PromptMemo.Lines.Text + ', ' + VariationCB.Items[VariationCB.ItemIndex];
  PromptMemo.Lines.Text := PromptMemo.Lines.Text + ', ' + SuperChargeCB.Items[SuperChargeCB.ItemIndex];
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDBatchMoveDataSetWriter1.DataSet := ImageFormatTable;
  FDBatchMoveTextReader1.FileName := ExtractFilePath(ParamStr(0)) + 'imageformat.txt';
  FDBatchMove1.Execute;
  FDBatchMoveDataSetWriter1.DataSet := PerspectiveTable;
  FDBatchMoveTextReader1.FileName := ExtractFilePath(ParamStr(0)) + 'perspective.txt';
  FDBatchMove1.Execute;
  FDBatchMoveDataSetWriter1.DataSet := StyleTable;
  FDBatchMoveTextReader1.FileName := ExtractFilePath(ParamStr(0)) + 'style.txt';
  FDBatchMove1.Execute;
  FDBatchMoveDataSetWriter1.DataSet := VariationTable;
  FDBatchMoveTextReader1.FileName := ExtractFilePath(ParamStr(0)) + 'variation.txt';
  FDBatchMove1.Execute;
  FDBatchMoveDataSetWriter1.DataSet := SuperChargeTable;
  FDBatchMoveTextReader1.FileName := ExtractFilePath(ParamStr(0)) + 'supercharge.txt';
  FDBatchMove1.Execute;
  RandomButtonClick(Self);
end;

procedure TMainForm.GenerateButtonClick(Sender: TObject);
begin
  if PromptMemo.Lines.Text='' then Exit;

  GenerateButton.Enabled := False;
  ProgressBar.Visible := True;
  RESTRequest1.Params[0].Value := PostBodyMemo.Lines.Text.Replace('%api_key%',API_KEY).Replace('%prompt%',PromptMemo.Lines.Text).Replace('%negative_prompt%',NegativePromptMemo.Lines.Text);
  TTask.Run(procedure begin
    try
    RESTRequest1.Execute;

       TThread.Synchronize(nil,procedure begin
         StatusLabel.Text := 'Status: ' + ResponseMemTable.FieldByName('status').AsString + ' Generation Time: ' + ResponseMemTable.FieldByName('generationTime').AsString + ' seconds';
         StatusLabel.TagString := ResponseMemTable.FieldByName('output').AsString.Replace('["','').Replace('"]','').Replace('\/','/');
       end);
       TTask.Run(procedure var LMS: TMemoryStream; begin
          LMS := TMemoryStream.Create;
          try
            NetHTTPClient1.Get(StatusLabel.TagString,LMS);
            TThread.Synchronize(nil,procedure begin
              ImageViewer.Bitmap.LoadFromStream(LMS);
              LMS.SaveToFile(TPath.Combine(ExtractFilePath(ParamStr(0)),MD5(StatusLabel.TagString) + '.png'));
            end);
          finally
            LMS.Free;
            TThread.Synchronize(nil,procedure begin
              ProgressBar.Visible := False;
              GenerateButton.Enabled := True;
            end);
          end;
        end);
    except
      on E:Exception do
        begin
          TThread.Synchronize(nil,procedure begin
            StatusLabel.Text := 'Status: Error';
            ProgressBar.Visible := False;
            GenerateButton.Enabled := True;
          end);
        end;
    end;
  end);
end;


procedure TMainForm.RandomButtonClick(Sender: TObject);
begin
  ImageFormatCB.ItemIndex := RandomRange(0,ImageFormatCB.Items.Count-1);
  PerspectiveCB.ItemIndex := RandomRange(0,PerspectiveCB.Items.Count-1);
  StyleCB.ItemIndex := RandomRange(0,StyleCB.Items.Count-1);
  VariationCB.ItemIndex := RandomRange(0,VariationCB.Items.Count-1);
  SuperChargeCB.ItemIndex := RandomRange(0,SuperChargeCB.Items.Count-1);
end;

procedure TMainForm.ProgressTimerTimer(Sender: TObject);
begin
  if ProgressBar.Value=ProgressBar.Max then
    ProgressBar.Value := ProgressBar.Min
  else
    ProgressBar.Value := ProgressBar.Value+5;
end;

initialization
  Randomize;

end.
