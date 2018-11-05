unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

CONST N=31;
      RAD = 10;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    Panel2: TPanel;
    Button2: TButton;
    Panel3: TPanel;
    Button1: TButton;
    Memo1: TMemo;
    Button3: TButton;
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    function LoadImg(id:integer):boolean;
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Draw_cur;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TArrPoints = array[1..20] of TPoint;

var
  Form1: TForm1;
  index:integer=1;
  cur_size:integer;
  sizer:integer = 3;
  size:integer;
  points:array[1..31] of TArrPoints;
  drawed:integer;
  backed_bmp:tbitmap;

implementation

{$R *.dfm}
procedure TForm1.draw_cur;
var i:integer;
begin
i:=1;
PaintBox1.Refresh;
//PaintBox1.Canvas.FillRect(rect(0,0,PaintBox1.Width,PaintBox1.Height));
PaintBox1.Canvas.Pen.Color:=clLime;
PaintBox1.Canvas.Brush.Color:=clRed;
PaintBox1.Canvas.Pen.Width:=2;
PaintBox1.Canvas.Brush.Style:=bsSolid;
paintbox1.Canvas.MoveTo(points[index,1].x*sizer,points[index,1].y*sizer);
while (points[index,i].X>0) or (points[index,i].Y>0) do
  begin
  PaintBox1.Canvas.LineTo(points[index,i].X*sizer,points[index,i].Y*sizer);
  PaintBox1.Canvas.Ellipse(points[index,i].X*sizer-RAD,
                           points[index,i].Y*sizer-RAD,
                           points[index,i].X*sizer+RAD,
                           points[index,i].Y*sizer+RAD);

  i:=i+1;
  end;
cur_size:=i-1;
end;

function TForm1.LoadImg(id:integer):boolean;
var f:string;
    cache:tpicture;
begin
f:='../tile'+inttostr(id)+'.bmp';
if FileExists(f) then
  begin
  try
  cache:=TPicture.Create;
  cache.LoadFromFile(f);
  PaintBox1.Width:=0;
  PaintBox1.Height:=0;
  form1.Width:=(form1.Width-image1.width) + 3*cache.Width;
  form1.Height:=(form1.Height-image1.Height) + 3*cache.Height;
  Image1.Picture:=cache;
  backed_bmp:=image1.Picture.Bitmap;
  PaintBox1.Width:=image1.Width;
  PaintBox1.Height:=image1.Height;
//  Draw_cur;
  LoadImg:=true;
  except
  LoadImg:=false;
  end;
  end else begin
  LoadImg:=false;
  end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
LoadImg(index);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
if LoadImg(index+1) then
  begin
  index:=index+1;
  ComboBox1.ItemIndex:=index-1;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
if LoadImg(index-1) then
  begin
  index:=index-1;
  ComboBox1.ItemIndex:=index-1;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var f:file of TArrPoints;
    i:integer;
begin
ComboBox1.Items.Clear;
for i:=1 to N do
  ComboBox1.Items.Add(inttostr(i));
ComboBox1.ItemIndex:=0;
backed_bmp:=TBitmap.Create;
backed_bmp.PixelFormat:=pf16bit;
AssignFile(f,'points.cur');
Reset(f);
size:=0;
while not eof(f) do
  begin
  size:=size+1;
  read(f,points[size]);
  end;
CloseFile(f);
end;

procedure TForm1.FormDestroy(Sender: TObject);
var f:file of TArrPoints;
    i:integer;
begin
AssignFile(f,'points.cur');
Rewrite(f);
for i:=1 to N do
  Write(f,points[i]);
CloseFile(f);
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
if cur_size>1 then
  begin
  points[index,cur_size].X:=0;
  points[index,cur_size].Y:=0;
  cur_size:=cur_size-1;
  end;
Draw_cur;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,j:integer;
begin
j:=0;
for i:=1 to cur_size do
  if sqr(points[index,i].X*3-X)+sqr(points[index,i].Y*3-Y)<sqr(RAD) then
    j:=i;
if j>0 then
  begin
  drawed:=j;
  end else if (cur_size<20) then begin
  cur_size:=cur_size+1;
  points[index,cur_size].X:=x div 3;
  points[index,cur_size].y:=y div 3;
  Draw_cur;
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
drawed:=0;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if (drawed>0) then
  begin
  points[index,drawed].X:=x div 3;
  points[index,drawed].Y:=y div 3;
  Draw_cur;
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
//Draw_cur;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
Draw_cur;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
if LoadImg(ComboBox1.ItemIndex+1) then
  begin
  index:=ComboBox1.ItemIndex+1;
  end else begin
  ComboBox1.ItemIndex:=index-1;
  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
var i,j:integer;
    first:boolean;
    x1,y1:integer;
    s:string;
begin
memo1.Text:='var curves = [';
for i:=1 to N do
  begin
  if i=1 then
    memo1.lines.add('[')
    else if i=N then
    memo1.Lines.Add(']')
    else
    memo1.Lines.Add('],[');
  s:='../tile'+inttostr(i)+'.bmp';
  x1:=0;
  y1:=0;
  if fileexists(s) then
     begin
     backed_bmp.LoadFromFile(s);
     x1:=backed_bmp.Width;
     y1:=backed_bmp.Height;
     x1:=(strtoint(edit1.text)-x1) div 2;
     x1:=(strtoint(edit2.text)-y1) div 2;
     end;
  j:=1;
  first:=true;
  while (points[i,j].X>0) or (points[i,j].Y>0) do
    begin
    if first then
      first:=false
      else
      memo1.Lines.Add(',');
    memo1.lines.add('['+inttostr(points[i,j].X+x1)+','+inttostr(points[i,j].Y+y1)+']');
    j:=j+1;
    end;
  end;
memo1.Lines.Add('];');
memo1.Text:=StringReplace(memo1.Text,chr(13)+chr(10),'',[rfReplaceAll]);
memo1.Lines.SaveToFile('../../../template/curves.js');
end;

end.
