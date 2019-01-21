unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,Vcl.Clipbrd,System.DateUtils;
const
   CELLCOUNT = 20;
type
  TForm1 = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    CenterX , CenterY : Integer;
    CellX , CellY : Integer;
    procedure RePaint;
    procedure FillCellColor(X,Y:Integer;Color : TColor;const Text:String = '');
    procedure DrawPosition();
    function Diff(Value1,Value2:Integer):Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.Diff(Value1, Value2: Integer): Integer;
begin
  Value1 := Abs(Value1);
  Value2 := Abs(Value2);
  Result := Abs(Value1 - Value2)
end;

procedure TForm1.DrawPosition;
type
  TDirection = (deLeft,deRight,deTop,deBottom);
var
  i : Integer;
  X , Y  : Integer;
  XRange : Integer;
  YRange : Integer;
  tmpRange : Integer;
  Direction : TDirection;
  Str : string;
begin
  Direction := deRight;
  X := CenterX;
  Y := CenterY;
  XRange := 0;
  YRange := 0;

  Str := '[';
  for I := 0 to 15 * 15 - 1 do begin

    case Direction of
      deLeft:
      begin
        X := X - 1;
        tmpRange := Diff(X , CenterX);
        if tmpRange >= XRange then
        begin
          XRange := tmpRange;
          Direction := deBottom;
        end;
      end;

      deRight:
      begin
        X := X + 1;
        tmpRange := Diff(X , CenterX);
        if tmpRange > XRange then
        begin
          XRange := tmpRange;
          Direction := deTop;
        end;
      end;

      deTop:
      begin
        Y := Y - 1 ;
        tmpRange := Diff(Y , CenterY);
        if tmpRange > YRange then
        begin
          YRange := tmpRange;
          Direction := deLeft;
        end;
      end;

      deBottom:begin
        Y := Y + 1;
        tmpRange := Diff(Y , CenterY);
        if tmpRange >= YRange then
        begin
          YRange := tmpRange;
          Direction := deRight;
        end;
      end;

    end;

    FillCellColor(X,Y,clBlue,IntToStr(i));

    Str := Str + IntToStr(X - CenterX) + ',' + IntToStr(Y - CenterY) + ',';

    if (i mod 20) = 0 then
    begin
      Str := Str + #13#10;
    end;
  end;


  //拷贝到剪切板

  Str := Copy(Str,1,Length(Str) - 1);

  Str := '//以下掉落位置数组预定义代码为工具手动生成 请勿人工编辑。李昀  生成日期: ' + FormatDateTime('YYYY-MM-DD HH:NN:SS',Now()) + #13#10 + Str;
  Str := Str + '];';
  with TClipboard.Create do
  begin
    SetTextBuf(PWideChar(Str));
    Free;
  end;

end;

procedure TForm1.FillCellColor(X,Y:Integer;Color : TColor;const Text:String);
var
  Rect : TRect;
  OldColor :TColor;
  S:String;
  textFormat : TTextFormat;
begin
  Rect.Left := X * CellX + 1 ;
  Rect.Top := Y *CellY + 1;
  Rect.Width := CellX - 1;
  Rect.Height := CellY -1 ;

  OldColor := Canvas.Brush.Color;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect);
  Canvas.Brush.Color := OldColor;

  if Text <> '' then
  begin
    S := Text;
    Canvas.TextRect(Rect,S,textFormat);
  end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  RePaint();
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  RePaint();
end;

procedure TForm1.RePaint;
var
  XCellSize , YCellSize: Integer;
  X,Y,W,H:Integer;
begin
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(ClientRect);
  Canvas.Pen.Color := clBlack;
  Canvas.Rectangle(ClientRect);

  W := ClientRect.Width;
  H := ClientRect.Height;


  XCellSize := W div CELLCOUNT;
  YCellSize := H div CELLCOUNT;

  CellX := XCellSize;
  CellY := YCellSize;


  for X := 0 to CELLCOUNT - 1 do
  begin
    Canvas.MoveTo(X * CellX,0);
    Canvas.LineTo(X * CellX,W);
  end;

  for Y := 0 to CELLCOUNT - 1 do
  begin
    Canvas.MoveTo(0,Y * CellY);
    Canvas.LineTo(W,Y * CellY);
  end;

  CenterX := CELLCOUNT div 2;
  CenterY := CELLCOUNT Div 2;

  FillCellColor(CenterX,CenterY,clRed);

  Canvas.Font.Size := 14;


  DrawPosition();
end;




end.
