//a-star アルゴリズムによる経路探索 by にゃんちｗ
#ifndef __astar__
#define __astar__

#module astar

//通れるか通れないか
#define global ASTAR_INFO_IMPASSABLE 0
#define global ASTAR_INFO_PASSABLE 1

//アルゴリズムで使う
#define ASTAR_INTERNAL_NONE 0
#define ASTAR_INTERNAL_OPENED 1
#define ASTAR_INTERNAL_CLOSED 2

/*
astar_search int start_x, int start_y, int destination_x, int destination_y, array source_2dmap, var output_var
スタート位置から目的地までの最短経路を探索し、output_var に結果を文字列で返します。
パラメータ:
start_x: スタート地点のX座標
start_y: スタート地点のY座標
destination_x: 目的地のX座標
destination_y: 目的地のY座標
source_2dmap: マップの情報を格納している配列。マップデータは2次元のint配列で、通れる場所をASTAR_INFO_PASSABLE、通れない場所をASTAR_INFO_IMPASSABLEで示したデータ。
output_var: 結果が格納される変数(初期化不要)
戻り値: 目的地に到達可能である場合は1。目的地に到達できない場合は0。エラーの場合は-1。output_var に返される文字列フォーマットは、スタート位置から開始して、経由する座標(x-y)を\n区切りで示したデータ。到達不可能およびエラーの場合には、空の文字列が書き込まれる。
*/

#deffunc astar_search int _px, int _py, int _dx, int _dy, array _source, var out
px=_px:py=_py:dx=_dx:dy=_dy
mx=length(_source)
my=length2(_source)

//なぜか分からないが、配列を一度コピーしてやらないと内部エラー7になった。たぶん、hspの array 指定が次元数を考慮していない。勝手に1次元しか来ないと思ってる。just クソ。
dim source,mx,my
memcpy source,_source,4*mx*my
//メモリ確保
dim nodeState,mx,my
dim nodeCostA,mx,my
dim nodeCostH,mx,my
dim nodeScore,mx,my
dim nodeParentx,mx,my
dim nodeParenty,mx,my
sdim openList,10000
openListSize=0
openListNum=0
//一時変数
cpx=px
cpy=py
cCost=0
cScore=0
cScoreX=-1
cScoreY=-1
open px,py,-1,-1
parent=stat
//スタート地点をオープン
counter=0
nopath=0
repeat//探索開始
counter++
if cpx=dx: if cpy=dy:break//目的地に着いたら終了する
if openListNum=0:nopath=1:break//オープンリストがもうないので、どうやっても行けない
//今は4方向。8方向に対応させたければ、この下にあるオープンの定義を追加して、斜め上とかもオープンするように変更する。
if cpx!0:open cpx-1,cpy,cpx,cpy//左をオープン
if cpx!mx-1:open cpx+1,cpy,cpx,cpy//右をオープン
if cpy!0:open cpx,cpy-1,cpx,cpy//下をオープン
if cpy!my-1:open cpx,cpy+1,cpx,cpy//上をオープン
close parent//親ノードは閉じる
//オープンリストから、スコアがもっとも小さいものを探す
cScore=-1//値は未設定
repeat openListNum
x=lpeek(openList,cnt*8)
y=lpeek(openList,(cnt*8)+4)
if cScore=-1 or nodeScore(x,y)<cScore:{//より小さいコストで行ける経路なので、こっちに更新
cScore=nodeScore(x,y)
cScoreX=x
cScoreY=y
}
loop//探索した
//最短コストだと分かった場所にカーソルを移動させる。次はここから周囲をオープンしていくことになる。
cpx=cScoreX
cpy=cScoreY
parent=getOpenList(cpx,cpy)//今、親ノードはオープンされているので、座標から管理番号を計算してきて入れる
loop
//経路探索の答えが出た
sdim tmp,10000
if nopath:{//行けなかった
tmp=""
}else{//経路があったので、座標を入れていく
tmp=""+dx+"-"+dy+","
repeat//親ノードをたどり続ける、実はopen関数がちゃっかりセットしてくれている
prx=nodeParentx(cpx,cpy)
pry=nodeParenty(cpx,cpy)
//親ノードにカーソル移動
cpx=prx
cpy=pry
tmp+=""+prx+"-"+pry+","
if prx=px:if pry=py:break//スタートまで戻ってきたので抜ける
loop
//目的地から親をたどってきてスタートまで来たので、このリストは逆にする必要がある
split tmp,",",tmp2
sdim tmp,10000
counter=length(tmp2)-2
repeat counter+1
tmp+=tmp2(counter)+"\n"
counter--
loop
sdim tmp2,0
}//行けたか行けなかったか、どちらにしろ情報を入れた
sdim out,strlen(tmp)+1
out=tmp
sdim tmp,0
return nopath|1

//ここから下は内部で使う関数
#deffunc open int openx, int openy, int parentx, int parenty//親から隣のノードをオープンする
if nodeState(openx,openy)!ASTAR_INTERNAL_NONE:return//過去にオープンしているところは再オープンできないし、今オープンしてるところもオープンできない
if source(openx,openy)=ASTAR_INFO_IMPASSABLE:return//通れないところはオープンできない
nodeState(openx,openy)=ASTAR_INTERNAL_OPENED
//実コストと推定コストを計算
nodeCostA(openx,openy)=abs(px-openx)+abs(py-openy)
nodeCostH(openx,openy)=abs(openx-dx)+abs(openy-dy)
//二つのコストをもとにスコアを計算
nodeScore(openx,openy)=nodeCostA(openx,openy)+nodeCostH(openx,openy)
if parentx!-1 and parenty!-1:nodeParentx(openx,openy)=parentx:nodeParenty(openx,openy)=parenty//親がいれば、親ノードの場所を格納
//オープンリストに書き込み
lpoke openList,openListSize,openx
lpoke openList,openListSize+4,openy
openListSize+=8
openListNum++
return openListSize-8

#deffunc close int closeNum//指定されたオフセットのノードをクローズし、オープンリストから削除する
closex=lpeek(openList,closeNum)
closey=lpeek(openList,closeNum+4)
nodeState(closex,closey)=ASTAR_INTERNAL_CLOSED
memcpy openList,openList,10000-closeNum-8,closeNum,closeNum+8//メモリ領域をずらして上書き
openListNum--
openListSize-=8
return
#defcfunc getOpenList int getx, int gety//座標から、オープンリスト上のオフセットを計算する
found=-1
repeat openListNum
if lpeek(openList,cnt*8)=getx:if lpeek(openList,(cnt*8)+4)=gety:found=cnt*8:break
loop
return found

#global

#endif